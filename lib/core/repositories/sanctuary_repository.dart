import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';
import '../models/sanctuary_model.dart';

class SanctuaryRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<SanctuaryModel?> getSanctuary(String userId) async {
    final data = await _client.from('sanctuary').select().eq('user_id', userId).maybeSingle();
    if (data == null) return null;
    return SanctuaryModel.fromMap(data);
  }

  Future<void> updateSanctuary(String userId, Map<String, dynamic> updates) async {
    await _client.from('sanctuary').update(updates).eq('user_id', userId);
  }

  Future<PetModel?> getPet(String userId) async {
    final data = await _client.from('pets').select().eq('user_id', userId).maybeSingle();
    if (data == null) return null;
    return PetModel.fromMap(data);
  }

  Future<void> updatePet(String userId, Map<String, dynamic> updates) async {
    await _client.from('pets').update(updates).eq('user_id', userId);
  }
}
