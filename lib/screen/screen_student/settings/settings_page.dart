import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuswork/auth/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _darkMode = false;
  String _language = 'Français';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          // Section Notifications
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Notifications push'),
            subtitle: const Text('Recevoir des notifications sur l\'appareil'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          SwitchListTile(
            title: const Text('Notifications par email'),
            subtitle: const Text('Recevoir des notifications par email'),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() => _emailNotifications = value);
            },
          ),
          
          const Divider(),
          
          // Section Apparence
          _buildSectionHeader('Apparence'),
          SwitchListTile(
            title: const Text('Mode sombre'),
            subtitle: const Text('Utiliser le thème sombre'),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
              // TODO: Implémenter le changement de thème
            },
          ),
          ListTile(
            title: const Text('Langue'),
            subtitle: Text(_language),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showLanguageDialog();
            },
          ),
          
          const Divider(),
          
          // Section Compte
          _buildSectionHeader('Compte'),
          ListTile(
            title: const Text('Changer le mot de passe'),
            leading: const Icon(Icons.lock),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showChangePasswordDialog();
            },
          ),
          ListTile(
            title: const Text('Supprimer le compte'),
            leading: const Icon(Icons.delete, color: Colors.red),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),
          
          const Divider(),
          
          // Section À propos
          _buildSectionHeader('À propos'),
          ListTile(
            title: const Text('Version de l\'application'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info),
          ),
          ListTile(
            title: const Text('Conditions d\'utilisation'),
            leading: const Icon(Icons.description),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Ouvrir les conditions d'utilisation
            },
          ),
          ListTile(
            title: const Text('Politique de confidentialité'),
            leading: const Icon(Icons.privacy_tip),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Ouvrir la politique de confidentialité
            },
          ),
          
          const SizedBox(height: 32),
          
          // Bouton de déconnexion
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Se déconnecter'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Français'),
              value: 'Français',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Ancien mot de passe',
                ),
                obscureText: true,
                validator: (value) => value?.isEmpty == true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                ),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Requis';
                  if (value!.length < 6) return 'Au moins 6 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                ),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Requis';
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
                final success = await AuthService().changePassword(
                  userId: AuthService().currentUser!.userId,
                  oldPassword: oldPasswordController.text,
                  newPassword: newPasswordController.text,
                );
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success 
                        ? 'Mot de passe changé avec succès'
                        : 'Erreur lors du changement de mot de passe'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Changer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer votre compte ? '
          'Cette action est irréversible et toutes vos données seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Implémenter la suppression du compte
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité non encore implémentée'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService().logout();
              if (mounted) {
                context.go('/');
              }
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}