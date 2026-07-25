-- ============================================================
-- LELOMS v16 - Migración completa
-- Ejecutar en SQL Editor de Supabase Dashboard
-- ============================================================

-- ============================================================
-- LELOMS v16 - Esquema inicial
-- Plataforma de estudio para estudiantes de ciencias de la salud
-- ============================================================

-- 1. TABLAS BASE
-- ============================================================

CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL DEFAULT '',
  username TEXT UNIQUE NOT NULL DEFAULT '',
  avatar_url TEXT,
  career_id UUID,
  university TEXT,
  study_year INT NOT NULL DEFAULT 1,
  bio TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.careers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  color TEXT,
  icon_name TEXT,
  subject_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.subjects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  career_id UUID NOT NULL REFERENCES public.careers(id) ON DELETE CASCADE,
  order_index INT NOT NULL DEFAULT 0,
  color TEXT,
  icon_name TEXT,
  topics_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  subject_id UUID NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
  order_index INT NOT NULL DEFAULT 0,
  color TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. RECURSOS
-- ============================================================

CREATE TABLE IF NOT EXISTS public.resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  topic_id UUID REFERENCES public.topics(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  pdf_url TEXT,
  is_public BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.summaries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_id UUID NOT NULL REFERENCES public.resources(id) ON DELETE CASCADE,
  short_summary TEXT NOT NULL,
  full_summary TEXT NOT NULL,
  keywords TEXT[] NOT NULL DEFAULT '{}',
  key_concepts TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.flashcards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_id UUID NOT NULL REFERENCES public.resources(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  is_learned BOOLEAN NOT NULL DEFAULT false,
  easiness_factor DOUBLE PRECISION NOT NULL DEFAULT 2.5,
  interval INT NOT NULL DEFAULT 0,
  repetitions INT NOT NULL DEFAULT 0,
  next_review_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_id UUID NOT NULL REFERENCES public.resources(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.quiz_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES public.quizzes(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  options TEXT[] NOT NULL DEFAULT '{}',
  correct_answer INT NOT NULL,
  explanation TEXT,
  order_index INT NOT NULL DEFAULT 0
);

-- 3. ESTUDIO
-- ============================================================

CREATE TABLE IF NOT EXISTS public.study_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  exam_date TIMESTAMPTZ NOT NULL,
  progress DOUBLE PRECISION NOT NULL DEFAULT 0.0,
  total_topics INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.study_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  session_type TEXT NOT NULL DEFAULT 'pomodoro',
  minutes INT NOT NULL DEFAULT 0,
  subject_name TEXT,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. COMUNIDAD
-- ============================================================

CREATE TABLE IF NOT EXISTS public.comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  resource_id UUID NOT NULL REFERENCES public.resources(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  resource_id UUID NOT NULL REFERENCES public.resources(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, resource_id)
);

CREATE TABLE IF NOT EXISTS public.ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  resource_id UUID NOT NULL REFERENCES public.resources(id) ON DELETE CASCADE,
  value INT NOT NULL CHECK (value >= 1 AND value <= 5),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, resource_id)
);

CREATE TABLE IF NOT EXISTS public.help_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  subject_name TEXT,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'inProgress', 'resolved')),
  helper_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  resolved_at TIMESTAMPTZ
);

-- 5. IA
-- ============================================================

CREATE TABLE IF NOT EXISTS public.ai_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  resource_id UUID NOT NULL REFERENCES public.resources(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  result_url TEXT,
  error_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ
);

-- 6. REPUTACIÓN ACADÉMICA
-- ============================================================

