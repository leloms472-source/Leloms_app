import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../core/supabase/supabase_client.dart';
import '../../core/services/interfaces/supabase_service.dart';
import '../../core/models/user.dart' as app;
import '../../core/models/career.dart';
import '../../core/models/subject.dart';
import '../../core/models/topic.dart';
import '../../core/models/resource.dart';
import '../../core/models/summary.dart';
import '../../core/models/flashcard.dart';
import '../../core/models/study_plan.dart';
import '../../core/models/study_session.dart';
import '../../core/models/comment.dart';
import '../../core/models/favorite.dart';
import '../../core/models/rating.dart';
import '../../core/models/help_request.dart';
import '../../core/models/ai_job.dart';
import '../../core/models/academic_reputation.dart';
import '../../core/enums/enums.dart';

class SupabaseServiceImpl implements ISupabaseService {
  SupabaseClient get _client => SupabaseConfig.client;

  @override
  Future<void> initialize() async {
    await SupabaseConfig.initialize();
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Future<app.User?> fetchUser(String id) async {
    final response = await _client.from('profiles').select().eq('id', id).single();
    return app.User.fromMap(response);
  }

  @override
  Future<void> upsertUser(app.User user) async {
    await _client.from('profiles').upsert(user.toMap());
  }

  @override
  Future<List<Career>> fetchCareers() async {
    final response = await _client.from('careers').select();
    return response.map((e) => Career.fromMap(e)).toList();
  }

  @override
  Future<List<Subject>> fetchSubjects(String careerId) async {
    final response = await _client.from('subjects').select().eq('career_id', careerId).order('order_index');
    return response.map((e) => Subject.fromMap(e)).toList();
  }

  @override
  Future<List<Topic>> fetchTopics(String subjectId) async {
    final response = await _client.from('topics').select().eq('subject_id', subjectId).order('order_index');
    return response.map((e) => Topic.fromMap(e)).toList();
  }

  @override
  Future<List<Resource>> fetchResources({String? topicId, String? authorId, bool? isPublic}) async {
    var query = _client.from('resources').select();
    if (topicId != null) query = query.eq('topic_id', topicId);
    if (authorId != null) query = query.eq('author_id', authorId);
    if (isPublic != null) query = query.eq('is_public', isPublic);
    final response = await query.order('created_at', ascending: false);
    return response.map((e) => Resource.fromMap(e)).toList();
  }

  @override
  Future<Resource?> fetchResource(String id) async {
    final response = await _client.from('resources').select().eq('id', id).single();
    return Resource.fromMap(response);
  }

  @override
  Future<void> insertResource(Resource resource) async {
    await _client.from('resources').insert(resource.toMap());
  }

  @override
  Future<void> updateResource(Resource resource) async {
    await _client.from('resources').update(resource.toMap()).eq('id', resource.id);
  }

  @override
  Future<void> deleteResource(String id) async {
    await _client.from('resources').delete().eq('id', id);
  }

  @override
  Future<Summary?> fetchSummary(String resourceId) async {
    final response = await _client.from('summaries').select().eq('resource_id', resourceId).maybeSingle();
    if (response == null) return null;
    return Summary.fromMap(response);
  }

  @override
  Future<void> insertSummary(Summary summary) async {
    await _client.from('summaries').insert(summary.toMap());
  }

  @override
  Future<List<Flashcard>> fetchFlashcards(String resourceId) async {
    final response = await _client.from('flashcards').select().eq('resource_id', resourceId);
    return response.map((e) => Flashcard.fromMap(e)).toList();
  }

  @override
  Future<void> insertFlashcard(Flashcard flashcard) async {
    await _client.from('flashcards').insert(flashcard.toMap());
  }

  @override
  Future<void> updateFlashcard(Flashcard flashcard) async {
    await _client.from('flashcards').update(flashcard.toMap()).eq('id', flashcard.id);
  }

  @override
  Future<List<dynamic>> fetchQuizzes(String resourceId) async {
    final response = await _client.from('quizzes').select('*, quiz_questions(*)').eq('resource_id', resourceId);
    return response;
  }

  @override
  Future<void> insertQuiz(Map<String, dynamic> quiz) async {
    await _client.from('quizzes').insert(quiz);
  }

  @override
  Future<void> insertQuizQuestion(Map<String, dynamic> question) async {
    await _client.from('quiz_questions').insert(question);
  }

  @override
  Future<List<StudyPlan>> fetchStudyPlans(String userId) async {
    final response = await _client.from('study_plans').select().eq('user_id', userId).order('exam_date');
    return response.map((e) => StudyPlan.fromMap(e)).toList();
  }

  @override
  Future<void> insertStudyPlan(StudyPlan plan) async {
    await _client.from('study_plans').insert(plan.toMap());
  }

  @override
  Future<List<StudySession>> fetchStudySessions(String userId, {DateTime? from, DateTime? to}) async {
    var query = _client.from('study_sessions').select().eq('user_id', userId);
    if (from != null) query = query.gte('completed_at', from.toIso8601String());
    if (to != null) query = query.lte('completed_at', to.toIso8601String());
    final response = await query.order('completed_at', ascending: false);
    return response.map((e) => StudySession.fromMap(e)).toList();
  }

  @override
  Future<void> insertStudySession(StudySession session) async {
    await _client.from('study_sessions').insert(session.toMap());
  }

  @override
  Future<int> fetchTotalMinutesToday(String userId) async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    try {
      final response = await _client.rpc('get_total_minutes_today', params: {
        'p_user_id': userId,
        'p_start': start.toIso8601String(),
      });
      return (response as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<List<Comment>> fetchComments(String resourceId) async {
    final response = await _client.from('comments').select().eq('resource_id', resourceId).order('created_at');
    return response.map((e) => Comment.fromMap(e)).toList();
  }

  @override
  Future<void> insertComment(Comment comment) async {
    await _client.from('comments').insert(comment.toMap());
  }

  @override
  Future<bool> isFavorite(String userId, String resourceId) async {
    final response = await _client.from('favorites').select().eq('user_id', userId).eq('resource_id', resourceId).maybeSingle();
    return response != null;
  }

  @override
  Future<void> addFavorite(Favorite favorite) async {
    await _client.from('favorites').insert(favorite.toMap());
  }

  @override
  Future<void> removeFavorite(String userId, String resourceId) async {
    await _client.from('favorites').delete().eq('user_id', userId).eq('resource_id', resourceId);
  }

  @override
  Future<List<String>> fetchFavoriteIds(String userId) async {
    final response = await _client.from('favorites').select('resource_id').eq('user_id', userId);
    return response.map((e) => e['resource_id'] as String).toList();
  }

  @override
  Future<double> fetchAverageRating(String resourceId) async {
    try {
      final response = await _client.rpc('get_average_rating', params: {'p_resource_id': resourceId});
      return ((response as num?)?.toDouble() ?? 0.0);
    } catch (_) {
      return 0.0;
    }
  }

  @override
  Future<void> upsertRating(Rating rating) async {
    await _client.from('ratings').upsert(rating.toMap(), onConflict: 'user_id, resource_id');
  }

  @override
  Future<int?> fetchUserRating(String userId, String resourceId) async {
    final response = await _client.from('ratings').select('value').eq('user_id', userId).eq('resource_id', resourceId).maybeSingle();
    return response?['value'] as int?;
  }

  @override
  Future<List<HelpRequest>> fetchHelpRequests({String? subjectName, HelpRequestStatus? status}) async {
    var query = _client.from('help_requests').select();
    if (subjectName != null) query = query.eq('subject_name', subjectName);
    if (status != null) query = query.eq('status', status.name);
    final response = await query.order('created_at', ascending: false);
    return response.map((e) => HelpRequest.fromMap(e)).toList();
  }

  @override
  Future<void> insertHelpRequest(HelpRequest request) async {
    await _client.from('help_requests').insert(request.toMap());
  }

  @override
  Future<void> updateHelpRequest(HelpRequest request) async {
    await _client.from('help_requests').update(request.toMap()).eq('id', request.id);
  }

  @override
  Future<void> insertAiJob(AiJob job) async {
    await _client.from('ai_jobs').insert(job.toMap());
  }

  @override
  Future<AiJob?> fetchAiJob(String id) async {
    final response = await _client.from('ai_jobs').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return AiJob.fromMap(response);
  }

  @override
  Future<List<AiJob>> fetchAiJobsByUser(String userId) async {
    final response = await _client.from('ai_jobs').select().eq('user_id', userId).order('created_at', ascending: false);
    return response.map((e) => AiJob.fromMap(e)).toList();
  }

  @override
  Future<AcademicReputation?> fetchAcademicReputation(String userId) async {
    final response = await _client.from('academic_reputations').select().eq('user_id', userId).maybeSingle();
    if (response == null) return null;
    return AcademicReputation.fromMap(response);
  }

  @override
  Future<void> upsertAcademicReputation(AcademicReputation rep) async {
    await _client.from('academic_reputations').upsert(rep.toMap());
  }

  @override
  Future<List<app.User>> fetchTopContributors({int limit = 10}) async {
    final response = await _client
        .from('academic_reputations')
        .select('user_id, overall_score, profiles:user_id(*)')
        .order('overall_score', ascending: false)
        .limit(limit);
    return response.map((e) => app.User.fromMap(e['profiles'] as Map<String, dynamic>)).toList();
  }
}
