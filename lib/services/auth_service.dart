import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await ApiService.post('/api/login', {
      'email': email,
      'password': password,
    });
    if (response['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['data']['token']);
      await prefs.setString('user', jsonEncode(response['data']['user']));
    }
    return response;
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await ApiService.post('/api/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    if (response['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['data']['token']);
      await prefs.setString('user', jsonEncode(response['data']['user']));
    }
    return response;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }
}
