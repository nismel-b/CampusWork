import 'package:flutter/material.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/model/group.dart';
import 'package:campuswork/services/group_service.dart';
import 'package:campuswork/components/components.dart';
import 'package:campuswork/screen/groups/group_project.dart';

class GroupsList extends StatefulWidget {
  final User currentUser;
  final bool showOnlyUserGroups;

  const GroupsList({
    super.key,
    required this.currentUser,
    this.showOnlyUserGroups = false,
  });

  @override
  State<GroupsList> createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  final GroupService _groupService = GroupService();
  List<Group> _groups = [];
  List<Group> _filteredGroups = [];
  bool _isLoading = true;
  String _searchQuery = '';
  GroupType? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => _isLoading = true);

    try {
      List<Group> groups;
      if (widget.showOnlyUserGroups) {
        if (widget.currentUser.isAdmin || widget.currentUser.isLecturer) {
          groups = _groupService.getGroupsByCreator(widget.currentUser.userId);
        } else {
          groups = _groupService.getGroupsByMember(widget.currentUser.userId);
        }
      } else {
        groups = _groupService.getAllGroups();
      }

      setState(() {
        _groups = groups;
        _filteredGroups = groups;
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

  void _filterGroups() {
    setState(() {
      _filteredGroups = _groups.where((group) {
        bool matchesSearch = _searchQuery.isEmpty ||
            group.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            group.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (group.courseName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        bool matchesType = _selectedType == null || group.type == _selectedType;

        return matchesSearch && matchesType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre de recherche et filtres
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Recherche
              TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _filterGroups();
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher un groupe...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 12),

              // Filtres par type
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Tous'),
                      selected: _selectedType == null,
                      onSelected: (selected) {
                        setState(() => _selectedType = null);
                        _filterGroups();
                      },
                    ),
                    const SizedBox(width: 8),
                    ...GroupType.values.map((type) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getTypeLabel(type)),
                          selected: _selectedType == type,
                          onSelected: (selected) {
                            setState(() => _selectedType = selected ? type : null);
                            _filterGroups();
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Liste des groupes
        Expanded(
          child: _isLoading
              ? const LoadingState(message: 'Chargement des groupes...')
              : _filteredGroups.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadGroups,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredGroups.length,
                        itemBuilder: (context, index) {
                          final group = _filteredGroups[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildGroupCard(group),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(Group group) {
    final isCreator = group.isCreator(widget.currentUser.userId);
    final isMember = group.isMember(widget.currentUser.userId);
    final canJoin = group.isOpen && !group.isFull && !isMember;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openGroupDetails(group),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTypeLabel(group.type),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getTypeColor(group.type),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
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
                    )
                  else if (isMember)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Membre',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                group.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Informations
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (group.courseName != null)
                    _buildInfoChip(Icons.book, group.courseName!),
                  if (group.academicYear != null)
                    _buildInfoChip(Icons.calendar_today, group.academicYear!),
                  if (group.section != null)
                    _buildInfoChip(Icons.class_, 'Section ${group.section}'),
                  _buildInfoChip(Icons.people, '${group.memberCount}/${group.maxMembers}'),
                  if (group.hasProjects)
                    _buildInfoChip(Icons.folder, '${group.projectCount} projets'),
                ],
              ),
              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  if (group.isOpen)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.public, size: 14, color: Colors.orange[800]),
                          const SizedBox(width: 4),
                          Text(
                            'Ouvert',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  if (canJoin)
                    TextButton.icon(
                      onPressed: () => _joinGroup(group),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Rejoindre'),
                    ),
                  TextButton.icon(
                    onPressed: () => _openGroupDetails(group),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Voir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
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
            Icons.group_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _groups.isEmpty
                ? 'Aucun groupe créé'
                : 'Aucun groupe trouvé',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _groups.isEmpty
                ? 'Les groupes créés apparaîtront ici'
                : 'Essayez de modifier vos critères de recherche',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(GroupType type) {
    switch (type) {
      case GroupType.project:
        return 'Projet';
      case GroupType.study:
        return 'Étude';
      case GroupType.collaboration:
        return 'Collaboration';
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

  Future<void> _joinGroup(Group group) async {
    final success = await _groupService.addMemberToGroup(group.groupId!, widget.currentUser.userId);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous avez rejoint le groupe avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _loadGroups();
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

  void _openGroupDetails(Group group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupProject(
          group: group,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }
}