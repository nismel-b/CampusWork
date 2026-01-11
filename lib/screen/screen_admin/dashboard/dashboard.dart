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

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late User _admin;
  List<User> _pendingUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _admin = AuthService().currentUser!;
    _loadPendingUsers();
  }

  Future<void> _loadPendingUsers() async {
    setState(() => _isLoading = true);
    final users = await AuthService().getPendingUsers();
    setState(() {
      _pendingUsers = users;
      _isLoading = false;
    });
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
        _loadPendingUsers();
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
          _loadPendingUsers();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allProjects = ProjectService().getAllProjects();
    final courses = ProjectService().getAllCourses();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Future.delayed(Duration.zero, () async {
                    await AuthService().logout();
                    if (context.mounted) context.go('/');
                  });
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 12),
                    Text('Déconnexion'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(16),
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
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Administrateur système',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
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
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/projects'),
                  icon: const Icon(Icons.search),
                  label: const Text('Explorer tous les projets'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section Actions Administrateur
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Actions administrateur',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
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
                      icon: Icons.security,
                      title: 'Similarité',
                      subtitle: 'Détection plagiat',
                      color: Colors.red,
                      onTap: () => _showSimilarityCheck(),
                    ),
                    _buildActionCard(
                      icon: Icons.poll,
                      title: 'Sondages',
                      subtitle: 'Créer/Gérer',
                      color: Colors.teal,
                      onTap: () => _showSurveyManagement(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Gestion des Groupes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gestion des groupes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    CreateGroupIconButton(
                      currentUser: _admin,
                      onGroupCreated: () {
                        // Actualiser les données si nécessaire
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.group,
                        title: 'Groupes totaux',
                        value: '${GroupService().getAllGroups().length}',
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.group_add,
                        title: 'Groupes ouverts',
                        value: '${GroupService().getOpenGroups().length}',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _showGroupsManagement(),
                  icon: const Icon(Icons.manage_accounts),
                  label: const Text('Gérer tous les groupes'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Demandes d\'inscription',
                      style: Theme.of(context).textTheme.titleLarge,
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
              ),
              const SizedBox(height: 12),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_pendingUsers.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.green.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune demande en attente',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._pendingUsers.map((user) => Card(
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
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: Theme.of(context).textTheme.bodySmall,
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
                )),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Statistiques',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Cours disponibles: ${courses.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: courses.map((course) => Chip(
                    label: Text(course),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  )).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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
