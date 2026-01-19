import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/privacy_policy.dart';
import '../models/shop.dart';

class ApiService {
  static const String baseUrl = 'https://pos.sudsudgroup.com'; // CHANGE THIS

  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await getHeaders(),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> post(
      String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await getHeaders(),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> patch(
      String endpoint, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: await getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // Seller API methods
  static Future<dynamic> getSellers() async {
    return await get('/api/sellers');
  }

  static Future<dynamic> createSeller(Map<String, dynamic> data) async {
    return await post('/api/sellers', data);
  }

  static Future<dynamic> getSeller(int id) async {
    return await get('/api/sellers/$id');
  }

  static Future<dynamic> updateSeller(int id, Map<String, dynamic> data) async {
    return await put('/api/sellers/$id', data);
  }

  static Future<dynamic> deleteSeller(int id) async {
    return await delete('/api/sellers/$id');
  }

  static Future<dynamic> toggleBlockSeller(int id) async {
    return await patch('/api/sellers/$id/block', {});
  }

  static Future<PrivacyPolicy> getPrivacyPolicy() async {
    final response = await get('/api/privacy-policy');
    if (response['success']) {
      return PrivacyPolicy.fromJson(response['data']);
    } else {
      throw Exception(response['message'] ?? 'Failed to fetch privacy policy');
    }
  }

  // Shop API methods
  static Future<Shop> getShop() async {
    final response = await get('/shop');
    if (response['success']) {
      return Shop.fromJson(response['data']);
    } else {
      throw Exception(response['message'] ?? 'Failed to fetch shop details');
    }
  }

  static Future<Shop> updateShop(Map<String, dynamic> data) async {
    final response = await put('/shop', data);
    if (response['success']) {
      return Shop.fromJson(response['data']);
    } else {
      throw Exception(response['message'] ?? 'Failed to update shop details');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final json = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json;
    } else {
      throw Exception('An error occurred. Please try again.');
    }
  }
}
