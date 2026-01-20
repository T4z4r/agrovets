import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _loading = false;

  Map<String, dynamic>? get user => _user;
  bool get loading => _loading;
  bool get isAdmin => _user?['role'] == 'admin';
  bool get isOwner => _user?['role'] == 'owner';
  bool get isSeller => _user?['role'] == 'seller';

  Future<void> loadUser() async {
    _loading = true;
    notifyListeners();
    try {
      // First try to load from local DB
      final dbUser = await DatabaseHelper().getUser();
      if (dbUser != null) {
        _user = dbUser.toJson();
      }

      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Fetch from API and update DB
        try {
          final userData = await AuthService.getUser();
          if (userData != null) {
            _user = userData;
            final user = User.fromJson(userData);
            await DatabaseHelper().insertUser(user);
          }
        } catch (e) {
          // If API fails (e.g., token expired), clear local data
          if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
            await DatabaseHelper().clearAllData();
            _user = null;
          }
        }
      }
    } catch (e) {
      // If both fail, keep the DB user if available
      print('Error loading user: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    // Clear local data
    await DatabaseHelper().clearAllData();
    notifyListeners();
  }
}
