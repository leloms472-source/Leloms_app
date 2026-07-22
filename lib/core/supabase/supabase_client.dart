import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase, SupabaseClient;

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await dotenv.load();
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    assert(url != null && url.isNotEmpty, 'SUPABASE_URL not set in .env');
    assert(anonKey != null && anonKey.isNotEmpty, 'SUPABASE_ANON_KEY not set in .env');

    await Supabase.initialize(
      url: url!,
      publishableKey: anonKey!,
      debug: false,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static bool get isInitialized => true;
}
