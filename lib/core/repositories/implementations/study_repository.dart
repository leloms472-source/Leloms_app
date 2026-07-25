import '../../services/interfaces/supabase_service.dart';
import '../../enums/enums.dart';
import '../../models/study_plan.dart';
import '../../models/study_session.dart';
import '../interfaces/study_repository.dart';

class StudyRepository implements IStudyRepository {
  final ISupabaseService _supabase;

  StudyRepository(this._supabase);

  @override
  Future<List<StudyPlan>> getStudyPlans(String userId) => _supabase.fetchStudyPlans(userId);

  @override
  Future<void> createStudyPlan(StudyPlan plan) => _supabase.insertStudyPlan(plan);

  @override
  Future<List<StudySession>> getSessions(String userId, {DateTime? from, DateTime? to}) =>
      _supabase.fetchStudySessions(userId, from: from, to: to);

  @override
  Future<void> logSession(StudySession session) => _supabase.insertStudySession(session);

  @override
  Future<int> getMinutesToday(String userId) => _supabase.fetchTotalMinutesToday(userId);

  @override
  Future<int> getTotalMinutes(String userId) async {
    final sessions = await _supabase.fetchStudySessions(userId);
    int total = 0;
    for (final s in sessions) {
      total += s.minutes;
    }
    return total;
  }

  @override
  Future<int> getStreakDays(String userId) async {
    final sessions = await _supabase.fetchStudySessions(userId);
    if (sessions.isEmpty) return 0;
    final dates = sessions.map((s) => DateTime(s.completedAt.year, s.completedAt.month, s.completedAt.day)).toSet().toList()..sort();
    int streak = 1;
    for (int i = dates.length - 2; i >= 0; i--) {
      if (dates[i + 1].difference(dates[i]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
