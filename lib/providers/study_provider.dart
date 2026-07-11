import 'package:flutter/foundation.dart';

class StudyProvider extends ChangeNotifier {
  int _sessionsToday = 0;
  int _totalMinutesToday = 0;
  int _allTimeSessions = 0;
  int _allTimeMinutes = 0;
  int _currentStreakDays = 0;
  List<DateTime> _studyLog = [];

  int get sessionsToday => _sessionsToday;
  int get totalMinutesToday => _totalMinutesToday;
  int get allTimeSessions => _allTimeSessions;
  int get allTimeMinutes => _allTimeMinutes;
  int get currentStreakDays => _currentStreakDays;
  List<DateTime> get studyLog => List.unmodifiable(_studyLog);

  void completeSession(int minutes) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _sessionsToday++;
    _totalMinutesToday += minutes;
    _allTimeSessions++;
    _allTimeMinutes += minutes;
    _studyLog.add(now);

    _updateStreak(today);
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
        final d1 = DateTime(
          _studyLog[i].year, _studyLog[i].month, _studyLog[i].day,
        );
        final d2 = DateTime(
          _studyLog[i + 1].year, _studyLog[i + 1].month, _studyLog[i + 1].day,
        );
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

  void resetDaily() {
    _sessionsToday = 0;
    _totalMinutesToday = 0;
    notifyListeners();
  }
}
