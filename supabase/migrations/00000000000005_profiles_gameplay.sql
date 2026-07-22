-- LELOMS Profiles Gameplay Fields Migration
-- Migration 005: Study tracking, energy, hearts, localization, academic fields

-- ==================== ADD NEW COLUMNS ====================
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS daily_study_minutes INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_login TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS last_study_date DATE,
  ADD COLUMN IF NOT EXISTS experience_total INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS energy INTEGER NOT NULL DEFAULT 100,
  ADD COLUMN IF NOT EXISTS hearts INTEGER NOT NULL DEFAULT 5,
  ADD COLUMN IF NOT EXISTS country TEXT,
  ADD COLUMN IF NOT EXISTS language TEXT NOT NULL DEFAULT 'es',
  ADD COLUMN IF NOT EXISTS timezone TEXT,
  ADD COLUMN IF NOT EXISTS birth_year INTEGER,
  ADD COLUMN IF NOT EXISTS academic_year INTEGER,
  ADD COLUMN IF NOT EXISTS favorite_subject TEXT;

-- ==================== INDEXES ====================
CREATE INDEX IF NOT EXISTS idx_profiles_language ON profiles(language);
CREATE INDEX IF NOT EXISTS idx_profiles_country ON profiles(country);
CREATE INDEX IF NOT EXISTS idx_profiles_academic_year ON profiles(academic_year);
CREATE INDEX IF NOT EXISTS idx_profiles_energy ON profiles(energy);
CREATE INDEX IF NOT EXISTS idx_profiles_last_login ON profiles(last_login);
CREATE INDEX IF NOT EXISTS idx_profiles_daily_study ON profiles(daily_study_minutes);

-- ==================== UPDATE TRIGGER WITH NEW DEFAULTS ====================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name, language, energy, hearts)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', 'user_' || substr(NEW.id::text, 1, 8)),
    COALESCE(NEW.raw_user_meta_data->>'name', 'Estudiante'),
    COALESCE(NEW.raw_user_meta_data->>'language', 'es'),
    100,
    5
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

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
