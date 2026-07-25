import '../../models/comment.dart';
import '../../models/favorite.dart';
import '../../models/rating.dart';
import '../../models/help_request.dart';

abstract class ICommunityRepository {
  Future<List<Comment>> getComments(String resourceId);
  Future<void> addComment(Comment comment);

  Future<bool> isFavorite(String userId, String resourceId);
  Future<void> toggleFavorite(String userId, String resourceId);
  Future<List<String>> getUserFavorites(String userId);

  Future<double> getAverageRating(String resourceId);
  Future<int?> getUserRating(String userId, String resourceId);
  Future<void> rateResource(String userId, String resourceId, int value);

  Future<List<HelpRequest>> getHelpRequests({String? subjectName});
  Future<void> createHelpRequest(HelpRequest request);
  Future<void> offerHelp(String requestId, String helperId);
  Future<void> resolveHelpRequest(String requestId);
}
