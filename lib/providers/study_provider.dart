import 'package:flutter/foundation.dart';
import '../core/repositories/study_repository.dart';
import '../core/models/study_session_model.dart';

class StudyProvider extends ChangeNotifier {
  late final StudyRepository _repo;

  int _sessionsToday = 0;
  int _totalMinutesToday = 0;
  int _allTimeSessions = 0;
  int _allTimeMinutes = 0;
  int _currentStreakDays = 0;
  final List<DateTime> _studyLog = [];
  String? _userId;

  int get sessionsToday => _sessionsToday;
  int get totalMinutesToday => _totalMinutesToday;
  int get allTimeSessions => _allTimeSessions;
  int get allTimeMinutes => _allTimeMinutes;
  int get currentStreakDays => _currentStreakDays;
  List<DateTime> get studyLog => List.unmodifiable(_studyLog);

  StudyProvider() {
    _repo = StudyRepository();
  }

  Future<void> loadFromServer(String userId) async {
    _userId = userId;
    final stats = await _repo.getStats(userId);
    final sessions = await _repo.getUserSessions(userId, limit: 100);

    _sessionsToday = stats['todaySessions'] as int;
    _totalMinutesToday = stats['todayMinutes'] as int;
    _allTimeSessions = stats['allTimeSessions'] as int;
    _allTimeMinutes = stats['allTimeMinutes'] as int;

    _studyLog.clear();
    for (final s in sessions) {
      _studyLog.add(s.completedAt);
    }

    _updateStreakFromLog();
    notifyListeners();
  }

  void completeSession(int minutes) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _sessionsToday++;
    _totalMinutesToday += minutes;
    _allTimeSessions++;
    _allTimeMinutes += minutes;
    _studyLog.add(now);

    _updateStreak(today);

    if (_userId != null) {
      _repo.saveSession(StudySessionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userId!,
        sessionType: 'pomodoro',
        minutes: minutes,
        xpEarned: minutes * 5,
      ));
    }

    notifyListeners();
  }

  void _updateStreak(DateTime today) {
    if (_studyLog.isEmpty) {
      _currentStreakDays = 1;
      return;
    }

    final lastStudy = _studyLog.last;
    final lastDate = DateTime(lastStudy.year, lastStudy.month, lastStudy.day);
    final diff = today.difference(lastDate).inDays;

    if (diff <= 1) {
      _currentStreakDays = 1;
      for (int i = _studyLog.length - 2; i >= 0; i--) {
        final d1 = DateTime(_studyLog[i].year, _studyLog[i].month, _studyLog[i].day);
        final d2 = DateTime(_studyLog[i + 1].year, _studyLog[i + 1].month, _studyLog[i + 1].day);
        if (d2.difference(d1).inDays == 1) {
          _currentStreakDays++;
        } else {
          break;
        }
      }
    } else {
      _currentStreakDays = 1;
    }
  }

  void _updateStreakFromLog() {
    if (_studyLog.isEmpty) {
      _currentStreakDays = 0;
      return;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _updateStreak(today);
  }

  void resetDaily() {
    _sessionsToday = 0;
    _totalMinutesToday = 0;
    notifyListeners();
  }
}
