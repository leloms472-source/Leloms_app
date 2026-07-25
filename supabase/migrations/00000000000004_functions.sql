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
