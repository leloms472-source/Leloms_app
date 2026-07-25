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
