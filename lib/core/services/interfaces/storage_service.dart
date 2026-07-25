abstract class IStorageService {
  Future<String?> uploadPdf(String userId, String fileName, List<int> bytes);
  Future<String?> uploadImage(String userId, String fileName, List<int> bytes);
  Future<void> deleteFile(String url);
  Future<String> getPublicUrl(String bucket, String path);
}
