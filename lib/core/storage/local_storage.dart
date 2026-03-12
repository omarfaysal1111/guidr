import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _tokenKey = 'jwt_token';

  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  // Auth token helpers
  Future<bool> saveToken(String token) async {
    return await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<bool> deleteToken() async {
    return await _prefs.remove(_tokenKey);
  }

  // Generic string helpers for local templates / drafts
  Future<bool> saveString(String key, String value) async {
    return _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> saveStringList(String key, List<String> values) async {
    return _prefs.setStringList(key, values);
  }

  List<String> getStringList(String key) {
    return _prefs.getStringList(key) ?? <String>[];
  }

  Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }
}
