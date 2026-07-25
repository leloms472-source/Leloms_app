-- ============================================================
-- LELOMS v16 - Storage buckets
-- ============================================================

INSERT INTO storage.buckets (id, name, public)
VALUES
  ('avatars', 'avatars', true),
  ('pdfs', 'pdfs', false),
  ('summaries', 'summaries', false)
ON CONFLICT (id) DO NOTHING;

-- AVATARS (público)
CREATE POLICY "Avatars públicos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Usuarios pueden subir avatars"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden eliminar sus avatars"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'avatars' AND auth.uid() = owner);

-- PDFS (solo dueño)
CREATE POLICY "Dueño ve sus PDFs"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'pdfs' AND auth.uid() = owner);

CREATE POLICY "Usuarios pueden subir PDFs"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'pdfs' AND auth.role() = 'authenticated');

CREATE POLICY "Dueño elimina sus PDFs"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'pdfs' AND auth.uid() = owner);

-- SUMMARIES (solo dueño)
CREATE POLICY "Dueño ve sus resúmenes"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'summaries' AND auth.uid() = owner);

CREATE POLICY "Usuarios pueden subir resúmenes"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'summaries' AND auth.role() = 'authenticated');

CREATE POLICY "Dueño elimina sus resúmenes"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'summaries' AND auth.uid() = owner);
