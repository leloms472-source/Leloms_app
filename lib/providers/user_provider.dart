import 'package:flutter/foundation.dart';
import '../core/repositories/profile_repository.dart';
import '../core/repositories/auth_repository.dart';
import '../core/models/profile_model.dart';

class UserProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  final ProfileRepository _profileRepo = ProfileRepository();

  ProfileModel? _profile;
  bool _isInitialized = false;

  ProfileModel? get profile => _profile;
  String get userName => _profile?.name ?? 'Estudiante';
  int get level => _profile?.level ?? 1;
  int get currentXp => _profile?.currentXp ?? 0;
  int get nextLevelXp => _profile?.nextLevelXp ?? 100;
  int get streak => _profile?.streak ?? 0;
  bool get isLoggedIn => _authRepo.isAuthenticated;
  bool get isInitialized => _isInitialized;
  double get xpProgress => _profile?.xpProgress ?? 0;

  Future<void> initialize() async {
    final session = _authRepo.currentSession;
    if (session != null) {
      await _loadProfile(session.user.id);
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadProfile(String userId) async {
    _profile = await _profileRepo.getProfile(userId);
    notifyListeners();
  }

  Future<void> loadProfile() async {
    if (_authRepo.currentUser == null) return;
    await _loadProfile(_authRepo.currentUser!.id);
  }

  void addXp(int amount) {
    if (_profile == null) return;
    var newXp = _profile!.currentXp + amount;
    var newLevel = _profile!.level;
    var newNextLevel = _profile!.nextLevelXp;

    while (newXp >= newNextLevel) {
      newXp -= newNextLevel;
      newLevel++;
      newNextLevel = _calculateXpForLevel(newLevel);
    }

    _profile = _profile!.copyWith(
      currentXp: newXp,
      level: newLevel,
      nextLevelXp: newNextLevel,
    );

    _profileRepo.updateXp(
      _profile!.id,
      _profile!.currentXp,
      _profile!.level,
      _profile!.nextLevelXp,
    );

    notifyListeners();
  }

  void incrementStreak() {
    if (_profile == null) return;
    _profile = _profile!.copyWith(streak: _profile!.streak + 1);
    _profileRepo.updateStreak(_profile!.id, _profile!.streak);
    notifyListeners();
  }

  void resetStreak() {
    if (_profile == null) return;
    _profile = _profile!.copyWith(streak: 0);
    _profileRepo.updateStreak(_profile!.id, 0);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(name: name);
    await _profileRepo.updateProfile(_profile!.id, {'name': name});
    notifyListeners();
  }

  void setProfile(ProfileModel profile) {
    _profile = profile;
    notifyListeners();
  }

  int _calculateXpForLevel(int level) {
    return 100 + (level - 1) * 50;
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
    _profile = null;
    notifyListeners();
  }
}
