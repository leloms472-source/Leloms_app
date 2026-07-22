import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';
import '../models/career_model.dart';
import '../models/topic_model.dart';
import '../models/subject_model.dart';

class AcademicRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<List<Career>> getCareers() async {
    final data = await _client.from('careers').select().order('name');
    return (data as List).map((d) => Career.fromMap(d['id'] as String, d)).toList();
  }

  Future<void> addCareer(Career career) async {
    await _client.from('careers').insert(career.toMap());
  }

  Future<List<Subject>> getSubjectsByCareer(String careerId) async {
    final data = await _client
        .from('subjects')
        .select()
        .eq('career_id', careerId)
        .order('name');
    return (data as List).map((d) => Subject.fromMap(d['id'] as String, d)).toList();
  }

  Future<List<Topic>> getTopics(String subjectId) async {
    final data = await _client
        .from('topics')
        .select()
        .eq('subject_id', subjectId)
        .order('order_index');
    return (data as List).map((d) => Topic.fromMap(d['id'] as String, d)).toList();
  }

  Future<void> addTopic(Topic topic) async {
    await _client.from('topics').insert(topic.toMap());
  }
}
