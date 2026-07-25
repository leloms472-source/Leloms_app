import '../../models/resource.dart';
import '../../models/summary.dart';
import '../../models/flashcard.dart';

abstract class IResourceRepository {
  Future<List<Resource>> getResources({String? topicId, String? authorId, bool? isPublic});
  Future<Resource?> getResource(String id);
  Future<void> createResource(Resource resource);
  Future<void> updateResource(Resource resource);
  Future<void> deleteResource(String id);

  Future<Summary?> getSummary(String resourceId);
  Future<void> saveSummary(Summary summary);

  Future<List<Flashcard>> getFlashcards(String resourceId);
  Future<void> createFlashcard(Flashcard flashcard);
  Future<void> updateFlashcard(Flashcard flashcard);
}
