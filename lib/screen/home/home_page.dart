import 'package:flutter/material.dart';
import 'package:campuswork/model/project.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/model/user.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProjectService _projectService = ProjectService();
  final TextEditingController _searchController = TextEditingController();

  List<Project> _allProjects = [];
  List<Project> _filteredProjects = [];
  String _searchQuery = '';
  String? _selectedCourse;
  String? _selectedStatus;
  String? _selectedState;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    try {
      await _projectService.refreshProjects();

      // Utiliser le filtrage basé sur le rôle
      final currentUser = AuthService().currentUser;
      if (currentUser != null) {
        switch (currentUser.userRole) {
          case UserRole.admin:
          case UserRole.lecturer:
            _allProjects = _projectService.getAllProjects();
            break;
          case UserRole.student:
            _allProjects = _projectService.getAllProjectsWithRoleFilter();
            break;
          default:
            _allProjects = _projectService.getPublicProjects();
        }
      } else {
        _allProjects = _projectService.getPublicProjects();
      }

      _filteredProjects = List.from(_allProjects);
    } catch (e) {
      debugPrint('Erreur lors du chargement des projets: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredProjects = _allProjects.where((project) {
      // Filtre de recherche
      final matchesSearch = _searchQuery.isEmpty ||
          project.projectName.toLowerCase().contains(
              _searchQuery.toLowerCase()) ||
          project.description.toLowerCase().contains(
              _searchQuery.toLowerCase()) ||
          project.courseName.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filtre par cours
      final matchesCourse = _selectedCourse == null ||
          project.courseName == _selectedCourse;

      // Filtre par statut
      final matchesStatus = _selectedStatus == null ||
          project.status
              .toString()
              .split('.')
              .last == _selectedStatus;

      // Filtre par état
      final matchesState = _selectedState == null ||
          project.state == _selectedState;

      return matchesSearch && matchesCourse && matchesStatus && matchesState;
    }).toList();
  }

  void _showFilterDialog() {
    final courses = _allProjects.map((p) => p.courseName).toSet().toList()
      ..sort();

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Filtres'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtre par cours
                  const Text(
                      'Cours:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String?>(
                    value: _selectedCourse,
                    isExpanded: true,
                    hint: const Text('Tous les cours'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tous les cours'),
                      ),
                      ...courses.map((course) =>
                          DropdownMenuItem<String?>(
                            value: course,
                            child: Text(course),
                          )),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedCourse = value),
                  ),

                  const SizedBox(height: 16),

                  // Filtre par statut
                  const Text(
                      'Statut:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String?>(
                    value: _selectedStatus,
                    isExpanded: true,
                    hint: const Text('Tous les statuts'),
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tous les statuts'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'public',
                        child: Text('Public'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'private',
                        child: Text('Privé'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedStatus = value),
                  ),

                  const SizedBox(height: 16),

                  // Filtre par état
                  const Text(
                      'État:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String?>(
                    value: _selectedState,
                    isExpanded: true,
                    hint: const Text('Tous les états'),
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tous les états'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'enCours',
                        child: Text('En cours'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'termine',
                        child: Text('Terminé'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'note',
                        child: Text('Noté'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedState = value),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCourse = null;
                    _selectedStatus = null;
                    _selectedState = null;
                    _applyFilters();
                  });
                  Navigator.pop(context);
                },
                child: const Text('Réinitialiser'),
              ),
              ElevatedButton(
                onPressed: () {
                  _applyFilters();
                  Navigator.pop(context);
                },
                child: const Text('Appliquer'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildSkeletonLoading();
    }

    return RefreshIndicator(
      onRefresh: _loadProjects,
      child: Column(
        children: [
          // Barre de recherche et filtres
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher des projets...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme
                              .of(context)
                              .scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _showFilterDialog,
                      icon: const Icon(Icons.filter_list),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme
                            .of(context)
                            .primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (_selectedCourse != null || _selectedStatus != null ||
                    _selectedState != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (_selectedCourse != null)
                          Chip(
                            label: Text('Cours: $_selectedCourse'),
                            onDeleted: () =>
                                setState(() {
                                  _selectedCourse = null;
                                  _applyFilters();
                                }),
                          ),
                        if (_selectedStatus != null)
                          Chip(
                            label: Text('Statut: $_selectedStatus'),
                            onDeleted: () =>
                                setState(() {
                                  _selectedStatus = null;
                                  _applyFilters();
                                }),
                          ),
                        if (_selectedState != null)
                          Chip(
                            label: Text('État: $_selectedState'),
                            onDeleted: () =>
                                setState(() {
                                  _selectedState = null;
                                  _applyFilters();
                                }),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Liste des projets
          Expanded(
            child: _filteredProjects.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun projet trouvé',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Essayez de modifier vos critères de recherche',
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredProjects.length,
              itemBuilder: (context, index) {
                final project = _filteredProjects[index];
                return _buildProjectCard(project);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // TODO: Implémenter la navigation vers les détails du projet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Détails du projet: ${project.projectName}')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.projectName,
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(project.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.courseName,
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStateChip(project.state),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.favorite_outline, size: 16,
                          color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${project.likesCount}'),
                      const SizedBox(width: 16),
                      Icon(Icons.comment_outlined, size: 16,
                          color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${project.commentsCount}'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ProjectStatus status) {
    final isPublic = status == ProjectStatus.public;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPublic ? Colors.green.withOpacity(0.1) : Colors.orange
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isPublic ? 'Public' : 'Privé',
        style: TextStyle(
          color: isPublic ? Colors.green[700] : Colors.orange[700],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStateChip(String state) {
    Color color;
    String label;

    switch (state) {
      case 'enCours':
        color = Colors.blue;
        label = 'En cours';
        break;
      case 'termine':
        color = Colors.orange;
        label = 'Terminé';
        break;
      case 'note':
        color = Colors.green;
        label = 'Noté';
        break;
      default:
        color = Colors.grey;
        label = 'Inconnu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return Column(
      children: [
        // Skeleton pour la barre de recherche
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 60,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Skeleton pour la liste des projets
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) => _buildSkeletonCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 200,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
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