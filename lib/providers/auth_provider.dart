import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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
      final userData = await AuthService.getUser();
      _user = userData;
    } catch (e) {
      _user = null;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }
}
