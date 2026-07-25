import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/services/interfaces/storage_service.dart';

class StorageServiceImpl implements IStorageService {
  SupabaseClient get _client => SupabaseConfig.client;

  @override
  Future<String?> uploadPdf(String userId, String fileName, List<int> bytes) async {
    final path = '$userId/pdfs/$fileName';
    await _client.storage.from('pdfs').uploadBinary(path, Uint8List.fromList(bytes));
    return _client.storage.from('pdfs').getPublicUrl(path);
  }

  @override
  Future<String?> uploadImage(String userId, String fileName, List<int> bytes) async {
    final path = '$userId/avatars/$fileName';
    await _client.storage.from('avatars').uploadBinary(path, Uint8List.fromList(bytes));
    return _client.storage.from('avatars').getPublicUrl(path);
  }

  @override
  Future<void> deleteFile(String url) async {
    final path = Uri.parse(url).pathSegments.skip(2).join('/');
    final bucket = Uri.parse(url).pathSegments[1];
    await _client.storage.from(bucket).remove([path]);
  }

  @override
  Future<String> getPublicUrl(String bucket, String path) async {
    return _client.storage.from(bucket).getPublicUrl(path);
  }
}
