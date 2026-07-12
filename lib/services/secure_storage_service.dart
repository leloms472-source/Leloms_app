import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _notesPrefix = 'note_';
  static const _avatarKey = 'avatar_path';
  static const _studyPlanKey = 'study_plan';

  Future<void> saveString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> readString(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteKey(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> saveNote(String subject, String content) async {
    await _storage.write(key: '$_notesPrefix$subject', value: content);
  }

  Future<String?> readNote(String subject) async {
    return await _storage.read(key: '$_notesPrefix$subject');
  }

  Future<void> saveAvatarPath(String path) async {
    await _storage.write(key: _avatarKey, value: path);
  }

  Future<String?> readAvatarPath() async {
    return await _storage.read(key: _avatarKey);
  }

  Future<void> saveStudyPlan(String json) async {
    await _storage.write(key: _studyPlanKey, value: json);
  }

  Future<String?> readStudyPlan() async {
    return await _storage.read(key: _studyPlanKey);
  }

  Future<void> deleteStudyPlan() async {
    await _storage.delete(key: _studyPlanKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
