-- LELOMS Storage Buckets Migration
-- Migration 003: Storage Buckets and Policies

-- ==================== CREATE BUCKETS ====================
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', TRUE) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('notes', 'notes', FALSE) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('pdfs', 'pdfs', FALSE) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('pets', 'pets', TRUE) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('backgrounds', 'backgrounds', TRUE) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('community', 'community', TRUE) ON CONFLICT DO NOTHING;

-- ==================== STORAGE POLICIES ====================
-- AVATARS (public read, authenticated write)
CREATE POLICY "anyone_can_read_avatars"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "users_can_upload_own_avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "users_can_update_own_avatar"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'avatars' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "users_can_delete_own_avatar"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'avatars' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- NOTES (private read/write for owner)
CREATE POLICY "users_can_read_own_notes_files"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'notes' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "users_can_upload_own_notes"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'notes' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "users_can_delete_own_notes"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'notes' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- PDFS (private read/write for owner)
CREATE POLICY "users_can_read_own_pdfs"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'pdfs' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "users_can_upload_own_pdfs"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'pdfs' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "users_can_delete_own_pdfs"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'pdfs' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- PETS (public read, authenticated write)
CREATE POLICY "anyone_can_read_pets"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'pets');

CREATE POLICY "admins_can_upload_pets"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'pets' AND
    auth.role() = 'authenticated'
  );

-- BACKGROUNDS (public read, authenticated write)
CREATE POLICY "anyone_can_read_backgrounds"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'backgrounds');

CREATE POLICY "admins_can_upload_backgrounds"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'backgrounds' AND
    auth.role() = 'authenticated'
  );

-- COMMUNITY (public read, authenticated write)
CREATE POLICY "anyone_can_read_community"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'community');

CREATE POLICY "users_can_upload_community_files"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'community' AND
    auth.role() = 'authenticated'
  );

CREATE POLICY "users_can_delete_own_community_files"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'community' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );
