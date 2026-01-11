import 'package:flutter/material.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/model/group.dart';
import 'package:campuswork/model/project.dart';
import 'package:campuswork/services/group_service.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/services/user_service.dart';
import 'package:campuswork/components/components.dart';
import 'package:campuswork/screen/groups/add_project_to_group.dart';

class GroupProject extends StatefulWidget {
  final Group group;
  final User currentUser;

  const GroupProject({
    super.key,
    required this.group,
    required this.currentUser,
  });

  @override
  State<GroupProject> createState() => _GroupProjectState();
}

class _GroupProjectState extends State<GroupProject> with TickerProviderStateMixin {
  late TabController _tabController;
  final GroupService _groupService = GroupService();
  final ProjectService _projectService = ProjectService();
  final UserService _userService = UserService();

  Group? _group;
  List<Project> _projects = [];
  List<User> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _group = widget.group;
    _loadGroupData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGroupData() async {
    setState(() => _isLoading = true);

    try {
      // Recharger les données du groupe
      final updatedGroup = _groupService.getGroupById(widget.group.groupId!);
      if (updatedGroup != null) {
        _group = updatedGroup;
      }

      // Charger les projets du groupe
      final projects = <Project>[];
      for (final projectId in _group!.projects) {
        final project = _projectService.getProjectById(projectId);
        if (project != null) {
          projects.add(project);
        }
      }

      // Charger les membres du groupe
      final members = <User>[];
      for (final userId in _group!.members) {
        final user = await _userService.getUserById(userId);
        if (user != null) {
          members.add(user);
        }
      }

      setState(() {
        _projects = projects;
        _members = members;
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

  @override
  Widget build(BuildContext context) {
    if (_group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Groupe introuvable')),
        body: const Center(child: Text('Ce groupe n\'existe plus')),
      );
    }

    final isCreator = _group!.isCreator(widget.currentUser.userId);
    final isMember = _group!.isMember(widget.currentUser.userId);

    return Scaffold(
      appBar: AppBar(
        title: Text(_group!.name),
        actions: [
          if (isCreator)
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Modifier'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Infos'),
            Tab(icon: Icon(Icons.folder), text: 'Projets'),
            Tab(icon: Icon(Icons.people), text: 'Membres'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingState(message: 'Chargement...')
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildProjectsTab(),
                _buildMembersTab(),
              ],
            ),
      floatingActionButton: _buildFloatingActionButton(isCreator, isMember),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du groupe
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getTypeColor(_group!.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getTypeIcon(_group!.type),
                          color: _getTypeColor(_group!.type),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _group!.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              _getTypeLabel(_group!.type),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: _getTypeColor(_group!.type),
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _group!.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Informations détaillées
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  if (_group!.courseName != null)
                    _buildInfoRow(Icons.book, 'Cours', _group!.courseName!),
                  if (_group!.academicYear != null)
                    _buildInfoRow(Icons.calendar_today, 'Année', _group!.academicYear!),
                  if (_group!.section != null)
                    _buildInfoRow(Icons.class_, 'Section', _group!.section!),
                  _buildInfoRow(Icons.people, 'Membres', '${_group!.memberCount}/${_group!.maxMembers}'),
                  _buildInfoRow(Icons.folder, 'Projets', _group!.projectCount.toString()),
                  _buildInfoRow(
                    _group!.isOpen ? Icons.public : Icons.lock,
                    'Accès',
                    _group!.isOpen ? 'Ouvert' : 'Fermé',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Critères d'évaluation
          if (_group!.evaluationCriteria.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Critères d\'évaluation',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _group!.evaluationCriteria.map((criteria) {
                        return Chip(
                          label: Text(criteria),
                          backgroundColor: Colors.blue[50],
                          labelStyle: TextStyle(color: Colors.blue[800]),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProjectsTab() {
    return Column(
      children: [
        if (_projects.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun projet dans ce groupe',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Les projets ajoutés au groupe apparaîtront ici',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                final project = _projects[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ProjectCard(
                    title: project.projectName,
                    description: project.description,
                    imageUrl: project.imageUrl,
                    tags: [
                      if (project.category != null && project.category!.isNotEmpty) 
                        project.category!,
                      project.state,
                      if (project.grade != null && project.grade!.isNotEmpty) 
                        'Note: ${project.grade}',
                    ],
                    onTap: () {
                      // Navigation vers les détails du projet
                    },
                    footer: _buildProjectFooter(project),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMembersTab() {
    return Column(
      children: [
        if (_members.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun membre dans ce groupe',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];
                final isCreator = _group!.isCreator(member.userId);
                
                return Card(
                  child: ListTile(
                    leading: UserAvatar(
                      userId: member.userId,
                      name: member.fullName,
                    ),
                    title: Text(member.fullName),
                    subtitle: Text(member.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCreator)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Créateur',
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        if (_group!.isCreator(widget.currentUser.userId) && !isCreator)
                          IconButton(
                            onPressed: () => _removeMember(member),
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            tooltip: 'Retirer du groupe',
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectFooter(Project project) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Créé le ${project.createdAt ?? 'Date inconnue'}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          if (_group!.isCreator(widget.currentUser.userId))
            IconButton(
              onPressed: () => _removeProjectFromGroup(project),
              icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
              tooltip: 'Retirer du groupe',
            ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(bool isCreator, bool isMember) {
    if (isCreator) {
      return FloatingActionButton(
        onPressed: _showAddProjectDialog,
        child: const Icon(Icons.add),
        tooltip: 'Ajouter un projet',
      );
    } else if (!isMember && _group!.isOpen && !_group!.isFull) {
      return FloatingActionButton.extended(
        onPressed: _joinGroup,
        icon: const Icon(Icons.person_add),
        label: const Text('Rejoindre'),
      );
    }
    return null;
  }

  String _getTypeLabel(GroupType type) {
    switch (type) {
      case GroupType.project:
        return 'Groupe de projet';
      case GroupType.study:
        return 'Groupe d\'étude';
      case GroupType.collaboration:
        return 'Groupe de collaboration';
    }
  }

  Color _getTypeColor(GroupType type) {
    switch (type) {
      case GroupType.project:
        return Colors.blue;
      case GroupType.study:
        return Colors.green;
      case GroupType.collaboration:
        return Colors.purple;
    }
  }

  IconData _getTypeIcon(GroupType type) {
    switch (type) {
      case GroupType.project:
        return Icons.work;
      case GroupType.study:
        return Icons.school;
      case GroupType.collaboration:
        return Icons.handshake;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        // TODO: Implémenter l'édition du groupe
        break;
      case 'delete':
        _deleteGroup();
        break;
    }
  }

  Future<void> _deleteGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le groupe'),
        content: Text('Voulez-vous vraiment supprimer "${_group!.name}" ?'),
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

    if (confirmed == true) {
      final success = await _groupService.deleteGroup(_group!.groupId!);
      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Groupe supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la suppression'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _joinGroup() async {
    final success = await _groupService.addMemberToGroup(_group!.groupId!, widget.currentUser.userId);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous avez rejoint le groupe avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _loadGroupData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de rejoindre le groupe'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeMember(User member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer le membre'),
        content: Text('Voulez-vous retirer ${member.fullName} du groupe ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _groupService.removeMemberFromGroup(_group!.groupId!, member.userId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Membre retiré avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          _loadGroupData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors du retrait'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _removeProjectFromGroup(Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer le projet'),
        content: Text('Voulez-vous retirer "${project.projectName}" du groupe ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _groupService.removeProjectFromGroup(_group!.groupId!, project.projectId!);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Projet retiré avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          _loadGroupData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors du retrait'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AddProjectToGroup(
        group: _group!,
        currentUser: widget.currentUser,
        onProjectAdded: _loadGroupData,
      ),
    );
  }
}