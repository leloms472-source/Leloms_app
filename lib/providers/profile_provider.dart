import 'package:flutter/foundation.dart';
import '../core/repositories/i_profile_repository.dart';
import '../core/repositories/profile_repository_impl.dart';
import '../core/repositories/auth_repository.dart';
import '../core/models/profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  final AuthRepository _authRepo;
  final IProfileRepository _profileRepo;

  ProfileModel? _profile;
  bool _isInitialized = false;

  ProfileProvider({
    AuthRepository? authRepo,
    IProfileRepository? profileRepo,
  })  : _authRepo = authRepo ?? AuthRepository(),
        _profileRepo = profileRepo ?? ProfileRepository();

  ProfileModel? get profile => _profile;
  String get userName =>
      _profile?.fullName ?? _profile?.username ?? 'Estudiante';
  int get level => _profile?.level ?? 1;
  int get currentXp => _profile?.xp ?? 0;
  int get nextLevelXp => _profile?.nextLevelXp ?? 100;
  int get streak => _profile?.streak ?? 0;
  bool get isInitialized => _isInitialized;
  double get xpProgress => _profile?.xpProgress ?? 0;
  int get dailyStudyMinutes => _profile?.dailyStudyMinutes ?? 0;
  String get language => _profile?.language ?? 'es';
  String? get country => _profile?.country;
  String? get timezone => _profile?.timezone;
  int? get birthYear => _profile?.birthYear;
  int? get academicYear => _profile?.academicYear;
  String? get favoriteSubject => _profile?.favoriteSubject;
  DateTime? get lastLogin => _profile?.lastLogin;
  DateTime? get lastStudyDate => _profile?.lastStudyDate;

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
    if (_profile == null && _authRepo.currentUser != null) {
      _profile = ProfileModel(id: userId);
      await _profileRepo.createProfile(_profile!);
    }
    notifyListeners();
  }

  Future<void> loadProfile() async {
    final user = _authRepo.currentUser;
    if (user == null) return;
    await _loadProfile(user.id);
  }

  void setProfile(ProfileModel profile) {
    _profile = profile;
    notifyListeners();
  }

  void addXp(int amount) {
    if (_profile == null) return;
    var newXp = _profile!.xp + amount;
    var newLevel = _profile!.level;

    while (newXp >= _profile!.nextLevelXp) {
      newXp -= _profile!.nextLevelXp;
      newLevel++;
    }

    final updated = _profile!.copyWith(xp: newXp, level: newLevel);
    _profile = updated;
    _profileRepo.updateXp(_profile!.id, _profile!.xp, _profile!.level);
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
    _profile = _profile!.copyWith(fullName: name);
    await _profileRepo.updateProfile(_profile!.id, {'full_name': name});
    notifyListeners();
  }

  void updateDailyStudyMinutes(int minutes) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(dailyStudyMinutes: minutes);
    _profileRepo.updateDailyMinutes(_profile!.id, minutes);
    notifyListeners();
  }

  Future<void> setLastLogin() async {
    if (_profile == null) return;
    final now = DateTime.now();
    _profile = _profile!.copyWith(lastLogin: now);
    await _profileRepo.updateLastLogin(_profile!.id, now);
    notifyListeners();
  }

  Future<void> setLastStudyDate(DateTime date) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(lastStudyDate: date);
    await _profileRepo.updateLastStudyDate(_profile!.id, date);
    notifyListeners();
  }

  Future<void> updateProfileField(String field, dynamic value) async {
    if (_profile == null) return;
    await _profileRepo.updateProfile(_profile!.id, {field: value});
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
    _profile = null;
    notifyListeners();
  }
}
