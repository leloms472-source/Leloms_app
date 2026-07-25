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
