import 'package:flutter/material.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/services/profile_settings_service.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/components/components.dart';

class ProfileSettingsPage extends StatefulWidget {
  final User currentUser;

  const ProfileSettingsPage({super.key, required this.currentUser});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ProfileSettingsService _settingsService = ProfileSettingsService();
  final AuthService _authService = AuthService();
  ProfileSettings? _settings;
  bool _isLoading = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentUser = widget.currentUser;
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      _settings = _settingsService.getCurrentSettings();
      // Refresh current user data
      _currentUser = await _authService.getUserById(widget.currentUser.userId);
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres du profil'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profil'),
            Tab(icon: Icon(Icons.palette), text: 'Apparence'),
            Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
            Tab(icon: Icon(Icons.privacy_tip), text: 'Confidentialité'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingState(message: 'Chargement des paramètres...')
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildAppearanceTab(),
                _buildNotificationsTab(),
                _buildPrivacyTab(),
              ],
            ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo de profil et informations de base
          Center(
            child: Column(
              children: [
                UserAvatar(
                  userId: (_currentUser ?? widget.currentUser).userId,
                  name: (_currentUser ?? widget.currentUser).fullName,
                ),
                const SizedBox(height: 16),
                Text(
                  (_currentUser ?? widget.currentUser).fullName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  (_currentUser ?? widget.currentUser).email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getRoleColor((_currentUser ?? widget.currentUser).userRole).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getRoleLabel((_currentUser ?? widget.currentUser).userRole),
                    style: TextStyle(
                      color: _getRoleColor((_currentUser ?? widget.currentUser).userRole),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Informations du profil
          _buildSectionTitle('Informations personnelles'),
          Card(
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.person,
                  title: 'Nom complet',
                  subtitle: (_currentUser ?? widget.currentUser).fullName,
                  onTap: () => _showEditDialog('Nom complet', (_currentUser ?? widget.currentUser).fullName, 'fullName'),
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  icon: Icons.alternate_email,
                  title: 'Nom d\'utilisateur',
                  subtitle: (_currentUser ?? widget.currentUser).username,
                  onTap: () => _showEditDialog('Nom d\'utilisateur', (_currentUser ?? widget.currentUser).username, 'username'),
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  icon: Icons.email,
                  title: 'Email',
                  subtitle: (_currentUser ?? widget.currentUser).email,
                  onTap: () => _showEditDialog('Email', (_currentUser ?? widget.currentUser).email, 'email'),
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  icon: Icons.phone,
                  title: 'Téléphone',
                  subtitle: (_currentUser ?? widget.currentUser).phonenumber,
                  onTap: () => _showEditDialog('Téléphone', (_currentUser ?? widget.currentUser).phonenumber, 'phone'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Actions du compte
          _buildSectionTitle('Actions du compte'),
          Card(
            child: Column(
              children: [
                _buildActionTile(
                  icon: Icons.lock,
                  title: 'Changer le mot de passe',
                  subtitle: 'Modifier votre mot de passe',
                  onTap: _showChangePasswordDialog,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.logout,
                  title: 'Déconnexion',
                  subtitle: 'Se déconnecter de l\'application',
                  onTap: _logout,
                  textColor: Colors.orange,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.delete_forever,
                  title: 'Supprimer le compte',
                  subtitle: 'Supprimer définitivement votre compte',
                  onTap: _showDeleteAccountDialog,
                  textColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Thème'),
          Card(
            child: Column(
              children: [
                RadioListTile<AppTheme>(
                  title: const Text('Clair'),
                  subtitle: const Text('Thème clair'),
                  value: AppTheme.light,
                  groupValue: _settings?.theme ?? AppTheme.system,
                  onChanged: (value) => _updateTheme(value!),
                  secondary: const Icon(Icons.light_mode),
                ),
                RadioListTile<AppTheme>(
                  title: const Text('Sombre'),
                  subtitle: const Text('Thème sombre'),
                  value: AppTheme.dark,
                  groupValue: _settings?.theme ?? AppTheme.system,
                  onChanged: (value) => _updateTheme(value!),
                  secondary: const Icon(Icons.dark_mode),
                ),
                RadioListTile<AppTheme>(
                  title: const Text('Système'),
                  subtitle: const Text('Suivre les paramètres du système'),
                  value: AppTheme.system,
                  groupValue: _settings?.theme ?? AppTheme.system,
                  onChanged: (value) => _updateTheme(value!),
                  secondary: const Icon(Icons.settings_system_daydream),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Langue'),
          Card(
            child: Column(
              children: [
                RadioListTile<AppLanguage>(
                  title: const Text('Français'),
                  subtitle: const Text('Interface en français'),
                  value: AppLanguage.french,
                  groupValue: _settings?.language ?? AppLanguage.french,
                  onChanged: (value) => _updateLanguage(value!),
                  secondary: const Text('🇫🇷', style: TextStyle(fontSize: 24)),
                ),
                RadioListTile<AppLanguage>(
                  title: const Text('English'),
                  subtitle: const Text('English interface'),
                  value: AppLanguage.english,
                  groupValue: _settings?.language ?? AppLanguage.french,
                  onChanged: (value) => _updateLanguage(value!),
                  secondary: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Notifications générales'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Activer les notifications'),
                  subtitle: const Text('Recevoir toutes les notifications'),
                  value: _settings?.notificationsEnabled ?? true,
                  onChanged: (value) => _updateNotificationSetting('general', value),
                  secondary: const Icon(Icons.notifications),
                ),
                SwitchListTile(
                  title: const Text('Notifications par email'),
                  subtitle: const Text('Recevoir les notifications par email'),
                  value: _settings?.emailNotifications ?? true,
                  onChanged: (value) => _updateNotificationSetting('email', value),
                  secondary: const Icon(Icons.email),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Notifications de contenu'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Mises à jour de projets'),
                  subtitle: const Text('Nouveaux projets et modifications'),
                  value: _settings?.projectUpdates ?? true,
                  onChanged: (value) => _updateNotificationSetting('projects', value),
                  secondary: const Icon(Icons.folder),
                ),
                SwitchListTile(
                  title: const Text('Invitations de groupe'),
                  subtitle: const Text('Invitations à rejoindre des groupes'),
                  value: _settings?.groupInvitations ?? true,
                  onChanged: (value) => _updateNotificationSetting('groups', value),
                  secondary: const Icon(Icons.group),
                ),
                SwitchListTile(
                  title: const Text('Réponses aux commentaires'),
                  subtitle: const Text('Réponses à vos commentaires'),
                  value: _settings?.commentReplies ?? true,
                  onChanged: (value) => _updateNotificationSetting('comments', value),
                  secondary: const Icon(Icons.comment),
                ),
                SwitchListTile(
                  title: const Text('Likes et réactions'),
                  subtitle: const Text('Likes sur vos projets et commentaires'),
                  value: _settings?.likesNotifications ?? false,
                  onChanged: (value) => _updateNotificationSetting('likes', value),
                  secondary: const Icon(Icons.favorite),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Visibilité du profil'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Mode privé'),
                  subtitle: const Text('Masquer votre profil aux autres utilisateurs'),
                  value: _settings?.privacyMode ?? false,
                  onChanged: (value) => _updatePrivacySetting('privacy', value),
                  secondary: const Icon(Icons.visibility_off),
                ),
                SwitchListTile(
                  title: const Text('Afficher l\'email'),
                  subtitle: const Text('Rendre votre email visible aux autres'),
                  value: _settings?.showEmail ?? true,
                  onChanged: (value) => _updatePrivacySetting('email', value),
                  secondary: const Icon(Icons.email),
                ),
                SwitchListTile(
                  title: const Text('Afficher le téléphone'),
                  subtitle: const Text('Rendre votre numéro visible aux autres'),
                  value: _settings?.showPhone ?? false,
                  onChanged: (value) => _updatePrivacySetting('phone', value),
                  secondary: const Icon(Icons.phone),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Collaboration'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Autoriser la collaboration'),
                  subtitle: const Text('Permettre aux autres de vous inviter sur leurs projets'),
                  value: _settings?.allowCollaboration ?? true,
                  onChanged: (value) => _updatePrivacySetting('collaboration', value),
                  secondary: const Icon(Icons.handshake),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Données et sécurité'),
          Card(
            child: Column(
              children: [
                _buildActionTile(
                  icon: Icons.download,
                  title: 'Télécharger mes données',
                  subtitle: 'Exporter toutes vos données personnelles',
                  onTap: _exportData,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.refresh,
                  title: 'Réinitialiser les paramètres',
                  subtitle: 'Remettre tous les paramètres par défaut',
                  onTap: _resetSettings,
                  textColor: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.edit),
      onTap: onTap,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.lecturer:
        return Colors.blue;
      case UserRole.student:
        return Colors.green;
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.lecturer:
        return 'Enseignant';
      case UserRole.student:
        return 'Étudiant';
    }
  }

  Future<void> _updateTheme(AppTheme theme) async {
    final success = await _settingsService.updateTheme(theme);
    if (success && mounted) {
      setState(() {
        _settings = _settings?.copyWith(theme: theme);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thème mis à jour')),
      );
    }
  }

  Future<void> _updateLanguage(AppLanguage language) async {
    final success = await _settingsService.updateLanguage(language);
    if (success && mounted) {
      setState(() {
        _settings = _settings?.copyWith(language: language);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Langue mise à jour')),
      );
    }
  }

  Future<void> _updateNotificationSetting(String type, bool value) async {
    Map<String, bool> updates = {};
    
    switch (type) {
      case 'general':
        updates['notificationsEnabled'] = value;
        break;
      case 'email':
        updates['emailNotifications'] = value;
        break;
      case 'projects':
        updates['projectUpdates'] = value;
        break;
      case 'groups':
        updates['groupInvitations'] = value;
        break;
      case 'comments':
        updates['commentReplies'] = value;
        break;
      case 'likes':
        updates['likesNotifications'] = value;
        break;
    }

    final success = await _settingsService.updateNotificationSettings(
      notificationsEnabled: updates['notificationsEnabled'],
      emailNotifications: updates['emailNotifications'],
      projectUpdates: updates['projectUpdates'],
      groupInvitations: updates['groupInvitations'],
      commentReplies: updates['commentReplies'],
      likesNotifications: updates['likesNotifications'],
    );

    if (success && mounted) {
      setState(() {
        _settings = _settings?.copyWith(
          notificationsEnabled: updates['notificationsEnabled'] ?? _settings?.notificationsEnabled,
          emailNotifications: updates['emailNotifications'] ?? _settings?.emailNotifications,
          projectUpdates: updates['projectUpdates'] ?? _settings?.projectUpdates,
          groupInvitations: updates['groupInvitations'] ?? _settings?.groupInvitations,
          commentReplies: updates['commentReplies'] ?? _settings?.commentReplies,
          likesNotifications: updates['likesNotifications'] ?? _settings?.likesNotifications,
        );
      });
    }
  }

  Future<void> _updatePrivacySetting(String type, bool value) async {
    Map<String, bool> updates = {};
    
    switch (type) {
      case 'privacy':
        updates['privacyMode'] = value;
        break;
      case 'email':
        updates['showEmail'] = value;
        break;
      case 'phone':
        updates['showPhone'] = value;
        break;
      case 'collaboration':
        updates['allowCollaboration'] = value;
        break;
    }

    final success = await _settingsService.updatePrivacySettings(
      privacyMode: updates['privacyMode'],
      showEmail: updates['showEmail'],
      showPhone: updates['showPhone'],
      allowCollaboration: updates['allowCollaboration'],
    );

    if (success && mounted) {
      setState(() {
        _settings = _settings?.copyWith(
          privacyMode: updates['privacyMode'] ?? _settings?.privacyMode,
          showEmail: updates['showEmail'] ?? _settings?.showEmail,
          showPhone: updates['showPhone'] ?? _settings?.showPhone,
          allowCollaboration: updates['allowCollaboration'] ?? _settings?.allowCollaboration,
        );
      });
    }
  }

  void _showEditDialog(String field, String currentValue, String fieldType) {
    final controller = TextEditingController(text: currentValue);
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier $field'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: field,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est requis';
              }
              
              if (fieldType == 'email') {
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Format d\'email invalide';
                }
              }
              
              if (fieldType == 'phone') {
                if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value.replaceAll(' ', ''))) {
                  return 'Format de téléphone invalide';
                }
              }
              
              return null;
            },
            keyboardType: fieldType == 'email' 
                ? TextInputType.emailAddress 
                : fieldType == 'phone' 
                    ? TextInputType.phone 
                    : TextInputType.text,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                await _updateProfile(fieldType, controller.text.trim());
              }
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(String fieldType, String newValue) async {
    try {
      setState(() => _isLoading = true);
      
      final currentUserId = (_currentUser ?? widget.currentUser).userId;
      bool success = false;
      
      switch (fieldType) {
        case 'fullName':
          // Split full name into first and last name
          final nameParts = newValue.split(' ');
          final firstName = nameParts.first;
          final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
          
          success = await _authService.updateUser(
            userId: currentUserId,
            firstname: firstName,
            lastname: lastName,
          );
          break;
          
        case 'username':
          success = await _authService.updateUsername(
            userId: currentUserId,
            newUsername: newValue,
          );
          break;
          
        case 'email':
          success = await _authService.updateUser(
            userId: currentUserId,
            email: newValue,
          );
          break;
          
        case 'phone':
          success = await _authService.updateUser(
            userId: currentUserId,
            phonenumber: newValue,
          );
          break;
      }
      
      if (success) {
        // Refresh user data
        _currentUser = await _authService.getUserById(currentUserId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$fieldType mis à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la mise à jour de $fieldType'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureOldPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Changer le mot de passe'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Ancien mot de passe',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscureOldPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setDialogState(() => obscureOldPassword = !obscureOldPassword),
                    ),
                  ),
                  obscureText: obscureOldPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ancien mot de passe requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setDialogState(() => obscureNewPassword = !obscureNewPassword),
                    ),
                  ),
                  obscureText: obscureNewPassword,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setDialogState(() => obscureConfirmPassword = !obscureConfirmPassword),
                    ),
                  ),
                  obscureText: obscureConfirmPassword,
                  validator: (value) {
                    if (value != newPasswordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  await _changePassword(
                    oldPasswordController.text,
                    newPasswordController.text,
                  );
                }
              },
              child: const Text('Changer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword(String oldPassword, String newPassword) async {
    try {
      setState(() => _isLoading = true);
      
      final success = await _authService.changePassword(
        userId: (_currentUser ?? widget.currentUser).userId,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
                ? 'Mot de passe changé avec succès' 
                : 'Erreur: ancien mot de passe incorrect'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error changing password: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du changement de mot de passe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService().logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _settingsService.requestAccountDeletion();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success 
                        ? 'Demande de suppression envoyée'
                        : 'Erreur lors de la demande'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export des données'),
        content: const Text(
          'Cette fonctionnalité permettra d\'exporter toutes vos données personnelles au format JSON. '
          'Cela inclut votre profil, vos projets, commentaires et paramètres.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export des données - Fonctionnalité à venir'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Exporter'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les paramètres'),
        content: const Text('Voulez-vous remettre tous les paramètres par défaut ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _settingsService.resetSettings();
      if (success && mounted) {
        await _loadSettings();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paramètres réinitialisés')),
        );
      }
    }
  }
}