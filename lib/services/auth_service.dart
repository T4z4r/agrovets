import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await ApiService.post('/api/login', {
        'email': email,
        'password': password,
      });
      if (response['success']) {
        final prefs = await SharedPreferences.getInstance();
        await SecureStorageService.saveToken(response['data']['token']);
        await prefs.setString('user', jsonEncode(response['data']['user']));
      }
      return response;
    } on ApiException catch (e) {
      if ((e.statusCode == 401 || e.statusCode == 403) &&
          e.body is Map<String, dynamic>) {
        return e.body as Map<String, dynamic>;
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> register(
      String name,
      String email,
      String password,
      String passwordConfirmation,
      String shopName,
      String shopLocation) async {
    try {
      final data = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': 'owner',
        'shop_name': shopName.trim(),
        'shop_location': shopLocation.trim(),
      };
      final response = await ApiService.post('/api/register', data);
      // Note: Register does not return token yet, OTP verification needed
      return response;
    } on ApiException catch (e) {
      if (e.statusCode == 422 && e.body is Map<String, dynamic>) {
        return e.body as Map<String, dynamic>;
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otpCode) async {
    final response = await ApiService.post('/api/verify-otp', {
      'email': email,
      'otp_code': otpCode,
    });
    if (response['success']) {
      final prefs = await SharedPreferences.getInstance();
      await SecureStorageService.saveToken(response['data']['token']);
      await prefs.setString('user', jsonEncode(response['data']['user']));
    }
    return response;
  }

  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final response = await ApiService.post('/api/resend-otp', {
      'email': email,
    });
    return response;
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await ApiService.post('/api/forgot-password', {
      'email': email,
    });
    return response;
  }

  static Future<Map<String, dynamic>> resetPassword(String email,
      String otpCode, String password, String passwordConfirmation) async {
    final response = await ApiService.post('/api/reset-password', {
      'email': email,
      'otp_code': otpCode,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    return response;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await SecureStorageService.clearToken();
    await prefs.remove('user');
  }

  static Future<Map<String, dynamic>?> getUser() async {
    try {
      final response = await ApiService.get('/api/me');
      if (response['success']) {
        final user = response['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(user));
        return user;
      }
    } catch (e) {
      // If API call fails, try to return stored user
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        return jsonDecode(userStr);
      }
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final token = await SecureStorageService.getToken();
    return token != null;
  }
}