CREATE TABLE IF NOT EXISTS public.academic_reputations (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  useful_resources INT NOT NULL DEFAULT 0,
  students_helped INT NOT NULL DEFAULT 0,
  positive_ratings INT NOT NULL DEFAULT 0,
  accepted_contributions INT NOT NULL DEFAULT 0,
  overall_score DOUBLE PRECISION NOT NULL DEFAULT 0.0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 7. ÍNDICES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_subjects_career_id ON public.subjects(career_id);
CREATE INDEX IF NOT EXISTS idx_topics_subject_id ON public.topics(subject_id);
CREATE INDEX IF NOT EXISTS idx_resources_author_id ON public.resources(author_id);
CREATE INDEX IF NOT EXISTS idx_resources_topic_id ON public.resources(topic_id);
CREATE INDEX IF NOT EXISTS idx_resources_is_public ON public.resources(is_public);
CREATE INDEX IF NOT EXISTS idx_summaries_resource_id ON public.summaries(resource_id);
CREATE INDEX IF NOT EXISTS idx_flashcards_resource_id ON public.flashcards(resource_id);
CREATE INDEX IF NOT EXISTS idx_flashcards_next_review ON public.flashcards(next_review_date);
CREATE INDEX IF NOT EXISTS idx_quiz_questions_quiz_id ON public.quiz_questions(quiz_id);
CREATE INDEX IF NOT EXISTS idx_study_sessions_user_id ON public.study_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_study_sessions_completed_at ON public.study_sessions(completed_at);
CREATE INDEX IF NOT EXISTS idx_study_plans_user_id ON public.study_plans(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_resource_id ON public.comments(resource_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON public.favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_resource_id ON public.favorites(resource_id);
CREATE INDEX IF NOT EXISTS idx_ratings_resource_id ON public.ratings(resource_id);
CREATE INDEX IF NOT EXISTS idx_help_requests_status ON public.help_requests(status);
CREATE INDEX IF NOT EXISTS idx_ai_jobs_user_id ON public.ai_jobs(user_id);

-- 8. FUNCIONES Y TRIGGERS
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, username)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''),
    COALESCE(NEW.raw_user_meta_data ->> 'username', '')
  );
  INSERT INTO public.academic_reputations (user_id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER set_academic_reputations_updated_at
  BEFORE UPDATE ON public.academic_reputations
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at();

-- ============================================================
-- LELOMS v16 - RLS Policies
-- ============================================================

-- 1. PROFILES
-- ============================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiles son públicos para lectura"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Usuarios pueden actualizar su propio perfil"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- 2. CAREERS
-- ============================================================
ALTER TABLE public.careers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Carreras son públicas"
  ON public.careers FOR SELECT
  USING (true);

-- 3. SUBJECTS
-- ============================================================
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Materias son públicas"
  ON public.subjects FOR SELECT
  USING (true);

-- 4. TOPICS
-- ============================================================
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Temas son públicos"
  ON public.topics FOR SELECT
  USING (true);

-- 5. RESOURCES
-- ============================================================
ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Recursos públicos visibles para todos"
  ON public.resources FOR SELECT
  USING (is_public = true OR auth.uid() = author_id);

CREATE POLICY "Usuarios pueden crear recursos"
  ON public.resources FOR INSERT
  WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Autor puede actualizar su recurso"
  ON public.resources FOR UPDATE
  USING (auth.uid() = author_id);

CREATE POLICY "Autor puede eliminar su recurso"
  ON public.resources FOR DELETE
  USING (auth.uid() = author_id);

-- 6. SUMMARIES
-- ============================================================
ALTER TABLE public.summaries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Resúmenes son públicos"
  ON public.summaries FOR SELECT
  USING (true);

CREATE POLICY "Usuarios pueden crear resúmenes"
  ON public.summaries FOR INSERT
  WITH CHECK (auth.uid() IN (SELECT author_id FROM public.resources WHERE id = resource_id));

-- 7. FLASHCARDS
-- ============================================================
ALTER TABLE public.flashcards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Flashcards son públicos"
  ON public.flashcards FOR SELECT
  USING (true);

CREATE POLICY "Usuarios pueden crear flashcards"
  ON public.flashcards FOR INSERT
  WITH CHECK (auth.uid() IN (SELECT author_id FROM public.resources WHERE id = resource_id));

CREATE POLICY "Usuarios pueden actualizar flashcards"
  ON public.flashcards FOR UPDATE
  USING (auth.uid() IN (SELECT author_id FROM public.resources WHERE id = resource_id));

-- 8. QUIZZES
-- ============================================================
ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Quizzes son públicos"
  ON public.quizzes FOR SELECT
  USING (true);

CREATE POLICY "Usuarios pueden crear quizzes"
  ON public.quizzes FOR INSERT
  WITH CHECK (auth.uid() IN (SELECT author_id FROM public.resources WHERE id = resource_id));

-- 9. QUIZ QUESTIONS
-- ============================================================
ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Preguntas de quiz son públicas"
  ON public.quiz_questions FOR SELECT
  USING (true);

CREATE POLICY "Usuarios pueden crear preguntas"
  ON public.quiz_questions FOR INSERT
  WITH CHECK (auth.uid() IN (
    SELECT r.author_id FROM public.quizzes q
    JOIN public.resources r ON r.id = q.resource_id
    WHERE q.id = quiz_id
  ));

-- 10. STUDY PLANS
-- ============================================================
ALTER TABLE public.study_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuario ve sus planes"
  ON public.study_plans FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Usuario crea sus planes"
  ON public.study_plans FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuario actualiza sus planes"
  ON public.study_plans FOR UPDATE
  USING (auth.uid() = user_id);

-- 11. STUDY SESSIONS
-- ============================================================
ALTER TABLE public.study_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuario ve sus sesiones"
  ON public.study_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Usuario crea sus sesiones"
  ON public.study_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 12. COMMENTS
-- ============================================================
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Comentarios son públicos"
  ON public.comments FOR SELECT
  USING (true);

CREATE POLICY "Usuario autenticado puede comentar"
  ON public.comments FOR INSERT
  WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Autor puede editar su comentario"
  ON public.comments FOR UPDATE
  USING (auth.uid() = author_id);

-- 13. FAVORITES
-- ============================================================
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuario ve sus favoritos"
  ON public.favorites FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Usuario agrega favoritos"
  ON public.favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuario elimina sus favoritos"
  ON public.favorites FOR DELETE
  USING (auth.uid() = user_id);

-- 14. RATINGS
-- ============================================================
ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Valoraciones son públicas"
  ON public.ratings FOR SELECT
  USING (true);

CREATE POLICY "Usuario autenticado puede valorar"
  ON public.ratings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuario puede actualizar su valoración"
  ON public.ratings FOR UPDATE
  USING (auth.uid() = user_id);

-- 15. HELP REQUESTS
-- ============================================================
ALTER TABLE public.help_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Solicitudes de ayuda son públicas"
  ON public.help_requests FOR SELECT
  USING (true);

CREATE POLICY "Usuario crea solicitudes"
  ON public.help_requests FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Autor o helper actualizan solicitud"
  ON public.help_requests FOR UPDATE
  USING (auth.uid() = user_id OR auth.uid() = helper_id);

-- 16. AI JOBS
-- ============================================================
ALTER TABLE public.ai_jobs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuario ve sus jobs"
  ON public.ai_jobs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Usuario crea jobs"
  ON public.ai_jobs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 17. ACADEMIC REPUTATIONS
-- ============================================================
ALTER TABLE public.academic_reputations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Reputaciones son públicas"
  ON public.academic_reputations FOR SELECT
  USING (true);

CREATE POLICY "Usuario actualiza su reputación"
  ON public.academic_reputations FOR UPDATE
  USING (auth.uid() = user_id);

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

-- ============================================================
-- LELOMS v16 - Funciones SQL
-- ============================================================

CREATE OR REPLACE FUNCTION public.get_total_minutes_today(p_user_id UUID, p_start TIMESTAMPTZ)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
  total INT;
BEGIN
  SELECT COALESCE(SUM(minutes), 0) INTO total
  FROM public.study_sessions
  WHERE user_id = p_user_id AND completed_at >= p_start;
  RETURN total;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_average_rating(p_resource_id UUID)
RETURNS DOUBLE PRECISION
LANGUAGE plpgsql
AS $$
DECLARE
  avg_val DOUBLE PRECISION;
BEGIN
  SELECT COALESCE(AVG(value), 0.0) INTO avg_val
  FROM public.ratings
  WHERE resource_id = p_resource_id;
  RETURN avg_val;
END;
$$;

-- ============================================================
-- LELOMS v16 - Seed data
-- ============================================================

INSERT INTO public.careers (id, name, description, color, icon_name, subject_count) VALUES
  ('c1000000-0000-0000-0000-000000000001', 'Medicina', 'Carrera de grado en Ciencias Médicas', '#6366F1', 'medical_services', 12),
  ('c1000000-0000-0000-0000-000000000002', 'Enfermería', 'Licenciatura en Enfermería', '#EC4899', 'local_hospital', 8),
  ('c1000000-0000-0000-0000-000000000003', 'Bioquímica', 'Licenciatura en Bioquímica', '#10B981', 'biotech', 6),
  ('c1000000-0000-0000-0000-000000000004', 'Odontología', 'Carrera de grado en Odontología', '#F97316', 'face', 10)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.subjects (id, name, description, career_id, order_index, color, icon_name, topics_count) VALUES
  ('s1000000-0000-0000-0000-000000000001', 'Anatomía', 'Estudio de la estructura del cuerpo humano', 'c1000000-0000-0000-0000-000000000001', 1, '#EF4444', 'biotech', 8),
  ('s1000000-0000-0000-0000-000000000002', 'Fisiología', 'Estudio de las funciones del cuerpo humano', 'c1000000-0000-0000-0000-000000000001', 2, '#3B82F6', 'monitor_heart', 6),
  ('s1000000-0000-0000-0000-000000000003', 'Bioquímica', 'Estudio de los procesos químicos en organismos vivos', 'c1000000-0000-0000-0000-000000000001', 3, '#10B981', 'science', 7),
  ('s1000000-0000-0000-0000-000000000004', 'Farmacología', 'Estudio de los fármacos y su acción en el organismo', 'c1000000-0000-0000-0000-000000000001', 4, '#F59E0B', 'medication', 5),
  ('s1000000-0000-0000-0000-000000000005', 'Histología', 'Estudio de los tejidos del cuerpo', 'c1000000-0000-0000-0000-000000000001', 5, '#8B5CF6', 'biotech', 4)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.topics (id, name, subject_id, order_index) VALUES
  ('t1000000-0000-0000-0000-000000000001', 'Introducción a la Anatomía', 's1000000-0000-0000-0000-000000000001', 1),
  ('t1000000-0000-0000-0000-000000000002', 'Sistema Esquelético', 's1000000-0000-0000-0000-000000000001', 2),
  ('t1000000-0000-0000-0000-000000000003', 'Sistema Muscular', 's1000000-0000-0000-0000-000000000001', 3),
  ('t1000000-0000-0000-0000-000000000004', 'Sistema Nervioso', 's1000000-0000-0000-0000-000000000001', 4),
  ('t1000000-0000-0000-0000-000000000005', 'Sistema Cardiovascular', 's1000000-0000-0000-0000-000000000001', 5),
  ('t1000000-0000-0000-0000-000000000006', 'Introducción a la Fisiología', 's1000000-0000-0000-0000-000000000002', 1),
  ('t1000000-0000-0000-0000-000000000007', 'Homeostasis', 's1000000-0000-0000-0000-000000000002', 2),
  ('t1000000-0000-0000-0000-000000000008', 'Potencial de Membrana', 's1000000-0000-0000-0000-000000000002', 3)
ON CONFLICT (id) DO NOTHING;
