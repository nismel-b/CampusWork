import 'package:flutter/material.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/model/group.dart';
import 'package:campuswork/model/project.dart';
import 'package:campuswork/services/group_service.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/components/components.dart';

class AddProjectToGroup extends StatefulWidget {
  final Group group;
  final User currentUser;
  final VoidCallback? onProjectAdded;

  const AddProjectToGroup({
    super.key,
    required this.group,
    required this.currentUser,
    this.onProjectAdded,
  });

  @override
  State<AddProjectToGroup> createState() => _AddProjectToGroupState();
}

class _AddProjectToGroupState extends State<AddProjectToGroup> {
  final GroupService _groupService = GroupService();
  final ProjectService _projectService = ProjectService();
  
  List<Project> _availableProjects = [];
  List<Project> _filteredProjects = [];
  final Set<String> _selectedProjects = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAvailableProjects();
  }

  Future<void> _loadAvailableProjects() async {
    setState(() => _isLoading = true);

    try {
      // Obtenir tous les projets disponibles
      List<Project> allProjects;
      
      if (widget.currentUser.isAdmin || widget.currentUser.isLecturer) {
        // Admin/Lecturer peut ajouter tous les projets
        allProjects = _projectService.getAllProjects();
      } else {
        // Étudiant ne peut ajouter que ses propres projets
        allProjects = _projectService.getProjectsByStudent(widget.currentUser.userId);
      }

      // Filtrer les projets déjà dans le groupe
      final availableProjects = allProjects
          .where((project) => !widget.group.projects.contains(project.projectId))
          .toList();

      setState(() {
        _availableProjects = availableProjects;
        _filteredProjects = availableProjects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _filterProjects() {
    setState(() {
      _filteredProjects = _availableProjects.where((project) {
        return _searchQuery.isEmpty ||
            project.projectName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            project.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            project.courseName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // En-tête
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ajouter des projets',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Groupe: ${widget.group.name}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),

            // Barre de recherche
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
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
            ),

            // Compteur de sélection
            if (_selectedProjects.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedProjects.length} projet(s) sélectionné(s)',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() => _selectedProjects.clear()),
                      child: const Text('Tout désélectionner'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),

            // Liste des projets
            Expanded(
              child: _isLoading
                  ? const LoadingState(message: 'Chargement des projets...')
                  : _filteredProjects.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: _filteredProjects.length,
                          itemBuilder: (context, index) {
                            final project = _filteredProjects[index];
                            final isSelected = _selectedProjects.contains(project.projectId);
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: CheckboxListTile(
                                value: isSelected,
                                onChanged: (selected) {
                                  setState(() {
                                    if (selected == true) {
                                      _selectedProjects.add(project.projectId!);
                                    } else {
                                      _selectedProjects.remove(project.projectId);
                                    }
                                  });
                                },
                                title: Text(
                                  project.projectName,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        _buildInfoChip(Icons.book, project.courseName),
                                        _buildInfoChip(Icons.category, project.category ?? 'Sans catégorie'),
                                        _buildInfoChip(Icons.flag, project.state),
                                      ],
                                    ),
                                  ],
                                ),
                                secondary: project.imageUrl != null && project.imageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          project.imageUrl!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.image, color: Colors.grey),
                                            );
                                          },
                                        ),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.folder, color: Colors.grey),
                                      ),
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                            );
                          },
                        ),
            ),

            // Boutons d'action
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedProjects.isEmpty ? null : _addSelectedProjects,
                    child: Text('Ajouter (${_selectedProjects.length})'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
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
            _availableProjects.isEmpty
                ? 'Aucun projet disponible'
                : 'Aucun projet trouvé',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _availableProjects.isEmpty
                ? 'Tous les projets sont déjà dans ce groupe'
                : 'Essayez de modifier votre recherche',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _addSelectedProjects() async {
    if (_selectedProjects.isEmpty) return;

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      int successCount = 0;
      
      for (final projectId in _selectedProjects) {
        final success = await _groupService.addProjectToGroup(widget.group.groupId!, projectId);
        if (success) successCount++;
      }

      // Fermer l'indicateur de chargement
      if (mounted) Navigator.pop(context);

      if (mounted) {
        // Fermer le dialog
        Navigator.pop(context);

        // Afficher le résultat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successCount == _selectedProjects.length
                  ? '$successCount projet(s) ajouté(s) avec succès'
                  : '$successCount/${_selectedProjects.length} projet(s) ajouté(s)',
            ),
            backgroundColor: successCount > 0 ? Colors.green : Colors.red,
          ),
        );

        // Notifier le parent
        widget.onProjectAdded?.call();
      }
    } catch (e) {
      // Fermer l'indicateur de chargement
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}