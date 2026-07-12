import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import '../supabase/supabase_client.dart';

class StorageRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<String> uploadAvatar(String userId, File file) async {
    final ext = p.extension(file.path);
    final path = '$userId/avatar$ext';
    await _client.storage.from('avatars').upload(path, file, fileOptions: const FileOptions(upsert: true));
    final url = _client.storage.from('avatars').getPublicUrl(path);
    return url;
  }

  Future<String> uploadNoteFile(String userId, String fileName, File file) async {
    final path = '$userId/$fileName';
    await _client.storage.from('notes').upload(path, file, fileOptions: const FileOptions(upsert: true));
    return path;
  }

  Future<String> uploadPdf(String userId, String fileName, File file) async {
    final path = '$userId/$fileName';
    await _client.storage.from('pdfs').upload(path, file, fileOptions: const FileOptions(upsert: true));
    final url = _client.storage.from('pdfs').getPublicUrl(path);
    return url;
  }

  Future<String> uploadCommunityFile(String fileName, File file) async {
    final path = fileName;
    await _client.storage.from('community').upload(path, file, fileOptions: const FileOptions(upsert: true));
    final url = _client.storage.from('community').getPublicUrl(path);
    return url;
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
