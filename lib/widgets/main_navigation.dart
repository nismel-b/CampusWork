import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/screen/home/home_page.dart';
import 'package:campuswork/screen/messages/messages_page.dart';
import 'package:campuswork/screen/screen_student/dashboard/dashboard.dart';
import 'package:campuswork/screen/screen_lecturer/dashboard/dashboard.dart';
import 'package:campuswork/screen/screen_admin/dashboard/dashboard.dart';
import 'package:campuswork/components/notifications_bell.dart';
import 'package:campuswork/services/notification_services.dart';


class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    _setupNavigation();
  }

  void _setupNavigation() {
    final currentUser = AuthService().currentUser;
    if (currentUser == null) return;

    // Pages communes à tous les utilisateurs
    _pages = [
      const HomePage(), // Accueil
      _getDashboardForUser(currentUser), // Dashboard spécifique au rôle
      const MessagesPage(), // Messages
    ];

    // Navigation items
    _navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Accueil',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.dashboard_outlined),
        activeIcon: const Icon(Icons.dashboard),
        label: _getDashboardLabel(currentUser.userRole),
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.message_outlined),
        activeIcon: Icon(Icons.message),
        label: 'Messages',
      ),
    ];
  }

  Widget _getDashboardForUser(User user) {
    switch (user.userRole) {
      case UserRole.student:
        return const StudentDashboard();
      case UserRole.lecturer:
        return const LecturerDashboard();
      case UserRole.admin:
        return const AdminDashboard();
      default:
        return const StudentDashboard();
    }
  }

  String _getDashboardLabel(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Mes Projets';
      case UserRole.lecturer:
        return 'Enseignement';
      case UserRole.admin:
        return 'Administration';
      default:
        return 'Dashboard';
    }
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Accueil';
      case 1:
        final currentUser = AuthService().currentUser;
        if (currentUser != null) {
          switch (currentUser.userRole) {
            case UserRole.student:
              return 'Mes Projets';
            case UserRole.lecturer:
              return 'Tableau de bord Enseignant';
            case UserRole.admin:
              return 'Administration';
            default:
              return 'Dashboard';
          }
        }
        return 'Dashboard';
      case 2:
        return 'Messages';
      default:
        return 'CampusWork';
    }
  }

  List<Widget> _getAppBarActions() {
    final currentUser = AuthService().currentUser;
    if (currentUser == null) return [];

    switch (_currentIndex) {
      case 0: // Accueil
        return [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Activer la recherche dans la page d'accueil
              // Cette fonctionnalité sera implémentée dans HomePage
            },
          ),
          NotificationBell(
            notificationCount: NotificationService().getUnreadCountByUser(currentUser.userId),
            onPressed: () {
              context.push('/notifications');
            },
          ),
          _buildProfileMenu(),
        ];
      case 1: // Dashboard
        List<Widget> actions = [
          NotificationBell(
            notificationCount: NotificationService().getUnreadCountByUser(currentUser.userId),
            onPressed: () {
              context.push('/notifications');
            },
          ),
        ];
        
        // Actions spécifiques selon le rôle
        switch (currentUser.userRole) {
          case UserRole.lecturer:
            actions.insert(0, IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Créer un nouveau projet ou cours
              },
            ));
            break;
          case UserRole.admin:
            actions.insert(0, IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                // Outils d'administration
              },
            ));
            break;
          case UserRole.student:
            actions.insert(0, IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Créer un nouveau projet
              },
            ));
            break;
        }
        
        actions.add(_buildProfileMenu());
        return actions;
        
      case 2: // Messages
        return [
          NotificationBell(
            notificationCount: NotificationService().getUnreadCountByUser(currentUser.userId),
            onPressed: () {
              context.push('/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Nouveau message - cette fonctionnalité existe déjà dans MessagesPage
              _showNewMessageDialog();
            },
          ),
          _buildProfileMenu(),
        ];
      default:
        return [_buildProfileMenu()];
    }
  }

  void _showNewMessageDialog() {
    // Appeler directement la méthode de la page des messages
    final messagesPageState = (_pages[2] as MessagesPage);
    // Pour l'instant, on affiche juste un snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appuyez sur le bouton + dans l\'onglet Messages pour créer un nouveau message'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildProfileMenu() {
    final currentUser = AuthService().currentUser;
    if (currentUser == null) return const SizedBox();

    return PopupMenuButton<String>(
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          currentUser.firstName.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onSelected: (value) {
        switch (value) {
          case 'profile':
            // Navigation vers le profil selon le rôle
            switch (currentUser.userRole) {
              case UserRole.student:
                context.push('/profile');
                break;
              case UserRole.lecturer:
              case UserRole.admin:
                context.push('/profile-settings');
                break;
            }
            break;
          case 'settings':
            context.push('/settings');
            break;
          case 'logout':
            _logout();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person_outline),
              const SizedBox(width: 12),
              Text('Profil'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings_outlined),
              const SizedBox(width: 12),
              Text('Paramètres'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, color: Colors.red),
              const SizedBox(width: 12),
              Text('Déconnexion', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await AuthService().logout();
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Utilisateur non connecté')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // child: Image.asset('assets/image/logo_campuswork.jpg'),
            const SizedBox(width: 12),
            Text(_getAppBarTitle()),
          ],
        ),
        actions: _getAppBarActions(),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          items: _navItems,
        ),
      ),
    );
  }
}