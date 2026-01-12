import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/services/notification_services.dart';
import 'package:campuswork/model/student.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/components/components.dart';
import 'package:campuswork/screen/groups/groups_list.dart';
import 'package:campuswork/screen/collaboration/collaboration_requests_page.dart';
import 'package:campuswork/theme/theme.dart';
import 'package:campuswork/widgets/sync_test_widget.dart';
import 'package:campuswork/utils/responsive_helper.dart';
import 'package:campuswork/components/app_logo.dart';


class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> 
    with TickerProviderStateMixin {
  late User _student;
  late AnimationController _animController;
  late AnimationController _headerAnimController;
  late AnimationController _cardAnimController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _unreadNotifications = 0;
  int _selectedTabIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final currentUser = AuthService().currentUser;
    if (currentUser != null && currentUser.userRole == UserRole.student) {
      _student = currentUser;
    } else {
      // Handle case where user is not a Student
      debugPrint('❌ Current user is not a Student: ${currentUser?.userRole}');
      // You might want to navigate back or show an error
      return;
    }
    
    // Initialize animation controllers
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Initialize animations
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOutCubic,
    );
    
    _cardAnimation = CurvedAnimation(
      parent: _cardAnimController,
      curve: Curves.elasticOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    _headerAnimController.dispose();
    _cardAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Start header animation
    _headerAnimController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    final count = NotificationService().getUnreadCountByUser(_student.userId);
    
    setState(() {
      _unreadNotifications = count;
      _isLoading = false;
    });
    
    // Start main content animations
    _animController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _cardAnimController.forward();
  }

  // Méthode utilitaire pour obtenir les informations d'étudiant de manière sûre
  String _getStudentInfo() {
    // Si on a accès aux informations spécifiques d'étudiant, on les utilise
    // Sinon, on retourne une valeur par défaut
    try {
      if (_student is Student) {
        final student = _student as Student;
        return '${student.level} • ${student.filiere}';
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'accès aux informations étudiant: $e');
    }
    return 'Étudiant • Informatique';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 24),
                Text(
                  'Chargement de votre dashboard...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final myProjects = ProjectService().getProjectsByStudent(_student.userId);
    final recentProjects = ProjectService().getAllProjects().take(5).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Modern Header
            _buildModernHeader(),
            
            // Main Content
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 32),
                        
                        // Quick Stats Cards
                        _buildQuickStats(myProjects),
                        
                        const SizedBox(height: 32),
                        
                        // Quick Actions
                        _buildQuickActions(),
                        
                        const SizedBox(height: 32),
                        
                        // Content Tabs
                        _buildContentTabs(),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Tab Content as separate sliver
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildTabContent(myProjects, recentProjects),
                ),
              ),
            ),
            
            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _cardAnimation,
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await context.push('/create-project');
            if (result == true) {
              setState(() {}); // Rafraîchir le dashboard
            }
          },
          backgroundColor: const Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Nouveau projet'),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: _headerAnimation,
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row with Avatar and Notifications
                    Row(
                      children: [
                        // Animated Avatar amélioré
                        ScaleTransition(
                          scale: _headerAnimation,
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: const LinearGradient(
                                colors: [Colors.white, Color(0xFFF0F4F8)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(-3, -3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 34,
                              color: Color(0xFF4A90E2),
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Logo de l'app
                        AppLogo.small(),
                        
                        const SizedBox(width: 16),
                        
                        // Notification Bell amélioré
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(_headerAnimation),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              onPressed: () => context.push('/notifications'),
                              icon: Stack(
                                children: [
                                  const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                  if (_unreadNotifications > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.red.withOpacity(0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          '$_unreadNotifications',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 36),
                    
                    // Welcome Text amélioré
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-0.5, 0),
                        end: Offset.zero,
                      ).animate(_headerAnimation),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bonjour 👋',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _student.firstName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.school,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getStudentInfo(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.more_vert, color: Colors.white),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: (value) async {
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
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person, color: Color(0xFF4A90E2)),
                  SizedBox(width: 12),
                  Text('Mon profil'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: Color(0xFF6B7280)),
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
        ),
      ],
    );
  }

  Widget _buildQuickStats(List<dynamic> myProjects) {
    return ResponsiveGrid(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      mobileColumns: 2,
      tabletColumns: 4,
      desktopColumns: 4,
      mobileAspectRatio: 1.3,
      tabletAspectRatio: 1.2,
      desktopAspectRatio: 1.1,
      children: [
          _ModernStatCard(
            icon: Icons.folder_open,
            title: 'Projets',
            value: '${myProjects.length}',
            color: const Color(0xFF4A90E2),
            animation: _cardAnimation,
            delay: 0,
          ),
          _ModernStatCard(
            icon: Icons.grade,
            title: 'Moyenne',
            value: _calculateAverage(myProjects),
            color: const Color(0xFFF59E0B),
            animation: _cardAnimation,
            delay: 100,
          ),
          _ModernStatCard(
            icon: Icons.check_circle_outline,
            title: 'Terminés',
            value: '${myProjects.where((p) => p.status == 'completed').length}',
            color: const Color(0xFF10B981),
            animation: _cardAnimation,
            delay: 200,
          ),
          _ModernStatCard(
            icon: Icons.timer_outlined,
            title: 'En cours',
            value: '${myProjects.where((p) => p.status == 'in_progress').length}',
            color: const Color(0xFFEF4444),
            animation: _cardAnimation,
            delay: 300,
          ),
        ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions rapides',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1D29),
            ),
          ),
          const SizedBox(height: 16),
          // Première ligne d'actions
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _ModernActionButton(
                  label: 'Nouveau projet',
                  icon: Icons.add_circle_outline,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF7B68EE)],
                  ),
                  animation: _cardAnimation,
                  onTap: () async {
                    final result = await context.push('/create-project');
                    if (result == true) {
                      setState(() {}); // Rafraîchir le dashboard
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModernActionButton(
                  label: 'Explorer',
                  icon: Icons.explore_outlined,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  animation: _cardAnimation,
                  onTap: () => context.push('/projects'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Deuxième ligne d'actions
          Row(
            children: [
              Expanded(
                child: _ModernActionButton(
                  label: 'Rejoindre groupe',
                  icon: Icons.group_add,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                  ),
                  animation: _cardAnimation,
                  onTap: () => _showAvailableGroups(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModernActionButton(
                  label: 'Mes groupes',
                  icon: Icons.group,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  animation: _cardAnimation,
                  onTap: () => _showMyGroups(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModernActionButton(
                  label: 'Collaborer',
                  icon: Icons.handshake,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  animation: _cardAnimation,
                  onTap: () => _showCollaborationRequests(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _ModernTab(
            label: 'Mes projets',
            isSelected: _selectedTabIndex == 0,
            onTap: () => setState(() => _selectedTabIndex = 0),
          ),
          const SizedBox(width: 12),
          _ModernTab(
            label: 'Récents',
            isSelected: _selectedTabIndex == 1,
            onTap: () => setState(() => _selectedTabIndex = 1),
          ),
          const SizedBox(width: 12),
          _ModernTab(
            label: 'Favoris',
            isSelected: _selectedTabIndex == 2,
            onTap: () => setState(() => _selectedTabIndex = 2),
          ),
          const SizedBox(width: 12),
          _ModernTab(
            label: 'Tutoriel',
            isSelected: _selectedTabIndex == 3,
            onTap: () => setState(() => _selectedTabIndex = 3),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(List<dynamic> myProjects, List<dynamic> recentProjects) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildProjectsList(myProjects, 'Mes projets', '/my-projects');
      case 1:
        return _buildProjectsList(recentProjects, 'Projets récents', '/projects');
      case 2:
        return _buildEmptyState();
      case 3:
        return ResponsiveWrapper(
          enableScrolling: true,
          child: SyncTestWidget(currentUser: _student),
        );
      default:
        return _buildProjectsList(myProjects, 'Mes projets', '/my-projects');
    }
  }

  Widget _buildProjectsList(List<dynamic> projects, String title, String viewAllRoute) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (projects.isEmpty)
            _buildEmptyState()
          else
            ...projects.take(3).map((project) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ProjectCard(
                title: project.projectName,
                description: project.description,
                imageUrl: project.imageUrl,
                tags: [
                  if (project.category != null && project.category!.isNotEmpty) project.category!,
                  project.state,
                  if (project.grade != null && project.grade!.isNotEmpty) 'Note: ${project.grade}',
                ],
                onTap: () {
                  // Navigate to project details
                },
              ),
            )),
          
          if (projects.length > 3)
            Center(
              child: TextButton.icon(
                onPressed: () => context.push(viewAllRoute),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Voir tout'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4A90E2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.folder_open,
              size: 40,
              color: Color(0xFF4A90E2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun projet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1D29),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier projet pour commencer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await context.push('/create-project');
              if (result == true) {
                setState(() {}); // Rafraîchir le dashboard
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Créer un projet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
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

  void _showAvailableGroups() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Groupes disponibles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            Expanded(
              child: GroupsList(
                currentUser: _student,
                showOnlyUserGroups: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMyGroups() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Mes groupes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            Expanded(
              child: GroupsList(
                currentUser: _student,
                showOnlyUserGroups: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCollaborationRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CollaborationRequestsPage(currentUser: _student),
      ),
    );
  }
}

// Modern Components

class _ModernStatCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Animation<double> animation;
  final int delay;

  const _ModernStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.animation,
    required this.delay,
  });

  @override
  State<_ModernStatCard> createState() => _ModernStatCardState();
}

class _ModernStatCardState extends State<_ModernStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

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
      child: RotationTransition(
        turns: _rotationAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color.withOpacity(0.1),
                widget.color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.color.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: widget.color,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final Animation<double> animation;
  final VoidCallback onTap;

  const _ModernActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModernTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: AppTheme.normalAnimation,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF7B68EE)],
                )
              : null,
          color: isSelected ? null : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : const Color(0xFFE8EDF2),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4A90E2).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}