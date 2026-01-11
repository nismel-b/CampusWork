import 'package:flutter/material.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/model/group.dart';
import 'package:campuswork/services/group_service.dart';

class GroupFormulaire extends StatefulWidget {
  final User currentUser;
  final Group? group; // Pour l'édition
  final VoidCallback? onGroupCreated;

  const GroupFormulaire({
    super.key,
    required this.currentUser,
    this.group,
    this.onGroupCreated,
  });

  @override
  State<GroupFormulaire> createState() => _GroupFormulaireState();
}

class _GroupFormulaireState extends State<GroupFormulaire> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _courseController = TextEditingController();
  final _academicYearController = TextEditingController();
  final _sectionController = TextEditingController();
  final _maxMembersController = TextEditingController();
  final _criteriaController = TextEditingController();

  GroupType _selectedType = GroupType.project;
  bool _isOpen = false;
  bool _isLoading = false;
  List<String> _evaluationCriteria = [];

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      _initializeWithGroup(widget.group!);
    } else {
      _maxMembersController.text = '10';
      _academicYearController.text = DateTime.now().year.toString();
    }
  }

  void _initializeWithGroup(Group group) {
    _nameController.text = group.name;
    _descriptionController.text = group.description;
    _courseController.text = group.courseName ?? '';
    _academicYearController.text = group.academicYear ?? '';
    _sectionController.text = group.section ?? '';
    _maxMembersController.text = group.maxMembers.toString();
    _selectedType = group.type;
    _isOpen = group.isOpen;
    _evaluationCriteria = List.from(group.evaluationCriteria);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _courseController.dispose();
    _academicYearController.dispose();
    _sectionController.dispose();
    _maxMembersController.dispose();
    _criteriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom du groupe
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du groupe',
                hintText: 'Ex: Groupe Projet Mobile 2024',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom du groupe est requis';
                }
                if (value.trim().length < 3) {
                  return 'Le nom doit contenir au moins 3 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Décrivez l\'objectif et les activités du groupe',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La description est requise';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Type de groupe
            Text(
              'Type de groupe',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: GroupType.values.map((type) {
                return ChoiceChip(
                  label: Text(_getTypeLabel(type)),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedType = type);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Cours (si applicable)
            if (_selectedType == GroupType.project || _selectedType == GroupType.study)
              Column(
                children: [
                  TextFormField(
                    controller: _courseController,
                    decoration: const InputDecoration(
                      labelText: 'Cours',
                      hintText: 'Ex: Développement Mobile',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Année académique et section
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _academicYearController,
                    decoration: const InputDecoration(
                      labelText: 'Année académique',
                      hintText: '2024',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _sectionController,
                    decoration: const InputDecoration(
                      labelText: 'Section',
                      hintText: 'A, B, C...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nombre maximum de membres
            TextFormField(
              controller: _maxMembersController,
              decoration: const InputDecoration(
                labelText: 'Nombre maximum de membres',
                hintText: '10',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nombre maximum de membres est requis';
                }
                final number = int.tryParse(value.trim());
                if (number == null || number < 2) {
                  return 'Le nombre doit être au moins 2';
                }
                if (number > 50) {
                  return 'Le nombre ne peut pas dépasser 50';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Critères d'évaluation
            Text(
              'Critères d\'évaluation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _criteriaController,
                    decoration: const InputDecoration(
                      labelText: 'Ajouter un critère',
                      hintText: 'Ex: Qualité du code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addCriteria,
                  icon: const Icon(Icons.add),
                  tooltip: 'Ajouter le critère',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_evaluationCriteria.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _evaluationCriteria.map((criteria) {
                  return Chip(
                    label: Text(criteria),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeCriteria(criteria),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // Options
            SwitchListTile(
              title: const Text('Groupe ouvert'),
              subtitle: const Text('Les étudiants peuvent rejoindre librement'),
              value: _isOpen,
              onChanged: (value) => setState(() => _isOpen = value),
            ),
            const SizedBox(height: 24),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveGroup,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.group != null ? 'Modifier' : 'Créer'),
                  ),
                ),
              ],
            ),
          ],
        ),
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

  void _addCriteria() {
    final criteria = _criteriaController.text.trim();
    if (criteria.isNotEmpty && !_evaluationCriteria.contains(criteria)) {
      setState(() {
        _evaluationCriteria.add(criteria);
        _criteriaController.clear();
      });
    }
  }

  void _removeCriteria(String criteria) {
    setState(() {
      _evaluationCriteria.remove(criteria);
    });
  }

  Future<void> _saveGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final group = Group(
        groupId: widget.group?.groupId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        createdBy: widget.currentUser.userId,
        type: _selectedType,
        courseName: _courseController.text.trim().isEmpty ? null : _courseController.text.trim(),
        academicYear: _academicYearController.text.trim().isEmpty ? null : _academicYearController.text.trim(),
        section: _sectionController.text.trim().isEmpty ? null : _sectionController.text.trim(),
        members: widget.group?.members ?? [],
        projects: widget.group?.projects ?? [],
        evaluationCriteria: _evaluationCriteria,
        maxMembers: int.parse(_maxMembersController.text.trim()),
        isOpen: _isOpen,
        createdAt: widget.group?.createdAt ?? DateTime.now(),
      );

      bool success;
      if (widget.group != null) {
        success = await GroupService().updateGroup(group);
      } else {
        success = await GroupService().createGroup(group);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.group != null 
                  ? 'Groupe modifié avec succès' 
                  : 'Groupe créé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onGroupCreated?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la sauvegarde'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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