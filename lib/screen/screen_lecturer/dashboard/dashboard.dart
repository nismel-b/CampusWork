import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/services/notification_services.dart';
import 'package:campuswork/services/group_service.dart';
import 'package:campuswork/model/lecturer.dart';
import 'package:campuswork/model/project.dart';
import 'package:campuswork/components/components.dart';
import 'package:campuswork/screen/groups/create_group_button.dart';
import 'package:campuswork/screen/groups/groups_list.dart';
import 'package:campuswork/screen/surveys/create_survey_page.dart';
import 'package:campuswork/screen/screen_student/dashboard/surveys_screen.dart';
import 'package:campuswork/screen/screen_lecturer/comments/my_comments_page.dart';
import 'package:campuswork/screen/screen_lecturer/similarity/similarity_check_page.dart';

class LecturerDashboard extends StatefulWidget {
  const LecturerDashboard({super.key});

  @override
  State<LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  late Lecturer _lecturer;
  int _unreadNotifications = 0;
  String? _selectedCourse;

  @override
  void initState() {
    super.initState();
    _lecturer = AuthService().currentUser as Lecturer;
    _loadUnreadCount();
  }

  void _loadUnreadCount() {
    final count = NotificationService().getUnreadCountByUser(_lecturer.userId);
    setState(() => _unreadNotifications = count);
  }

  @override
  Widget build(BuildContext context) {
    final allProjects = ProjectService().getAllProjects();
    final courses = ProjectService().getAllCourses();

    final filteredProjects = _selectedCourse == null
        ? allProjects
        : allProjects.where((p) => p.courseName == _selectedCourse).toList();

    final pendingEval = filteredProjects.where((p) => p.state == 'termine' && (p.grade == null || p.grade!.isEmpty)).length;
    final evaluated = filteredProjects.where((p) => p.grade != null && p.grade!.isNotEmpty).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Enseignant'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 12),
                    Text('Profil'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 12),
                    Text('Paramètres'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 12),
                    Text('Déconnexion'),
                  ],
                ),
              ),
            ],
            onSelected: (String value) async {
              switch (value) {
                case 'profile':
                case 'settings':
                  context.push('/profile-settings', extra: _lecturer);
                  break;
                case 'logout':
                  await AuthService().logout();
                  if (context.mounted) context.go('/');
                  break;
              }
            },
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
                      'Bonjour, ${_lecturer.firstName} 👋',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_lecturer.uniteDenseignement} • ${_lecturer.section}',
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
                        icon: Icons.pending_actions,
                        title: 'À évaluer',
                        value: '$pendingEval',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle,
                        title: 'Évalués',
                        value: '$evaluated',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Actions Enseignant
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Actions enseignant',
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
                      icon: Icons.folder,
                      title: 'Consulter projets',
                      subtitle: 'Voir tous les projets',
                      color: Colors.blue,
                      onTap: () => context.push('/projects'),
                    ),
                    _buildActionCard(
                      icon: Icons.grade,
                      title: 'Noter projets',
                      subtitle: 'Évaluer les projets',
                      color: Colors.green,
                      onTap: () => _showProjectsToGrade(),
                    ),
                    _buildActionCard(
                      icon: Icons.group,
                      title: 'Créer groupes',
                      subtitle: 'Gérer les groupes',
                      color: Colors.purple,
                      onTap: () => _showGroupManagement(),
                    ),
                    _buildActionCard(
                      icon: Icons.comment,
                      title: 'Mes commentaires',
                      subtitle: 'Voir mes commentaires',
                      color: Colors.orange,
                      onTap: () => _showCommentingInterface(),
                    ),
                    _buildActionCard(
                      icon: Icons.security,
                      title: 'Vérifier similarité',
                      subtitle: 'Détecter plagiat',
                      color: Colors.red,
                      onTap: () => _showSimilarityCheck(),
                    ),
                    _buildActionCard(
                      icon: Icons.poll,
                      title: 'Créer sondages',
                      subtitle: 'Sondages étudiants',
                      color: Colors.teal,
                      onTap: () => _showSurveyCreation(),
                    ),
                    _buildActionCard(
                      icon: Icons.analytics,
                      title: 'Voir sondages',
                      subtitle: 'Gérer les sondages',
                      color: Colors.indigo,
                      onTap: () => _showSurveyManagement(),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Filtrer par cours',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Tous'),
                      selected: _selectedCourse == null,
                      onSelected: (selected) {
                        setState(() => _selectedCourse = null);
                      },
                    ),
                    const SizedBox(width: 8),
                    ...courses.map((course) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(course),
                        selected: _selectedCourse == course,
                        onSelected: (selected) {
                          setState(() => _selectedCourse = selected ? course : null);
                        },
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Projets à évaluer',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ...filteredProjects
                  .where((p) => p.state == 'termine' && (p.grade == null || p.grade!.isEmpty))
                  .take(5)
                  .map((project) => ProjectCard(
                    title: project.projectName,
                    description: project.description,
                    imageUrl: project.imageUrl,
                    tags: [project.courseName, project.state],
                  )),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Tous les projets',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ...filteredProjects.take(5).map((project) => ProjectCard(
                title: project.projectName,
                description: project.description,
                imageUrl: project.imageUrl,
                tags: [project.courseName, project.state],
              )),
              const SizedBox(height: 24),
            ],
          ),
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

  void _showProjectsToGrade() {
    final allProjects = ProjectService().getAllProjects();
    final projectsToGrade = allProjects.where((p) => p.state == 'termine' && (p.grade == null || p.grade!.isEmpty)).toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Projets à évaluer (${projectsToGrade.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            Expanded(
              child: projectsToGrade.isEmpty
                  ? const Center(child: Text('Aucun projet à évaluer'))
                  : ListView.builder(
                      itemCount: projectsToGrade.length,
                      itemBuilder: (context, index) {
                        final project = projectsToGrade[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ProjectCard(
                            title: project.projectName,
                            description: project.description,
                            imageUrl: project.imageUrl,
                            tags: [project.courseName, project.state],
                            onTap: () {
                              Navigator.pop(context);
                              _showGradingDialog(project);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGradingDialog(Project project) {
    final gradeController = TextEditingController();
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Évaluer: ${project.projectName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gradeController,
              decoration: const InputDecoration(
                labelText: 'Note (sur 20)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Commentaire',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final grade = gradeController.text.trim();
              final comment = commentController.text.trim();
              
              if (grade.isNotEmpty) {
                await ProjectService().evaluateProject(project.projectId!, grade, comment);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Projet évalué avec succès')),
                );
                setState(() {}); // Refresh
              }
            },
            child: const Text('Évaluer'),
          ),
        ],
      ),
    );
  }

  void _showGroupManagement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gestion des groupes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                CreateGroupIconButton(
                  currentUser: _lecturer,
                  onGroupCreated: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: GroupsList(
                currentUser: _lecturer,
                showOnlyUserGroups: true, // Enseignant voit ses groupes
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentingInterface() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyCommentsPage(currentUser: _lecturer),
      ),
    );
  }

  void _showSimilarityCheck() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimilarityCheckPage(currentUser: _lecturer),
      ),
    );
  }

  void _showSurveyCreation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSurveyPage(currentUser: _lecturer),
      ),
    );
  }

  void _showSurveyManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurveysScreen(currentUser: _lecturer),
      ),
    );
  }

  void _showStatistics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Statistiques - Fonctionnalité à venir')),
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
