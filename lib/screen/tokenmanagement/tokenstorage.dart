import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static final SharedPrefs _instance = SharedPrefs._internal();
  factory SharedPrefs() => _instance;
  SharedPrefs._internal();

  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save Token
  static Future<void> saveToken(String token) async {
    await _prefs?.setString('auth_token', token);
  }

  // Get Token
  static String? getToken() {
    return _prefs?.getString('auth_token');
  }

  // Save User Data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs?.setString('user_id', userData['id'] ?? '');
    await _prefs?.setString('user_name', userData['name'] ?? '');
    await _prefs?.setString('user_phone', userData['phone'] ?? '');
    await _prefs?.setString('user_role', userData['role'] ?? '');
  }

  // Get User Data
  static Map<String, dynamic> getUserData() {
    return {
      'id': _prefs?.getString('user_id'),
      'name': _prefs?.getString('user_name'),
      'phone': _prefs?.getString('user_phone'),
      'role': _prefs?.getString('user_role'),
    };
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return getToken() != null && getToken()!.isNotEmpty;
  }

  // Clear all data (logout)
  static Future<void> clearAllData() async {
    await _prefs?.clear();
  }

  // Save specific user field
  static Future<void> saveUserField(String key, String value) async {
    await _prefs?.setString('user_$key', value);
  }

  // Get specific user field
  static String? getUserField(String key) {
    return _prefs?.getString('user_$key');
  }
}