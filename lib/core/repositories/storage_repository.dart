import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';

class StorageRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<String> uploadAvatar(String userId, Uint8List bytes, String extension) async {
    final path = '$userId/avatar$extension';
    await _client.storage.from('avatars').uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
    return _client.storage.from('avatars').getPublicUrl(path);
  }

  Future<String> uploadNoteFile(String userId, String fileName, Uint8List bytes) async {
    final path = '$userId/$fileName';
    await _client.storage.from('notes').uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
    return path;
  }

  Future<String> uploadPdf(String userId, String fileName, Uint8List bytes) async {
    final path = '$userId/$fileName';
    await _client.storage.from('pdfs').uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
    return _client.storage.from('pdfs').getPublicUrl(path);
  }

  Future<String> uploadCommunityFile(String fileName, Uint8List bytes) async {
    final path = fileName;
    await _client.storage.from('community').uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
    return _client.storage.from('community').getPublicUrl(path);
  }

  Future<void> deleteAvatar(String userId) async {
    final files = await _client.storage.from('avatars').list(path: userId);
    if (files.isNotEmpty) {
      await _client.storage.from('avatars').remove(files.map((f) => '$userId/${f.name}').toList());
    }
  }

  Future<String?> downloadUrl(String bucket, String path) async {
    try {
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (_) {
      return null;
    }
  }
}
