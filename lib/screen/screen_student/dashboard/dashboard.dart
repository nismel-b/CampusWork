import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/services/notification_services.dart';
import 'package:campuswork/model/student.dart';
import 'package:campuswork/components/components.dart';
import 'package:campuswork/screen/screen_student/projects/project_card.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with SingleTickerProviderStateMixin {
  late Student _student;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  int _unreadNotifications = 0;
  int _selectedTabIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _student = AuthService().currentUser as Student;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    final count = NotificationService().getUnreadCountByUser(_student.userId);
    setState(() {
      _unreadNotifications = count;
      _isLoading = false;
    });
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Actions rapides',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _QuickActionTile(
                  icon: Icons.add_circle_outline,
                  label: 'Nouveau\nProjet',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/create-project');
                  },
                ),
                _QuickActionTile(
                  icon: Icons.folder_open,
                  label: 'Mes\nProjets',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/my-projects');
                  },
                ),
                _QuickActionTile(
                  icon: Icons.explore,
                  label: 'Explorer',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/projects');
                  },
                ),
                _QuickActionTile(
                  icon: Icons.people_outline,
                  label: 'Équipe',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/team');
                  },
                ),
                _QuickActionTile(
                  icon: Icons.school,
                  label: 'Cours',
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/courses');
                  },
                ),
                _QuickActionTile(
                  icon: Icons.settings,
                  label: 'Paramètres',
                  color: Colors.grey,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/settings');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingState(message: 'Chargement de votre dashboard...'),
      );
    }

    final myProjects = ProjectService().getProjectsByStudent(_student.userId);
    final recentProjects = ProjectService().getAllProjects().take(5).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar dynamique
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            children: [
                              UserAvatar(
                                name: _student.fullName,
                                size: 56,
                                showBadge: true,
                                badgeColor: Colors.green,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bonjour 👋',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      _student.firstName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        StatusBadge(
                          label: '${_student.level} • ${_student.filiere}',
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              NotificationBell(
                notificationCount: _unreadNotifications,
                onPressed: () => context.push('/notifications'),
              ),
              UserAvatarMenu(
                name: _student.fullName,
                email: _student.email,
                menuItems: [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 12),
                        Text('Mon profil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 12),
                        Text('Paramètres'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Déconnexion', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onMenuItemSelected: (value) async {
                  switch (value) {
                    case 'profile':
                      context.push('/profile');
                      break;
                    case 'settings':
                      context.push('/settings');
                      break;
                    case 'logout':
                      await AuthService().logout();
                      if (mounted) context.go('/');
                      break;
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Contenu principal
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Statistiques en grille
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _AnimatedStatCard(
                          icon: Icons.folder_open,
                          title: 'Projets',
                          value: '${myProjects.length}',
                          color: Colors.blue,
                          delay: 0,
                        ),
                        _AnimatedStatCard(
                          icon: Icons.grade,
                          title: 'Moyenne',
                          value: _calculateAverage(myProjects),
                          color: Colors.amber,
                          delay: 100,
                        ),
                        _AnimatedStatCard(
                          icon: Icons.check_circle_outline,
                          title: 'Terminés',
                          value: '${myProjects.where((p) => p.status == 'completed').length}',
                          color: Colors.green,
                          delay: 200,
                        ),
                        _AnimatedStatCard(
                          icon: Icons.timer_outlined,
                          title: 'En cours',
                          value: '${myProjects.where((p) => p.status == 'in_progress').length}',
                          color: Colors.orange,
                          delay: 300,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Actions rapides
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _ActionButton(
                            label: 'Nouveau projet',
                            icon: Icons.add_circle,
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.blue.shade700],
                            ),
                            onTap: () => context.push('/create-project'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            label: 'Plus',
                            icon: Icons.apps,
                            gradient: LinearGradient(
                              colors: [Colors.grey.shade700, Colors.grey.shade900],
                            ),
                            onTap: _showQuickActions,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Tabs pour filtrer le contenu
                  _CustomTabBar(
                    selectedIndex: _selectedTabIndex,
                    onChanged: (index) => setState(() => _selectedTabIndex = index),
                  ),

                  const SizedBox(height: 16),

                  // Contenu selon l'onglet sélectionné
                  if (_selectedTabIndex == 0) ...[
                    _buildMyProjectsSection(myProjects),
                  ] else if (_selectedTabIndex == 1) ...[
                    _buildRecentProjectsSection(recentProjects),
                  ] else ...[
                    _buildFavoritesSection(),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-project'),
        icon: const Icon(Icons.add),
        label: const Text('Créer'),
      ),
    );
  }

  Widget _buildMyProjectsSection(List<dynamic> myProjects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes projets',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${myProjects.length} projet${myProjects.length > 1 ? 's' : ''}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              if (myProjects.length > 3)
                TextButton.icon(
                  onPressed: () => context.push('/my-projects'),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Voir tout'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (myProjects.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: EmptyState(
              icon: Icons.folder_open,
              title: 'Aucun projet',
              message: 'Créez votre premier projet pour commencer',
              actionLabel: 'Créer un projet',
              onAction: () => context.push('/create-project'),
            ),
          )
        else
          ...myProjects.take(3).map((project) =>
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ProjectCard(project: project),
              ),
          ),
      ],
    );
  }

  Widget _buildRecentProjectsSection(List<dynamic> recentProjects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Projets récents',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Découvrez les derniers projets',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...recentProjects.map((project) =>
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ProjectCard(project: project),
            ),
        ),
      ],
    );
  }

  Widget _buildFavoritesSection() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: EmptyState(
        icon: Icons.favorite_border,
        title: 'Aucun favori',
        message: 'Ajoutez des projets à vos favoris pour les retrouver ici',
      ),
    );
  }

  String _calculateAverage(List<dynamic> projects) {
    final gradedProjects = projects.where((p) => p.grade != null).toList();
    if (gradedProjects.isEmpty) return '-';
    final sum = gradedProjects.fold<double>(0, (sum, p) => sum + p.grade!);
    final average = sum / gradedProjects.length;
    return average.toStringAsFixed(1);
  }
}

// Composants personnalisés

class _AnimatedStatCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final int delay;

  const _AnimatedStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.delay,
  });

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(widget.icon, color: widget.color, size: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;

  const _CustomTabBar({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _TabItem(
            label: 'Mes projets',
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          const SizedBox(width: 12),
          _TabItem(
            label: 'Récents',
            isSelected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
          const SizedBox(width: 12),
          _TabItem(
            label: 'Favoris',
            isSelected: selectedIndex == 2,
            onTap: () => onChanged(2),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}