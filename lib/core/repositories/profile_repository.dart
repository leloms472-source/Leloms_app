import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<ProfileModel?> getProfile(String userId) async {
    final data = await _client.from('profiles').select().eq('id', userId).maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromMap(data);
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    await _client.from('profiles').update(updates).eq('id', userId);
  }

  Future<void> upsertProfile(ProfileModel profile) async {
    await _client.from('profiles').upsert(profile.toMap());
  }

  Future<void> updateXp(String userId, int xp, int level, int nextLevelXp) async {
    await _client.from('profiles').update({
      'current_xp': xp,
      'level': level,
      'next_level_xp': nextLevelXp,
    }).eq('id', userId);
  }

  Future<void> updateStreak(String userId, int streak) async {
    await _client.from('profiles').update({'streak': streak}).eq('id', userId);
  }
}
