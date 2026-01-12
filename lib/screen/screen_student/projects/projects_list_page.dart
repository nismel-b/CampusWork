import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/model/project.dart';
import 'package:campuswork/components/components.dart';
import 'package:campuswork/components/animated_button.dart';
import 'package:campuswork/services/project_service.dart';


class ProjectsListPage extends StatefulWidget {
  final User currentUser;

  const ProjectsListPage({super.key, required this.currentUser});

  @override
  State<ProjectsListPage> createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends State<ProjectsListPage> {
  final ProjectService _projectService = ProjectService();
  List<Project> _projects = [];
  List<Project> _filteredProjects = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    
    try {
      debugPrint('🔵 Loading projects for user: ${widget.currentUser.userId}');
      
      // Rafraîchir les données depuis la base
      await _projectService.refreshProjects();
      
      // Le service retourne directement List<Project>, pas Future<List<Map>>
      final projects = _projectService.getProjectsByStudent(widget.currentUser.userId);
      
      debugPrint('✅ Loaded ${projects.length} projects');
      for (var project in projects) {
        debugPrint('   - ${project.projectName} (${project.projectId})');
      }
      
      setState(() {
        _projects = projects;
        _filteredProjects = _projects;
      });
    } catch (e) {
      debugPrint('❌ Error loading projects: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterProjects() {
    setState(() {
      _filteredProjects = _projects.where((project) {
        bool matchesSearch = _searchQuery.isEmpty ||
            project.projectName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            project.description.toLowerCase().contains(_searchQuery.toLowerCase());
        
        bool matchesCategory = _selectedCategory == null ||
            project.category == _selectedCategory;
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _createProject() async {
    // Navigation vers la page de création de projet
    final result = await context.push('/create-project');
    
    // Si le projet a été créé avec succès, rafraîchir la liste
    if (result == true) {
      debugPrint('🔄 Project created successfully, refreshing list...');
      _loadProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Projets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingState(message: 'Chargement des projets...')
          : RefreshIndicator(
              onRefresh: _loadProjects,
              child: Column(
                children: [
                  // Search and Filter Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Search Bar
                        TextField(
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                            _filterProjects();
                          },
                          decoration: InputDecoration(
                            hintText: 'Rechercher un projet...',
                            prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Category Filter
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              decoration: InputDecoration(
                                labelText: 'Catégorie',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Toutes les catégories'),
                                ),
                                ...['Web', 'Mobile', 'Desktop', 'IA', 'Data Science']
                                    .map((category) => DropdownMenuItem(
                                          value: category,
                                          child: Text(category),
                                        )),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedCategory = value);
                                _filterProjects();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _selectedCategory = null;
                                _filteredProjects = _projects;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Projects List
                Expanded(
                  child: _filteredProjects.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredProjects.length,
                          itemBuilder: (context, index) {
                            final project = _filteredProjects[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ProjectCard(
                                title: project.projectName,
                                description: project.description,
                                imageUrl: project.imageUrl,
                                tags: [
                                  if (project.category != null && project.category!.isNotEmpty) project.category!,
                                  if (project.state.isNotEmpty) project.state,
                                  if (project.grade != null && project.grade!.isNotEmpty) 'Note: ${project.grade}',
                                ],
                                onTap: () => _openProjectDetail(project),
                                footer: _buildProjectFooter(project),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
      floatingActionButton: AnimatedFloatingActionButton(
        onPressed: _createProject,
        icon: const Icon(Icons.add),
        label: 'Nouveau Projet',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            _projects.isEmpty
                ? 'Aucun projet créé'
                : 'Aucun projet trouvé',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _projects.isEmpty
                ? 'Créez votre premier projet pour commencer'
                : 'Essayez de modifier vos critères de recherche',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_projects.isEmpty)
            ElevatedButton.icon(
              onPressed: _createProject,
              icon: const Icon(Icons.add),
              label: const Text('Créer un projet'),
            ),
        ],
      ),
    );
  }

  Widget _buildProjectFooter(Project project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                project.createdAt ?? 'Date inconnue',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _editProject(project),
                tooltip: 'Modifier',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                onPressed: () => _deleteProject(project),
                tooltip: 'Supprimer',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openProjectDetail(Project project) {
    // Navigation vers les détails du projet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ouverture du projet: ${project.projectName}')),
    );
  }

  void _editProject(Project project) {
    // Navigation vers l'édition du projet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Édition du projet: ${project.projectName}')),
    );
  }

  Future<void> _deleteProject(Project project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le projet'),
        content: Text('Voulez-vous vraiment supprimer "${project.projectName}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _projectService.deleteProject(project.projectId!);
        await _loadProjects();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Projet supprimé avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la suppression: $e')),
          );
        }
      }
    }
  }
}
