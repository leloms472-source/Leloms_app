-- LELOMS RLS Policies Migration
-- Migration 002: Row Level Security Policies

-- ==================== ENABLE RLS ====================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE careers ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE xp_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE sanctuary ENABLE ROW LEVEL SECURITY;
ALTER TABLE trees ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE shop_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE premium_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE xp_boosts ENABLE ROW LEVEL SECURITY;
ALTER TABLE cosmetics ENABLE ROW LEVEL SECURITY;

-- ==================== PROFILES ====================
CREATE POLICY "users_can_read_own_profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "users_can_update_own_profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "users_can_insert_own_profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ==================== CAREERS ====================
CREATE POLICY "users_can_read_own_careers"
  ON careers FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users_can_insert_own_careers"
  ON careers FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_can_update_own_careers"
  ON careers FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_can_delete_own_careers"
  ON careers FOR DELETE
  USING (auth.uid() = user_id);

-- ==================== SUBJECTS ====================
CREATE POLICY "everyone_can_read_subjects"
  ON subjects FOR SELECT
  USING (TRUE);

CREATE POLICY "admins_can_manage_subjects"
  ON subjects FOR INSERT
  WITH CHECK (TRUE);

CREATE POLICY "admins_can_update_subjects"
  ON subjects FOR UPDATE
  USING (TRUE)
  WITH CHECK (TRUE);

-- ==================== NOTES ====================
CREATE POLICY "users_can_read_own_notes"
  ON notes FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users_can_insert_own_notes"
  ON notes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_can_update_own_notes"
  ON notes FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_can_delete_own_notes"
  ON notes FOR DELETE
  USING (auth.uid() = user_id);

-- ==================== FLASHCARDS ====================
CREATE POLICY "users_can_read_all_flashcards"
  ON flashcards FOR SELECT
  USING (TRUE);

CREATE POLICY "users_can_insert_flashcards"
  ON flashcards FOR INSERT
  WITH CHECK (TRUE);

CREATE POLICY "users_can_update_own_flashcards"
  ON flashcards FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ==================== QUIZZES ====================
CREATE POLICY "users_can_read_all_quizzes"
  ON quizzes FOR SELECT
  USING (TRUE);

CREATE POLICY "users_can_insert_quizzes"
  ON quizzes FOR INSERT
  WITH CHECK (TRUE);

CREATE POLICY "users_can_update_own_quizzes"
  ON quizzes FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ==================== STUDY_SESSIONS ====================
CREATE POLICY "users_can_read_own_sessions"
  ON study_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users_can_insert_own_sessions"
  ON study_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_can_delete_own_sessions"
  ON study_sessions FOR DELETE
  USING (auth.uid() = user_id);

-- ==================== ACHIEVEMENTS ====================
CREATE POLICY "users_can_read_own_achievements"
  ON achievements FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users_can_insert_own_achievements"
  ON achievements FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ==================== XP_HISTORY ====================
CREATE POLICY "users_can_read_own_xp"
  ON xp_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users_can_insert_own_xp"
  ON xp_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ==================== STREAKS ====================
CREATE POLICY "users_can_read_own_streaks"
  ON streaks FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users_can_update_own_streaks"
  ON streaks FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ==================== PETS ====================
CREATE POLICY "users_can_read_own_pets"
  ON pets FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users_can_update_own_pets"
  ON pets FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ==================== SANCTUARY ====================
CREATE POLICY "users_can_read_own_sanctuary"
  ON sanctuary FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users_can_update_own_sanctuary"
  ON sanctuary FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ==================== TREES ====================
CREATE POLICY "users_can_read_own_trees"
  ON trees FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users_can_update_own_trees"
  ON trees FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ==================== INVENTORY ====================
CREATE POLICY "users_can_read_own_inventory"
  ON inventory FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users_can_insert_own_inventory"
  ON inventory FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_can_update_own_inventory"
  ON inventory FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ==================== SHOP_ITEMS ====================
CREATE POLICY "everyone_can_read_shop"
  ON shop_items FOR SELECT
  USING (TRUE);

-- ==================== PURCHASES ====================
CREATE POLICY "users_can_read_own_purchases"
  ON purchases FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users_can_insert_own_purchases"
  ON purchases FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ==================== STUDY_GROUPS ====================
CREATE POLICY "members_can_read_groups"
  ON study_groups FOR SELECT
  USING (
    auth.uid() = created_by OR
    EXISTS (SELECT 1 FROM group_members WHERE group_id = id AND user_id = auth.uid())
  );

CREATE POLICY "users_can_create_groups"
  ON study_groups FOR INSERT
  WITH CHECK (auth.uid() = created_by);

-- ==================== GROUP_MEMBERS ====================
CREATE POLICY "members_can_read_group_members"
  ON group_members FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM group_members WHERE group_id = group_id AND user_id = auth.uid())
  );

-- ==================== MESSAGES ====================
CREATE POLICY "members_can_read_messages"
  ON messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM group_members gm
      JOIN study_groups sg ON sg.id = gm.group_id
      WHERE gm.group_id = messages.group_id AND gm.user_id = auth.uid()
    )
  );

CREATE POLICY "members_can_send_messages"
  ON messages FOR INSERT
  WITH CHECK (
    auth.uid() = user_id AND
    EXISTS (
      SELECT 1 FROM group_members
      WHERE group_id = messages.group_id AND user_id = auth.uid()
    )
  );

-- ==================== NOTIFICATIONS ====================
CREATE POLICY "users_can_read_own_notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users_can_update_own_notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ==================== PREMIUM_SUBSCRIPTIONS ====================
CREATE POLICY "users_can_read_own_subscription"
  ON premium_subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- ==================== SETTINGS ====================
CREATE POLICY "users_can_read_own_settings"
  ON settings FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users_can_update_own_settings"
  ON settings FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ==================== CHALLENGES ====================
CREATE POLICY "users_can_read_own_challenges"
  ON challenges FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users_can_insert_own_challenges"
  ON challenges FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_can_update_own_challenges"
  ON challenges FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ==================== XP_BOOSTS ====================
CREATE POLICY "users_can_read_own_boosts"
  ON xp_boosts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users_can_update_own_boosts"
  ON xp_boosts FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ==================== COSMETICS ====================
CREATE POLICY "users_can_read_own_cosmetics"
  ON cosmetics FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users_can_update_own_cosmetics"
  ON cosmetics FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
