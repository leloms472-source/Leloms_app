import '../models/profile_model.dart';

abstract class IProfileRepository {
  Future<ProfileModel?> getProfile(String userId);
  Future<void> createProfile(ProfileModel profile);
  Future<void> updateProfile(String userId, Map<String, dynamic> updates);
  Future<void> updateXp(String userId, int xp, int level);
  Future<void> updateStreak(String userId, int streak);
  Future<void> updateCoins(String userId, int coins);
  Future<void> updateDailyMinutes(String userId, int minutes);
  Future<void> updateEnergy(String userId, int energy);
  Future<void> updateHearts(String userId, int hearts);
  Future<void> updateLastLogin(String userId, DateTime lastLogin);
  Future<void> updateLastStudyDate(String userId, DateTime date);
  Future<void> deleteProfile(String userId);
}
