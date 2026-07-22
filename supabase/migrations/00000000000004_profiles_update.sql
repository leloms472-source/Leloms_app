-- LELOMS Profiles Update Migration
-- Migration 004: Enhanced profiles table, RLS, auto-create trigger

-- ==================== UPDATE PROFILES TABLE ====================
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS username TEXT UNIQUE,
  ADD COLUMN IF NOT EXISTS full_name TEXT,
  ADD COLUMN IF NOT EXISTS career TEXT,
  ADD COLUMN IF NOT EXISTS university TEXT,
  ADD COLUMN IF NOT EXISTS semester INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS coins INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS pet_id UUID,
  ADD COLUMN IF NOT EXISTS tree_level INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS premium BOOLEAN NOT NULL DEFAULT FALSE;

-- Migrate existing data
UPDATE profiles SET full_name = name WHERE full_name IS NULL AND name IS NOT NULL;
UPDATE profiles SET coins = 0 WHERE coins IS NULL;
UPDATE profiles SET tree_level = 1 WHERE tree_level IS NULL;
UPDATE profiles SET semester = 1 WHERE semester IS NULL;
UPDATE profiles SET premium = FALSE WHERE premium IS NULL;

-- Drop old columns (after data migration)
ALTER TABLE profiles DROP COLUMN IF EXISTS name;
ALTER TABLE profiles DROP COLUMN IF EXISTS email;
ALTER TABLE profiles DROP COLUMN IF EXISTS current_xp;
ALTER TABLE profiles DROP COLUMN IF EXISTS next_level_xp;

-- ==================== INDEXES ====================
CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_career ON profiles(career);
CREATE INDEX IF NOT EXISTS idx_profiles_university ON profiles(university);
CREATE INDEX IF NOT EXISTS idx_profiles_level ON profiles(level);
CREATE INDEX IF NOT EXISTS idx_profiles_coins ON profiles(coins);
CREATE INDEX IF NOT EXISTS idx_profiles_premium ON profiles(premium) WHERE premium = TRUE;

-- ==================== UPDATE AUTO-CREATE PROFILE TRIGGER ====================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', 'user_' || substr(NEW.id::text, 1, 8)),
    COALESCE(NEW.raw_user_meta_data->>'name', 'Estudiante')
  );
  INSERT INTO public.streaks (user_id) VALUES (NEW.id);
  INSERT INTO public.sanctuary (user_id) VALUES (NEW.id);
  INSERT INTO public.pets (user_id) VALUES (NEW.id);
  INSERT INTO public.trees (user_id) VALUES (NEW.id);
  INSERT INTO public.settings (user_id) VALUES (NEW.id);
  INSERT INTO public.cosmetics (user_id) VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Re-create trigger in case it was dropped
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
