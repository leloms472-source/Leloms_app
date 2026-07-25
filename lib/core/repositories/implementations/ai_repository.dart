import '../../services/interfaces/supabase_service.dart';
import '../../services/interfaces/ai_service.dart';
import '../../models/ai_job.dart';
import '../../models/resource.dart';
import '../../models/flashcard.dart';
import '../interfaces/ai_repository.dart';

class AiRepository implements IAiRepository {
  final ISupabaseService _supabase;
  final IAiService _ai;

  AiRepository(this._supabase, this._ai);

  @override
  Future<AiJob> createJob(String userId, String resourceId) async {
    final job = AiJob(id: DateTime.now().millisecondsSinceEpoch.toString(), userId: userId, resourceId: resourceId);
    await _supabase.insertAiJob(job);
    return job;
  }

  @override
  Future<AiJob?> getJobStatus(String id) => _supabase.fetchAiJob(id);

  @override
  Future<List<AiJob>> getUserJobs(String userId) => _supabase.fetchAiJobsByUser(userId);

  @override
  Future<String> generateSummary(Resource resource) => _ai.generateSummary(resource.description ?? resource.title);

  @override
  Future<List<String>> generateKeywords(Resource resource) => _ai.generateKeywords(resource.description ?? resource.title);

  @override
  Future<List<Flashcard>> generateFlashcards(Resource resource, {int count = 10}) async {
    final raw = await _ai.generateFlashcards(resource.description ?? resource.title, count: count);
    return raw.asMap().entries.map((e) {
      return Flashcard(
        id: '${DateTime.now().millisecondsSinceEpoch}_${e.key}',
        resourceId: resource.id,
        question: e.value['question'] ?? '',
        answer: e.value['answer'] ?? '',
      );
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> generateQuiz(Resource resource, {int count = 5}) =>
      _ai.generateQuiz(resource.description ?? resource.title, count: count);

  @override
  Future<String> explain(String topic, String level) => _ai.explain(topic, level);
}
