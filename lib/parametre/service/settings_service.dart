import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/auth_service.dart';
import '../../database/database_helper.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _languageKey = 'app_language';
  static const String _themeKey = 'app_theme';

  // Get saved language
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'fr';
  }

  // Save language
  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  // Get theme mode
  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey) ?? 'light';
    return themeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  // Save theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  // Toggle theme
  Future<ThemeMode> toggleTheme() async {
    final currentMode = await getThemeMode();
    final newMode = currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
    return newMode;
  }

  // Logout
  Future<void> logout() async {
    await AuthService().logout();
  }

  // Delete account
  Future<bool> deleteAccount(String userId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      // Delete user data from all tables
      await db.delete('users', where: 'user_id = ?', whereArgs: [userId]);
      await db.delete('students', where: 'user_id = ?', whereArgs: [userId]);
      await db.delete('lecturers', where: 'user_id = ?', whereArgs: [userId]);
      await db.delete('projects', where: 'user_id = ?', whereArgs: [userId]);
      await db.delete('posts', where: 'user_id = ?', whereArgs: [userId]);
      await db.delete('comments', where: 'user_id = ?', whereArgs: [userId]);
      await db.delete('likes', where: 'user_id = ?', whereArgs: [userId]);
      await db.delete('notifications', where: 'user_id = ?', whereArgs: [userId]);
      
      // Clear preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      return true;
    } catch (e) {
      debugPrint('Error deleting account: $e');
      return false;
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final language = await getLanguage();
    final theme = await getThemeMode();
    
    await prefs.clear();
    
    // Restore important settings
    await setLanguage(language);
    await setThemeMode(theme);
  }

  // Get app version
  String getAppVersion() {
    return '1.0.0';
  }

  // Check for updates
  Future<bool> checkForUpdates() async {
    // Implement update check logic
    await Future.delayed(const Duration(seconds: 2));
    return false;
  }
}
