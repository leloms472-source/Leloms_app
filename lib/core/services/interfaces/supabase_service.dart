import '../../models/user.dart';
import '../../models/career.dart';
import '../../models/subject.dart';
import '../../models/topic.dart';
import '../../models/resource.dart';
import '../../models/summary.dart';
import '../../models/flashcard.dart';
import '../../models/study_plan.dart';
import '../../models/study_session.dart';
import '../../models/comment.dart';
import '../../models/favorite.dart';
import '../../models/rating.dart';
import '../../models/help_request.dart';
import '../../models/ai_job.dart';
import '../../models/academic_reputation.dart';
import '../../enums/enums.dart';

abstract class ISupabaseService {
  Future<void> initialize();
  Future<void> signOut();
  String? get currentUserId;

  Future<User?> fetchUser(String id);
  Future<void> upsertUser(User user);

  Future<List<Career>> fetchCareers();
  Future<List<Subject>> fetchSubjects(String careerId);
  Future<List<Topic>> fetchTopics(String subjectId);

  Future<List<Resource>> fetchResources({String? topicId, String? authorId, bool? isPublic});
  Future<Resource?> fetchResource(String id);
  Future<void> insertResource(Resource resource);
  Future<void> updateResource(Resource resource);
  Future<void> deleteResource(String id);

  Future<Summary?> fetchSummary(String resourceId);
  Future<void> insertSummary(Summary summary);

  Future<List<Flashcard>> fetchFlashcards(String resourceId);
  Future<void> insertFlashcard(Flashcard flashcard);
  Future<void> updateFlashcard(Flashcard flashcard);

  Future<List<dynamic>> fetchQuizzes(String resourceId);
  Future<void> insertQuiz(Map<String, dynamic> quiz);
  Future<void> insertQuizQuestion(Map<String, dynamic> question);

  Future<List<StudyPlan>> fetchStudyPlans(String userId);
  Future<void> insertStudyPlan(StudyPlan plan);

  Future<List<StudySession>> fetchStudySessions(String userId, {DateTime? from, DateTime? to});
  Future<void> insertStudySession(StudySession session);
  Future<int> fetchTotalMinutesToday(String userId);

  Future<List<Comment>> fetchComments(String resourceId);
  Future<void> insertComment(Comment comment);

  Future<bool> isFavorite(String userId, String resourceId);
  Future<void> addFavorite(Favorite favorite);
  Future<void> removeFavorite(String userId, String resourceId);
  Future<List<String>> fetchFavoriteIds(String userId);

  Future<double> fetchAverageRating(String resourceId);
  Future<void> upsertRating(Rating rating);
  Future<int?> fetchUserRating(String userId, String resourceId);

  Future<List<HelpRequest>> fetchHelpRequests({String? subjectName, HelpRequestStatus? status});
  Future<void> insertHelpRequest(HelpRequest request);
  Future<void> updateHelpRequest(HelpRequest request);

  Future<void> insertAiJob(AiJob job);
  Future<AiJob?> fetchAiJob(String id);
  Future<List<AiJob>> fetchAiJobsByUser(String userId);

  Future<AcademicReputation?> fetchAcademicReputation(String userId);
  Future<void> upsertAcademicReputation(AcademicReputation rep);

  Future<List<User>> fetchTopContributors({int limit = 10});
}
