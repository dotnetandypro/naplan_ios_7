import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _storageKey = 'user_uid';

  // Save user ID after successful login
  static Future<void> saveUserId(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, uid);
  }

  // Get stored user ID (if any)
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storageKey);
  }

  // Clear stored user ID (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final userId = await getUserId();
    return userId != null && userId.isNotEmpty;
  }
}
