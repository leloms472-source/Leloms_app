import '../../services/interfaces/supabase_service.dart';
import '../../models/resource.dart';
import '../../models/summary.dart';
import '../../models/flashcard.dart';
import '../interfaces/resource_repository.dart';

class ResourceRepository implements IResourceRepository {
  final ISupabaseService _supabase;

  ResourceRepository(this._supabase);

  @override
  Future<List<Resource>> getResources({String? topicId, String? authorId, bool? isPublic}) =>
      _supabase.fetchResources(topicId: topicId, authorId: authorId, isPublic: isPublic);

  @override
  Future<Resource?> getResource(String id) => _supabase.fetchResource(id);

  @override
  Future<void> createResource(Resource resource) => _supabase.insertResource(resource);

  @override
  Future<void> updateResource(Resource resource) => _supabase.updateResource(resource);

  @override
  Future<void> deleteResource(String id) => _supabase.deleteResource(id);

  @override
  Future<Summary?> getSummary(String resourceId) => _supabase.fetchSummary(resourceId);

  @override
  Future<void> saveSummary(Summary summary) => _supabase.insertSummary(summary);

  @override
  Future<List<Flashcard>> getFlashcards(String resourceId) => _supabase.fetchFlashcards(resourceId);

  @override
  Future<void> createFlashcard(Flashcard flashcard) => _supabase.insertFlashcard(flashcard);

  @override
  Future<void> updateFlashcard(Flashcard flashcard) => _supabase.updateFlashcard(flashcard);
}
