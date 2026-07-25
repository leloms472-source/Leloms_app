import '../../services/interfaces/supabase_service.dart';
import '../../models/comment.dart';
import '../../models/favorite.dart';
import '../../models/rating.dart';
import '../../models/help_request.dart';
import '../../enums/enums.dart';
import '../interfaces/community_repository.dart';

class CommunityRepository implements ICommunityRepository {
  final ISupabaseService _supabase;

  CommunityRepository(this._supabase);

  @override
  Future<List<Comment>> getComments(String resourceId) => _supabase.fetchComments(resourceId);

  @override
  Future<void> addComment(Comment comment) => _supabase.insertComment(comment);

  @override
  Future<bool> isFavorite(String userId, String resourceId) => _supabase.isFavorite(userId, resourceId);

  @override
  Future<void> toggleFavorite(String userId, String resourceId) async {
    final exists = await _supabase.isFavorite(userId, resourceId);
    if (exists) {
      await _supabase.removeFavorite(userId, resourceId);
    } else {
      await _supabase.addFavorite(Favorite(
        id: '${userId}_$resourceId',
        userId: userId,
        resourceId: resourceId,
      ));
    }
  }

  @override
  Future<List<String>> getUserFavorites(String userId) => _supabase.fetchFavoriteIds(userId);

  @override
  Future<double> getAverageRating(String resourceId) => _supabase.fetchAverageRating(resourceId);

  @override
  Future<int?> getUserRating(String userId, String resourceId) => _supabase.fetchUserRating(userId, resourceId);

  @override
  Future<void> rateResource(String userId, String resourceId, int value) async {
    await _supabase.upsertRating(Rating(
      id: '${userId}_$resourceId',
      userId: userId,
      resourceId: resourceId,
      value: value,
    ));
  }

  @override
  Future<List<HelpRequest>> getHelpRequests({String? subjectName}) =>
      _supabase.fetchHelpRequests(subjectName: subjectName);

  @override
  Future<void> createHelpRequest(HelpRequest request) => _supabase.insertHelpRequest(request);

  @override
  Future<void> offerHelp(String requestId, String helperId) async {
    final requests = await _supabase.fetchHelpRequests();
    final request = requests.firstWhere((r) => r.id == requestId);
    final updated = HelpRequest(
      id: request.id,
      userId: request.userId,
      title: request.title,
      description: request.description,
      subjectName: request.subjectName,
      status: HelpRequestStatus.inProgress,
      helperId: helperId,
      createdAt: request.createdAt,
    );
    await _supabase.updateHelpRequest(updated);
  }

  @override
  Future<void> resolveHelpRequest(String requestId) async {
    final requests = await _supabase.fetchHelpRequests();
    final request = requests.firstWhere((r) => r.id == requestId);
    final updated = HelpRequest(
      id: request.id,
      userId: request.userId,
      title: request.title,
      description: request.description,
      subjectName: request.subjectName,
      status: HelpRequestStatus.resolved,
      helperId: request.helperId,
      createdAt: request.createdAt,
      resolvedAt: DateTime.now(),
    );
    await _supabase.updateHelpRequest(updated);
  }
}
