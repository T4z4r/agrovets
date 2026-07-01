import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/privacy_policy.dart';
import '../models/shop.dart';
import '../models/guide.dart';
import 'secure_storage_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic body;

  const ApiException(this.statusCode, this.message, {this.body});

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  static const String baseUrl = 'https://app.apexpos.co.tz';
  static const Duration timeout = Duration(seconds: 20);

  static Future<Map<String, String>> getHeaders() async {
    final token = await SecureStorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(),
      ).timeout(timeout);
      return _handleResponse(response);
    } on http.ClientException {
      throw Exception('Network Error: Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Network Error: Please check your internet connection.');
    }
  }

  static Future<dynamic> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      ).timeout(timeout);
      return _handleResponse(response);
    } on http.ClientException {
      throw Exception('Network Error: Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Network Error: Please check your internet connection.');
    }
  }

  static Future<dynamic> postMultipart(
    String endpoint,
    Map<String, dynamic> data, {
    String? filePath,
    String fileField = 'photo',
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      final headers = await getHeaders();
      headers.remove('Content-Type');
      request.headers.addAll(headers);
      data.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });
      if (filePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(fileField, filePath),
        );
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse)
          .timeout(timeout);
      return _handleResponse(response);
    } on http.ClientException {
      throw Exception('Network Error: Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Network Error: Please check your internet connection.');
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      ).timeout(timeout);
      return _handleResponse(response);
    } on http.ClientException {
      throw Exception('Network Error: Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Network Error: Please check your internet connection.');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(),
      ).timeout(timeout);
      return _handleResponse(response);
    } on http.ClientException {
      throw Exception('Network Error: Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Network Error: Please check your internet connection.');
    }
  }

  static Future<dynamic> patch(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      ).timeout(timeout);
      return _handleResponse(response);
    } on http.ClientException {
      throw Exception('Network Error: Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Network Error: Please check your internet connection.');
    }
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
      throw Exception('Failed to fetch privacy policy');
    }
  }

  // Shop API methods
  static Future<Shop> getShop() async {
    final response = await get('/api/shop');
    if (response['data'] != null) {
      return Shop.fromJson(response['data']);
    } else {
      throw Exception('Failed to fetch shop details');
    }
  }

  static Future<Shop> updateShop(Map<String, dynamic> data) async {
    final response = await put('/api/shop', data);
    if (response['data'] != null) {
      return Shop.fromJson(response['data']);
    } else {
      throw Exception('Failed to update shop details');
    }
  }

  // Guide API methods
  static Future<List<Guide>> getGuides({String language = 'en'}) async {
    final response = await get('/api/guides');
    List<dynamic> guidesData;
    if (response is List) {
      guidesData = response;
    } else if (response['success'] && response['data'] is List) {
      guidesData = response['data'];
    } else {
      throw Exception('Failed to fetch guides');
    }
    return guidesData.map((json) => Guide.fromJson(json)).toList();
  }

  static Future<http.Response> downloadGuide(int id) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/guides/$id/download'),
      headers: headers,
    ).timeout(timeout);
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Operation failed. Please try again.');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final body = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body is Map<String, dynamic>
        ? body['message']?.toString() ?? 'Operation failed. Please try again.'
        : 'Operation failed. Please try again.';
    throw ApiException(response.statusCode, message, body: body);
  }
}
