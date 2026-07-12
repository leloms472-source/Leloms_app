import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

class SupabaseRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  SupabaseClient get client => _client;

  PostgrestQueryBuilder from(String table) => _client.from(table);

  SupabaseStorageClient get storage => _client.storage;

  GoTrueClient get auth => _client.auth;

  RealtimeClient get realtime => _client.realtime;

  User? get currentUser => _client.auth.currentUser;

  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    final response = await _client.from('profiles').select().eq('id', userId).maybeSingle();
    return response;
  }

  Future<void> upsertProfile(Map<String, dynamic> profile) async {
    await _client.from('profiles').upsert(profile);
  }

  Future<String> getCurrentUserId() async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user');
    return user.id;
  }
}
