import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _tokenKey = 'jwt_token';

  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  Future<bool> saveToken(String token) async {
    return await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<bool> deleteToken() async {
    return await _prefs.remove(_tokenKey);
  }
}
