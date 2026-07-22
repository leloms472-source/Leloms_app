import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;
import '../core/supabase/supabase_client.dart';
import '../models/subject.dart';
import '../models/quiz.dart';
import '../models/flashcard.dart';
import '../models/summary.dart';

class SupabaseService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // Subjects
  Future<List<Subject>> getSubjects() async {
    final data = await _client.from('subjects').select().order('name');
    return (data as List).map((d) => Subject.fromMap(d['id'] as String, d)).toList();
  }

  // Quizzes
  Future<List<Quiz>> getQuizzes({String? subject}) async {
    var query = _client.from('quizzes').select();
    if (subject != null) query = query.eq('subject', subject);
    final data = await query.order('created_at', ascending: false);
    return (data as List).map((d) => Quiz.fromMap(d['id'] as String, d as Map<String, dynamic>)).toList();
  }

  // Flashcards
  Future<List<Flashcard>> getFlashcards({String? subject}) async {
    var query = _client.from('flashcards').select();
    if (subject != null) query = query.eq('subject', subject);
    final data = await query.order('created_at', ascending: false);
    return (data as List).map((d) => Flashcard.fromMap(d['id'] as String, d as Map<String, dynamic>)).toList();
  }

  // Summaries
  Future<List<Summary>> getSummaries() async {
    final data = await _client.from('summaries').select().order('votes', ascending: false);
    return (data as List).map((d) => Summary.fromMap(d['id'] as String, d)).toList();
  }

  Future<void> voteSummary(String summaryId, int newVotes) async {
    await _client.from('summaries').update({'votes': newVotes}).eq('id', summaryId);
  }
}
