import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _tokenKey = "specialDinnerToken";


  static Future<void> saveToken(Map<String, dynamic> tokenData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_tokenKey, jsonEncode(tokenData));
  }


  static Future<Map<String, dynamic>?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_tokenKey);
    if (data == null) return null;
    return jsonDecode(data);
  }


  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_tokenKey);
  }

}
