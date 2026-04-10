import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/privacy_policy.dart';
import '../models/shop.dart';
import '../models/guide.dart';

class ApiService {
  static const String baseUrl = 'https://app.apexpos.co.tz'; // CHANGE THIS

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
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(),
      );
      return _handleResponse(response);
    } on http.ClientException {
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
      );
      return _handleResponse(response);
    } on http.ClientException {
      throw Exception(
'Network Error: Please check your internet connection.');
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } on http.ClientException {
      throw Exception(
'Network Error: Please check your internet connection.');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(),
      );
      return _handleResponse(response);
    } on http.ClientException {
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
      );
      return _handleResponse(response);
    } on http.ClientException {
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
      print(response);
      throw Exception('Failed to fetch guides');
    }
    return guidesData.map((json) => Guide.fromJson(json)).toList();
  }

  static Future<http.Response> downloadGuide(int id) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/guides/$id/download'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Operation failed. Please try again.');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final json = jsonDecode(response.body);
    print('API Response: Status ${response.statusCode}, Body: $json');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json;
    } else {
      // Extract error message from server response
      String errorMessage = 'Operation failed. Please try again.';
      if (json is Map<String, dynamic>) {
        if (json.containsKey('message')) {
          errorMessage = json['message'];
        } else if (json.containsKey('error')) {
          if (json['error'] is String) {
            errorMessage = json['error'];
          } else if (json['error'] is Map && json['error'].containsKey('message')) {
            errorMessage = json['error']['message'];
          }
        } else if (json.containsKey('errors')) {
          // Handle validation errors
          final errors = json['errors'];
          if (errors is Map) {
            errorMessage = errors.values.first.toString();
          } else if (errors is List) {
            errorMessage = errors.first.toString();
          }
        }
      }
      throw Exception(errorMessage);
    }
  }
}
