import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/auth/auth_service.dart';

enum AppTheme { light, dark, system }
enum AppLanguage { french, english }

class ProfileSettings {
  final String userId;
  final AppTheme theme;
  final AppLanguage language;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool projectUpdates;
  final bool groupInvitations;
  final bool commentReplies;
  final bool likesNotifications;
  final bool privacyMode;
  final bool showEmail;
  final bool showPhone;
  final bool allowCollaboration;
  final DateTime lastUpdated;

  ProfileSettings({
    required this.userId,
    this.theme = AppTheme.system,
    this.language = AppLanguage.french,
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.projectUpdates = true,
    this.groupInvitations = true,
    this.commentReplies = true,
    this.likesNotifications = false,
    this.privacyMode = false,
    this.showEmail = true,
    this.showPhone = false,
    this.allowCollaboration = true,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'theme': theme.toString().split('.').last,
      'language': language.toString().split('.').last,
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'projectUpdates': projectUpdates,
      'groupInvitations': groupInvitations,
      'commentReplies': commentReplies,
      'likesNotifications': likesNotifications,
      'privacyMode': privacyMode,
      'showEmail': showEmail,
      'showPhone': showPhone,
      'allowCollaboration': allowCollaboration,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ProfileSettings.fromMap(Map<String, dynamic> map) {
    return ProfileSettings(
      userId: map['userId'] ?? '',
      theme: AppTheme.values.firstWhere(
        (e) => e.toString().split('.').last == map['theme'],
        orElse: () => AppTheme.system,
      ),
      language: AppLanguage.values.firstWhere(
        (e) => e.toString().split('.').last == map['language'],
        orElse: () => AppLanguage.french,
      ),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      projectUpdates: map['projectUpdates'] ?? true,
      groupInvitations: map['groupInvitations'] ?? true,
      commentReplies: map['commentReplies'] ?? true,
      likesNotifications: map['likesNotifications'] ?? false,
      privacyMode: map['privacyMode'] ?? false,
      showEmail: map['showEmail'] ?? true,
      showPhone: map['showPhone'] ?? false,
      allowCollaboration: map['allowCollaboration'] ?? true,
      lastUpdated: DateTime.parse(map['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  ProfileSettings copyWith({
    String? userId,
    AppTheme? theme,
    AppLanguage? language,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? projectUpdates,
    bool? groupInvitations,
    bool? commentReplies,
    bool? likesNotifications,
    bool? privacyMode,
    bool? showEmail,
    bool? showPhone,
    bool? allowCollaboration,
    DateTime? lastUpdated,
  }) {
    return ProfileSettings(
      userId: userId ?? this.userId,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      projectUpdates: projectUpdates ?? this.projectUpdates,
      groupInvitations: groupInvitations ?? this.groupInvitations,
      commentReplies: commentReplies ?? this.commentReplies,
      likesNotifications: likesNotifications ?? this.likesNotifications,
      privacyMode: privacyMode ?? this.privacyMode,
      showEmail: showEmail ?? this.showEmail,
      showPhone: showPhone ?? this.showPhone,
      allowCollaboration: allowCollaboration ?? this.allowCollaboration,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class ProfileSettingsService {
  static final ProfileSettingsService _instance = ProfileSettingsService._internal();
  factory ProfileSettingsService() => _instance;
  ProfileSettingsService._internal();

  static const _settingsKey = 'profile_settings';
  ProfileSettings? _currentSettings;

  Future<void> init() async {
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsData = prefs.getString(_settingsKey);
      if (settingsData != null) {
        final Map<String, dynamic> settingsMap = jsonDecode(settingsData);
        _currentSettings = ProfileSettings.fromMap(settingsMap);
      }
    } catch (e) {
      debugPrint('Failed to load profile settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    if (_currentSettings == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(_currentSettings!.toMap()));
    } catch (e) {
      debugPrint('Failed to save profile settings: $e');
    }
  }

  // Obtenir les paramètres de l'utilisateur actuel
  ProfileSettings getCurrentSettings() {
    final currentUser = AuthService().currentUser;
    if (currentUser == null) {
      return ProfileSettings(
        userId: '',
        lastUpdated: DateTime.now(),
      );
    }

    if (_currentSettings == null || _currentSettings!.userId != currentUser.userId) {
      _currentSettings = ProfileSettings(
        userId: currentUser.userId,
        lastUpdated: DateTime.now(),
      );
    }

    return _currentSettings!;
  }

  // Mettre à jour le thème
  Future<bool> updateTheme(AppTheme theme) async {
    try {
      _currentSettings = getCurrentSettings().copyWith(
        theme: theme,
        lastUpdated: DateTime.now(),
      );
      await _saveSettings();
      return true;
    } catch (e) {
      debugPrint('Failed to update theme: $e');
      return false;
    }
  }

  // Mettre à jour la langue
  Future<bool> updateLanguage(AppLanguage language) async {
    try {
      _currentSettings = getCurrentSettings().copyWith(
        language: language,
        lastUpdated: DateTime.now(),
      );
      await _saveSettings();
      return true;
    } catch (e) {
      debugPrint('Failed to update language: $e');
      return false;
    }
  }

  // Mettre à jour les paramètres de notification
  Future<bool> updateNotificationSettings({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? projectUpdates,
    bool? groupInvitations,
    bool? commentReplies,
    bool? likesNotifications,
  }) async {
    try {
      _currentSettings = getCurrentSettings().copyWith(
        notificationsEnabled: notificationsEnabled,
        emailNotifications: emailNotifications,
        projectUpdates: projectUpdates,
        groupInvitations: groupInvitations,
        commentReplies: commentReplies,
        likesNotifications: likesNotifications,
        lastUpdated: DateTime.now(),
      );
      await _saveSettings();
      return true;
    } catch (e) {
      debugPrint('Failed to update notification settings: $e');
      return false;
    }
  }

  // Mettre à jour les paramètres de confidentialité
  Future<bool> updatePrivacySettings({
    bool? privacyMode,
    bool? showEmail,
    bool? showPhone,
    bool? allowCollaboration,
  }) async {
    try {
      _currentSettings = getCurrentSettings().copyWith(
        privacyMode: privacyMode,
        showEmail: showEmail,
        showPhone: showPhone,
        allowCollaboration: allowCollaboration,
        lastUpdated: DateTime.now(),
      );
      await _saveSettings();
      return true;
    } catch (e) {
      debugPrint('Failed to update privacy settings: $e');
      return false;
    }
  }

  // Réinitialiser les paramètres
  Future<bool> resetSettings() async {
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser == null) return false;

      _currentSettings = ProfileSettings(
        userId: currentUser.userId,
        lastUpdated: DateTime.now(),
      );
      await _saveSettings();
      return true;
    } catch (e) {
      debugPrint('Failed to reset settings: $e');
      return false;
    }
  }

  // Supprimer le compte (marquer pour suppression)
  Future<bool> requestAccountDeletion() async {
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser == null) return false;

      // Ici, on pourrait marquer le compte pour suppression
      // ou envoyer une demande à l'admin
      
      // Pour l'instant, on supprime juste les paramètres locaux
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);
      _currentSettings = null;
      
      return true;
    } catch (e) {
      debugPrint('Failed to request account deletion: $e');
      return false;
    }
  }

  // Déconnexion (nettoyer les paramètres)
  Future<void> logout() async {
    try {
      await _saveSettings(); // Sauvegarder avant de partir
      _currentSettings = null;
    } catch (e) {
      debugPrint('Failed to logout from settings service: $e');
    }
  }

  // Obtenir les paramètres par défaut pour un nouveau utilisateur
  static ProfileSettings getDefaultSettings(String userId) {
    return ProfileSettings(
      userId: userId,
      lastUpdated: DateTime.now(),
    );
  }
}