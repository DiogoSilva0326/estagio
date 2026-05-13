import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _roleKey = 'preferred_visual_role';

  static Future<void> savePreferredRole(String roleName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, roleName);
  }

  static Future<String?> loadPreferredRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<void> clearPreferredRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
  }
}