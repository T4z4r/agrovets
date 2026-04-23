import 'package:shared_preferences/shared_preferences.dart';

class AppTourService {
  static String _userIdentity(Map<String, dynamic>? user) {
    if (user == null) return 'guest';
    final id = user['id']?.toString();
    if (id != null && id.isNotEmpty) return id;
    final email = user['email']?.toString();
    if (email != null && email.isNotEmpty) return email;
    final name = user['name']?.toString();
    if (name != null && name.isNotEmpty) return name;
    return 'guest';
  }

  static String _tourKey(Map<String, dynamic>? user) {
    final role = user?['role']?.toString() ?? 'guest';
    return 'app_tour_seen_${role}_${_userIdentity(user)}';
  }

  static Future<bool> shouldShowTour(Map<String, dynamic>? user) async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_tourKey(user)) ?? false);
  }

  static Future<void> markTourSeen(Map<String, dynamic>? user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tourKey(user), true);
  }

  static Future<void> resetTour(Map<String, dynamic>? user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tourKey(user));
  }
}
