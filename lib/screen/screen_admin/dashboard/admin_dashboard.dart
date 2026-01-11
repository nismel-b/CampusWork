import 'package:flutter/material.dart';
import '../../../model/user.dart';
import '../../../components/components.dart';
import '../../../database/database_helper.dart';
import 'user_management_page.dart';
import 'statistics_page.dart';
import 'moderation_page.dart';
import 'announcements_page.dart';

class AdminDashboard extends StatefulWidget {
  final User currentUser;

  const AdminDashboard({super.key, required this.currentUser});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  int _totalUsers = 0;
  int _totalProjects = 0;
  int _totalPosts = 0;
  int _totalReports = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    try {
      final db = await DatabaseHelper.instance.database;
      
      final usersCount = await db.rawQuery('SELECT COUNT(*) as count FROM users');
      final projectsCount = await db.rawQuery('SELECT COUNT(*) as count FROM projects');
      final postsCount = await db.rawQuery('SELECT COUNT(*) as count FROM posts');
      final reportsCount = await db.rawQuery('SELECT COUNT(*) as count FROM reports');
      
      setState(() {
        _totalUsers = usersCount.first['count'] as int? ?? 0;
        _totalProjects = projectsCount.first['count'] as int? ?? 0;
        _totalPosts = postsCount.first['count'] as int? ?? 0;
        _totalReports = reportsCount.first['count'] as int? ?? 0;
      });
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingState(message: 'Chargement du tableau de bord...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Admin'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            CustomCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenue, ${widget.currentUser.firstName}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Administrateur système',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Cards
            Text(
              'Statistiques générales',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                InfoCard(
                  icon: Icons.people,
                  title: 'Utilisateurs',
                  value: _totalUsers.toString(),
                  iconColor: Colors.blue,
                ),
                InfoCard(
                  icon: Icons.folder,
                  title: 'Projets',
                  value: _totalProjects.toString(),
                  iconColor: Colors.green,
                ),
                InfoCard(
                  icon: Icons.post_add,
                  title: 'Publications',
                  value: _totalPosts.toString(),
                  iconColor: Colors.orange,
                ),
                InfoCard(
                  icon: Icons.flag,
                  title: 'Signalements',
                  value: _totalReports.toString(),
                  iconColor: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Management Section
            Text(
              'Gestion de la plateforme',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildManagementCard(
                  'Gestion des utilisateurs',
                  Icons.people_outline,
                  Colors.blue,
                  'Gérer les comptes utilisateurs',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserManagementPage(currentUser: widget.currentUser),
                    ),
                  ),
                ),
                _buildManagementCard(
                  'Statistiques détaillées',
                  Icons.bar_chart,
                  Colors.green,
                  'Voir les analyses complètes',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StatisticsPage(currentUser: widget.currentUser),
                    ),
                  ),
                ),
                _buildManagementCard(
                  'Modération',
                  Icons.gavel,
                  Colors.orange,
                  'Gérer les signalements',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModerationPage(currentUser: widget.currentUser),
                    ),
                  ),
                ),
                _buildManagementCard(
                  'Annonces',
                  Icons.campaign,
                  Colors.purple,
                  'Créer des annonces',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnnouncementsPage(currentUser: widget.currentUser),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap,
  ) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
