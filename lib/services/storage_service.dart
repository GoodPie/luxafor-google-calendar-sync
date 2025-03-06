import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Save Google auth token
  Future<void> saveToken(Map<String, dynamic> token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('google_auth_token', jsonEncode(token));
  }

  // Get Google auth token
  Future<Map<String, dynamic>?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenJson = prefs.getString('google_auth_token');
    if (tokenJson == null) return null;
    return jsonDecode(tokenJson) as Map<String, dynamic>;
  }

  // Delete Google auth token
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('google_auth_token');
  }
}