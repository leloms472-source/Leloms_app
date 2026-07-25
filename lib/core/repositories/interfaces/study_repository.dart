import '../../enums/enums.dart';
import '../../models/study_plan.dart';
import '../../models/study_session.dart';

abstract class IStudyRepository {
  Future<List<StudyPlan>> getStudyPlans(String userId);
  Future<void> createStudyPlan(StudyPlan plan);

  Future<List<StudySession>> getSessions(String userId, {DateTime? from, DateTime? to});
  Future<void> logSession(StudySession session);
  Future<int> getMinutesToday(String userId);
  Future<int> getTotalMinutes(String userId);
  Future<int> getStreakDays(String userId);
}
