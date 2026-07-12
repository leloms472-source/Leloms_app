import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';

class AchievementRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<List<Map<String, dynamic>>> getUserAchievements(String userId) async {
    final data = await _client.from('achievements').select().eq('user_id', userId);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> unlockAchievement(String userId, String achievementId, String title, String description) async {
    await _client.from('achievements').insert({
      'user_id': userId,
      'achievement_id': achievementId,
      'title': title,
      'description': description,
    });
  }

  Future<bool> isAchievementUnlocked(String userId, String achievementId) async {
    final data = await _client.from('achievements').select()
        .eq('user_id', userId)
        .eq('achievement_id', achievementId)
        .maybeSingle();
    return data != null;
  }
}
