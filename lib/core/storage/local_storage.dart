
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


abstract final class LocalStorage {
  static const String accessToken = 'accessToken';
  static const String refreshToken = 'refreshToken';
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';

  static SharedPreferences? _preferencesInstance;

  static SharedPreferences get _preferences {
    if (_preferencesInstance == null) {
      throw 'Call LocalStorage.init() to initialize local storage';
    }
    return _preferencesInstance!;
  }

  /// Call this ONCE in main() or before using any LocalStorage method
  static Future<void> init() async {
    _preferencesInstance = await SharedPreferences.getInstance();
  }

  /// Save string data
  static Future<bool> saveData(String key, String data) async {
    String toSave = data;
    if (toSave.startsWith('"') && toSave.endsWith('"')) {
      try {
        toSave = jsonDecode(toSave);
      } catch (_) {}
    }
    toSave = toSave.replaceAll(r'\', '');
    return _preferences.setString(key, toSave);
  }

  /// Get string data
  static String? getData(String key) {
    return _preferences.getString(key);
  }

  /// Remove a key
  static Future<bool> removeData(String key) async {
    return _preferences.remove(key);
  }

  /// Clear ALL data
  static Future<bool> clearAllData() async {
    return _preferences.clear();
  }

  /// Save boolean
  static Future<bool> setBool({
    required String key,
    required bool value,
  }) async {
    return _preferences.setBool(key, value);
  }

  /// Get boolean
  static bool? getBool({required String key}) {
    return _preferences.getBool(key);
  }

  /// Save list of strings
  static Future<bool> setList(String key, List<String> value) async {
    return _preferences.setStringList(key, value);
  }

  /// Get list of strings
  static List<String>? getList({required String key}) {
    return _preferences.getStringList(key);
  }
}
