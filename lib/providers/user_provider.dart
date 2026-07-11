import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  String _userName = 'Alex';
  int _level = 1;
  int _currentXp = 0;
  int _nextLevelXp = 100;
  int _streak = 0;
  bool _isLoggedIn = false;

  String get userName => _userName;
  int get level => _level;
  int get currentXp => _currentXp;
  int get nextLevelXp => _nextLevelXp;
  int get streak => _streak;
  bool get isLoggedIn => _isLoggedIn;
  double get xpProgress => _currentXp / _nextLevelXp;

  void addXp(int amount) {
    _currentXp += amount;
    while (_currentXp >= _nextLevelXp) {
      _currentXp -= _nextLevelXp;
      _level++;
      _nextLevelXp = _calculateXpForLevel(_level);
    }
    notifyListeners();
  }

  void incrementStreak() {
    _streak++;
    notifyListeners();
  }

  void resetStreak() {
    _streak = 0;
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  int _calculateXpForLevel(int level) {
    return 100 + (level - 1) * 50;
  }
}
