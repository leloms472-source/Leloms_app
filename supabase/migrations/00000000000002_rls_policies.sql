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
