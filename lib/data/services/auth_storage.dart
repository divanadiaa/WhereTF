import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/circle_summary.dart';

class AuthStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _circleKey = 'current_circle';
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> saveToken(String token) {
    return _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> readToken() {
    return _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() {
    return _secureStorage.delete(key: _tokenKey);
  }

  Future<void> saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<AppUser?> readUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(_userKey);

    if (rawUser == null || rawUser.isEmpty) {
      return null;
    }

    return AppUser.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
  }

  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<void> saveCurrentCircle(CircleSummary circle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_circleKey, jsonEncode(circle.toJson()));
  }

  Future<CircleSummary?> readCurrentCircle() async {
    final prefs = await SharedPreferences.getInstance();
    final rawCircle = prefs.getString(_circleKey);

    if (rawCircle == null || rawCircle.isEmpty) {
      return null;
    }

    return CircleSummary.fromJson(
      jsonDecode(rawCircle) as Map<String, dynamic>,
    );
  }

  Future<void> deleteCurrentCircle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_circleKey);
  }

  Future<void> clearSession() async {
    await deleteToken();
    await deleteUser();
    await deleteCurrentCircle();
  }
}
