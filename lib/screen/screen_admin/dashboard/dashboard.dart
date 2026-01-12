import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/services/notification_services.dart';
import 'package:campuswork/services/group_service.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/components/user_avatar.dart';
import 'package:campuswork/screen/groups/create_group_button.dart';
import 'package:campuswork/screen/groups/groups_list.dart';
import 'package:campuswork/screen/surveys/create_survey_page.dart';
import 'package:campuswork/screen/screen_student/dashboard/surveys_screen.dart';
import 'package:campuswork/widgets/sync_test_widget.dart';
import 'package:campuswork/services/tutorial_service.dart';
import 'package:campuswork/auth/register_page.dart';
import 'package:campuswork/components/app_logo.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late User _admin;
  List<User> _pendingUsers = [];
  bool _isLoading = true;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _admin = AuthService().currentUser!;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Charger les utilisateurs en attente
      final users = await AuthService().getPendingUsers();
      
      // Charger le nombre de notifications non lues
      final count = NotificationService().getUnreadCountByUser(_admin.userId);
      
      setState(() {
        _pendingUsers = users;
        _unreadNotifications = count;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des données admin: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveUser(User user) async {
    final success = await AuthService().approveUser(user.userId);
    if (success) {
      await NotificationService().createApprovalNotification(user.userId, true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.fullName} approuvé'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    }
  }

  Future<void> _rejectUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le rejet'),
        content: Text('Êtes-vous sûr de vouloir rejeter la demande de ${user.fullName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await AuthService().rejectUser(user.userId);
      if (success) {
        await NotificationService().createApprovalNotification(user.userId, false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.fullName} rejeté'),
              backgroundColor: Colors.red,
            ),
          );
          _loadData();
        }
      }
    }
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'profile':
        context.push('/profile');
        break;
      case 'settings':
        context.push('/settings');
        break;
      case 'logout':
        _logout();
        break;
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête de bienvenue
                    _buildWelcomeHeader(),
                    const SizedBox(height: 24),
                    
                    // Statistiques rapides
                    _buildQuickStats(),
                    const SizedBox(height: 24),
                    
                    // Actions administrateur
                    _buildAdminActions(),
                    const SizedBox(height: 24),
                    
                    // Demandes d'inscription
                    _buildPendingUsers(),
                    const SizedBox(height: 24),
                    
                    // Statistiques détaillées
                    _buildDetailedStats(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour, ${_admin.firstName} 👋',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Administrateur système',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final allProjects = ProjectService().getAllProjects();
    final allGroups = GroupService().getAllGroups();
    
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.pending,
            title: 'En attente',
            value: '${_pendingUsers.length}',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.folder,
            title: 'Projets',
            value: '${allProjects.length}',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.group,
            title: 'Groupes',
            value: '${allGroups.length}',
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildAdminActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions administrateur',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              icon: Icons.people,
              title: 'Gestion utilisateurs',
              subtitle: 'Approuver/Rejeter',
              color: Colors.blue,
              onTap: () => _showUserManagement(),
            ),
            _buildActionCard(
              icon: Icons.folder,
              title: 'Tous les projets',
              subtitle: 'Consulter/Modérer',
              color: Colors.green,
              onTap: () => context.push('/projects'),
            ),
            _buildActionCard(
              icon: Icons.group,
              title: 'Gestion groupes',
              subtitle: 'Créer/Gérer',
              color: Colors.purple,
              onTap: () => _showGroupsManagement(),
            ),
            _buildActionCard(
              icon: Icons.analytics,
              title: 'Statistiques',
              subtitle: 'Rapports système',
              color: Colors.orange,
              onTap: () => _showStatistics(),
            ),
            _buildActionCard(
              icon: Icons.person_add,
              title: 'Ajouter utilisateur',
              subtitle: 'Enregistrer nouveau',
              color: Colors.indigo,
              onTap: () => _showUserRegistration(),
            ),
            _buildActionCard(
              icon: Icons.refresh,
              title: 'Reset Tutoriels',
              subtitle: 'Réinitialiser tutoriels',
              color: Colors.amber,
              onTap: () => _resetTutorials(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPendingUsers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Demandes d\'inscription',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_pendingUsers.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_pendingUsers.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_pendingUsers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucune demande en attente',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Toutes les demandes ont été traitées',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.green.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          )
        else
          ...(_pendingUsers.map((user) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  UserAvatar(
                    userId: user.userId,
                    name: user.fullName, 
                    size: 48,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.userRole.name.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _approveUser(user),
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    tooltip: 'Approuver',
                  ),
                  IconButton(
                    onPressed: () => _rejectUser(user),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    tooltip: 'Rejeter',
                  ),
                ],
              ),
            ),
          ))),
      ],
    );
  }

  Widget _buildDetailedStats() {
    final allProjects = ProjectService().getAllProjects();
    final courses = ProjectService().getAllCourses();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques détaillées',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cours disponibles: ${courses.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (courses.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: courses.map((course) => Chip(
                      label: Text(course),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    )).toList(),
                  )
                else
                  Text(
                    'Aucun cours disponible',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showGroupsManagement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gestion des groupes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                CreateGroupIconButton(
                  currentUser: _admin,
                  onGroupCreated: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: GroupsList(
                currentUser: _admin,
                showOnlyUserGroups: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserManagement() {
    // Afficher la gestion des utilisateurs (déjà implémentée dans les demandes d'inscription)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voir les demandes d\'inscription ci-dessous')),
    );
  }

  void _showStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistiques système'),
        content: FutureBuilder<Map<String, int>>(
          future: _getSystemStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final stats = snapshot.data ?? {};
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatRow('Utilisateurs totaux', '${stats['users'] ?? 0}'),
                _buildStatRow('Projets totaux', '${ProjectService().getAllProjects().length}'),
                _buildStatRow('Groupes totaux', '${GroupService().getAllGroups().length}'),
                _buildStatRow('Demandes en attente', '${_pendingUsers.length}'),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, int>> _getSystemStats() async {
    try {
      final students = await AuthService().getAllStudents();
      final lecturers = await AuthService().getAllLecturers();
      final totalUsers = students.length + lecturers.length + 1; // +1 for admin
      
      return {
        'users': totalUsers,
      };
    } catch (e) {
      debugPrint('Error getting system stats: $e');
      return {'users': 0};
    }
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showSimilarityCheck() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Outil de détection de similarité - À implémenter')),
    );
  }

  void _showSurveyManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSurveyPage(currentUser: _admin),
      ),
    );
  }

  void _showUserRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterPage(),
      ),
    ).then((_) {
      // Recharger les utilisateurs en attente après l'enregistrement
      _loadData();
    });
  }

  void _showSyncTest() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sync, color: Color(0xFF4A90E2)),
                  const SizedBox(width: 12),
                  const Text(
                    'Test de Synchronisation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SyncTestWidget(currentUser: _admin),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetTutorials() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les tutoriels'),
        content: const Text(
          'Êtes-vous sûr de vouloir réinitialiser tous les tutoriels ? '
          'Les utilisateurs devront refaire le tutoriel à leur prochaine connexion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await TutorialService.resetAllTutorials();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Tutoriels réinitialisés avec succès'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la réinitialisation: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
