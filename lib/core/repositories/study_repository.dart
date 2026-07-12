import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';
import '../models/study_session_model.dart';

class StudyRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<void> saveSession(StudySessionModel session) async {
    await _client.from('study_sessions').insert(session.toMap());
  }

  Future<List<StudySessionModel>> getUserSessions(String userId, {int? limit}) async {
    var query = _client.from('study_sessions').select()
        .eq('user_id', userId)
        .order('completed_at', ascending: false);
    if (limit != null) query = query.limit(limit);
    final data = await query;
    return (data as List).map((d) => StudySessionModel.fromMap(d)).toList();
  }

  Future<List<StudySessionModel>> getTodaySessions(String userId) async {
    final todayStart = DateTime.now();
    final startOfDay = DateTime(todayStart.year, todayStart.month, todayStart.day);
    final data = await _client.from('study_sessions').select()
        .eq('user_id', userId)
        .gte('completed_at', startOfDay.toIso8601String())
        .order('completed_at', ascending: false);
    return (data as List).map((d) => StudySessionModel.fromMap(d)).toList();
  }

  Future<Map<String, int>> getStats(String userId) async {
    final allSessions = await _client.from('study_sessions').select()
        .eq('user_id', userId);
    final sessions = (allSessions as List);
    final today = await getTodaySessions(userId);

    int allTimeMinutes = 0;
    int todayMinutes = 0;
    for (final s in sessions) {
      allTimeMinutes += (s['minutes'] as num?)?.toInt() ?? 0;
    }
    for (final s in today) {
      todayMinutes += s.minutes;
    }

    return {
      'todaySessions': today.length,
      'todayMinutes': todayMinutes,
      'allTimeSessions': sessions.length,
      'allTimeMinutes': allTimeMinutes,
    };
  }
}
