import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _prefix = 'cache_';
  static const String _keysKey = 'cache_keys';
  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  Future<void> cacheData(String key, dynamic data) async {
    await initialize();
    final fullKey = '$_prefix$key';
    final json = jsonEncode({
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _prefs.setString(fullKey, json);

    final keys = _prefs.getStringList(_keysKey) ?? [];
    if (!keys.contains(key)) {
      keys.add(key);
      await _prefs.setStringList(_keysKey, keys);
    }
  }

  T? getCached<T>(String key, T Function(dynamic) fromJson) {
    final fullKey = '$_prefix$key';
    final stored = _prefs.getString(fullKey);
    if (stored == null) return null;

    try {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      return fromJson(decoded['data']);
    } catch (_) {
      return null;
    }
  }

  List<dynamic>? getCachedList(String key) {
    final fullKey = '$_prefix$key';
    final stored = _prefs.getString(fullKey);
    if (stored == null) return null;

    try {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      return decoded['data'] as List<dynamic>?;
    } catch (_) {
      return null;
    }
  }

  bool isStale(String key, {Duration maxAge = const Duration(hours: 1)}) {
    final fullKey = '$_prefix$key';
    final stored = _prefs.getString(fullKey);
    if (stored == null) return true;

    try {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      final timestamp = DateTime.parse(decoded['timestamp'] as String);
      return DateTime.now().difference(timestamp) > maxAge;
    } catch (_) {
      return true;
    }
  }

  Future<void> clearCache() async {
    await initialize();
    final keys = _prefs.getStringList(_keysKey) ?? [];
    for (final key in keys) {
      await _prefs.remove('$_prefix$key');
    }
    await _prefs.remove(_keysKey);
  }

  Future<void> clearKey(String key) async {
    await initialize();
    await _prefs.remove('$_prefix$key');
    final keys = _prefs.getStringList(_keysKey) ?? [];
    keys.remove(key);
    await _prefs.setStringList(_keysKey, keys);
  }
}
