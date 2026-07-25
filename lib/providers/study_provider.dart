import 'package:flutter/foundation.dart';
import '../core/enums/enums.dart';
import '../core/models/study_session.dart';

class StudyProvider extends ChangeNotifier {
  int _sessionsToday = 0;
  int _totalMinutesToday = 0;
  int _allTimeSessions = 0;
  int _allTimeMinutes = 0;
  String? _nextExam;
  String? _userId;

  int get sessionsToday => _sessionsToday;
  int get totalMinutesToday => _totalMinutesToday;
  int get allTimeSessions => _allTimeSessions;
  int get allTimeMinutes => _allTimeMinutes;
  String? get nextExam => _nextExam;

  Future<void> loadFromServer(String userId) async {
    _userId = userId;
    notifyListeners();
  }

  void completeSession(int minutes, {SessionType type = SessionType.pomodoro, String? subjectName}) {
    _sessionsToday++;
    _totalMinutesToday += minutes;
    _allTimeSessions++;
    _allTimeMinutes += minutes;
    notifyListeners();
  }

  void setNextExam(String exam) {
    _nextExam = exam;
    notifyListeners();
  }

  void resetDaily() {
    _sessionsToday = 0;
    _totalMinutesToday = 0;
    notifyListeners();
  }
}
