import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';
import '../models/flashcard_model.dart';
import '../models/quiz_model.dart';
import '../models/subject_model.dart';

class ContentRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  // Subjects
  Future<List<SubjectModel>> getSubjects() async {
    final data = await _client.from('subjects').select().order('name');
    return (data as List).map((d) => SubjectModel.fromMap(d['id'] as String, d)).toList();
  }

  Future<void> addSubject(SubjectModel subject) async {
    await _client.from('subjects').insert(subject.toMap());
  }

  // Quizzes
  Future<List<QuizModel>> getQuizzes({String? subject}) async {
    var query = _client.from('quizzes').select() as PostgrestFilterBuilder;
    if (subject != null) query = query.eq('subject', subject);
    final data = await query.order('created_at', ascending: false);
    return (data as List).map((d) => QuizModel.fromMap(d['id'] as String, d)).toList();
  }

  Future<void> addQuiz(QuizModel quiz) async {
    final map = quiz.toMap();
    map['user_id'] = quiz.userId;
    await _client.from('quizzes').insert(map);
  }

  // Flashcards
  Future<List<FlashcardModel>> getFlashcards({String? subject}) async {
    var query = _client.from('flashcards').select() as PostgrestFilterBuilder;
    if (subject != null) query = query.eq('subject', subject);
    final data = await query.order('created_at', ascending: false);
    return (data as List).map((d) => FlashcardModel.fromMap(d['id'] as String, d)).toList();
  }

  Future<void> addFlashcard(FlashcardModel flashcard) async {
    final map = flashcard.toMap();
    map['user_id'] = flashcard.userId;
    await _client.from('flashcards').insert(map);
  }

  Future<void> updateFlashcard(String id, Map<String, dynamic> updates) async {
    await _client.from('flashcards').update(updates).eq('id', id);
  }
}
