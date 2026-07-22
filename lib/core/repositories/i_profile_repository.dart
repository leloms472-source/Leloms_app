import '../models/profile_model.dart';

abstract class IProfileRepository {
  Future<ProfileModel?> getProfile(String userId);
  Future<void> createProfile(ProfileModel profile);
  Future<void> updateProfile(String userId, Map<String, dynamic> updates);
  Future<void> updateXp(String userId, int xp, int level);
  Future<void> updateStreak(String userId, int streak);
  Future<void> updateDailyMinutes(String userId, int minutes);
  Future<void> updateLastLogin(String userId, DateTime lastLogin);
  Future<void> updateLastStudyDate(String userId, DateTime date);
  Future<void> deleteProfile(String userId);
}
