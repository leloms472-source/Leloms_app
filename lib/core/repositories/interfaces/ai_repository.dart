import '../../models/ai_job.dart';
import '../../models/resource.dart';
import '../../models/flashcard.dart';

abstract class IAiRepository {
  Future<AiJob> createJob(String userId, String resourceId);
  Future<AiJob?> getJobStatus(String id);
  Future<List<AiJob>> getUserJobs(String userId);

  Future<String> generateSummary(Resource resource);
  Future<List<String>> generateKeywords(Resource resource);
  Future<List<Flashcard>> generateFlashcards(Resource resource, {int count = 10});
  Future<List<Map<String, dynamic>>> generateQuiz(Resource resource, {int count = 5});
  Future<String> explain(String topic, String level);
}
