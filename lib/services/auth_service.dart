import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

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
        await prefs.setString('token', response['data']['token']);
        await prefs.setString('user', jsonEncode(response['data']['user']));
      }
      return response;
    } catch (e) {
      // Handle 401 (invalid credentials) and 403 (unverified account) responses
      if (e.toString().contains('Operation failed')) {
        // For both 401 and 403, we need to manually make the request to get the response
        try {
          final client = http.Client();
          final headers = await ApiService.getHeaders();
          final apiResponse = await client.post(
            Uri.parse('${ApiService.baseUrl}/api/login'),
            headers: headers,
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          );
          client.close();

          final jsonResponse = jsonDecode(apiResponse.body);
          if (apiResponse.statusCode == 401 &&
              jsonResponse['message']?.contains('Invalid credentials') ==
                  true) {
            // Return invalid credentials response
            return jsonResponse;
          } else if (apiResponse.statusCode == 403 &&
              jsonResponse['message']?.contains('not verified') == true) {
            // Return unverified account response
            return jsonResponse;
          }
          throw Exception('Login failed');
        } catch (innerError) {
          throw Exception(
              'Network Error: Please check your internet connection.');
        }
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
        'shop_name': shopName,
        'shop_location': shopLocation,
      };
      final response = await ApiService.post('/api/register', data);
      // Note: Register does not return token yet, OTP verification needed
      return response;
    } catch (e) {
      // Handle validation errors (422) and other errors
      if (e.toString().contains('Operation failed')) {
        try {
          final client = http.Client();
          final headers = await ApiService.getHeaders();
          final apiResponse = await client.post(
            Uri.parse('${ApiService.baseUrl}/api/register'),
            headers: headers,
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'password_confirmation': passwordConfirmation,
              'role': 'owner',
              'shop_name': shopName,
              'shop_location': shopLocation,
            }),
          );
          client.close();

          final jsonResponse = jsonDecode(apiResponse.body);
          if (apiResponse.statusCode == 422) {
            // Validation error
            return jsonResponse;
          } else {
            throw Exception('Registration failed');
          }
        } catch (innerError) {
          throw Exception(
              'Network Error: Please check your internet connection.');
        }
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
      await prefs.setString('token', response['data']['token']);
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
    await prefs.remove('token');
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
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }
}
