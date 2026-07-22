import '../datasources/profile_datasource.dart';
import '../models/profile_model.dart';
import 'i_profile_repository.dart';

class ProfileRepository implements IProfileRepository {
  final ProfileDatasource _datasource;

  ProfileRepository({ProfileDatasource? datasource})
      : _datasource = datasource ?? ProfileDatasource();

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    return _datasource.fetchProfile(userId);
  }

  @override
  Future<void> createProfile(ProfileModel profile) async {
    await _datasource.createProfile(profile);
  }

  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    await _datasource.updateProfile(userId, updates);
  }

  @override
  Future<void> updateXp(String userId, int xp, int level) async {
    await _datasource.updateProfile(userId, {
      'xp': xp,
      'level': level,
    });
  }

  @override
  Future<void> updateStreak(String userId, int streak) async {
    await _datasource.updateProfile(userId, {'streak': streak});
  }

  @override
  Future<void> updateCoins(String userId, int coins) async {
    await _datasource.updateProfile(userId, {'coins': coins});
  }

  @override
  Future<void> updateDailyMinutes(String userId, int minutes) async {
    await _datasource.updateProfile(userId, {
      'daily_study_minutes': minutes,
    });
  }

  @override
  Future<void> updateEnergy(String userId, int energy) async {
    await _datasource.updateProfile(userId, {'energy': energy});
  }

  @override
  Future<void> updateHearts(String userId, int hearts) async {
    await _datasource.updateProfile(userId, {'hearts': hearts});
  }

  @override
  Future<void> updateLastLogin(String userId, DateTime lastLogin) async {
    await _datasource.updateProfile(userId, {
      'last_login': lastLogin.toIso8601String(),
    });
  }

  @override
  Future<void> updateLastStudyDate(String userId, DateTime date) async {
    await _datasource.updateProfile(userId, {
      'last_study_date': date.toIso8601String().substring(0, 10),
    });
  }

  @override
  Future<void> deleteProfile(String userId) async {
    await _datasource.deleteProfile(userId);
  }
}
