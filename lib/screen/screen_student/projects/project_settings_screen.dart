import 'package:flutter/material.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/providers/auth_provider.dart';
import 'package:campuswork/model/project.dart';
import 'package:provider/provider.dart';

class ProjectSettingsScreen extends StatefulWidget {
  final String? projectId;
  const ProjectSettingsScreen({super.key, this.projectId});

  @override
  State<ProjectSettingsScreen> createState() => _ProjectSettingsScreenState();
}

class _ProjectSettingsScreenState extends State<ProjectSettingsScreen> {
  final ProjectService _projectService = ProjectService();
  final _formKey = GlobalKey<FormState>();
  
  final _projectNameController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _resourcesController = TextEditingController();
  
  Project? _project;
  bool _isLoading = true;
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _courseNameController.dispose();
    _descriptionController.dispose();
    _resourcesController.dispose();
    super.dispose();
  }

  Future<void> _loadProject() async {
    if (widget.projectId != null) {
      try {
        final project = await _projectService.getProjectById(widget.projectId!);
        if (project != null) {
          setState(() {
            _project = project;
            _projectNameController.text = project.projectName;
            _courseNameController.text = project.courseName;
            _descriptionController.text = project.description;
            _resourcesController.text = project.resources.join(', ');
            _isPublic = project.status == ProjectStatus.public;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (_project != null) {
        final updatedProject = _project!.copyWith(
          projectName: _projectNameController.text.trim(),
          courseName: _courseNameController.text.trim(),
          description: _descriptionController.text.trim(),
          resources: _resourcesController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          status: _isPublic ? ProjectStatus.public : ProjectStatus.private,
        );

        await _projectService.updateProject(updatedProject);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Projet mis à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres du projet'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProject,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _project == null
              ? const Center(
                  child: Text('Projet non trouvé'),
                )
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations du projet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Nom du projet
                        TextFormField(
                          controller: _projectNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom du projet',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.folder),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le nom du projet est requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Nom du cours
                        TextFormField(
                          controller: _courseNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom du cours',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.school),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le nom du cours est requis';
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
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
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
                        
                        // Ressources
                        TextFormField(
                          controller: _resourcesController,
                          decoration: const InputDecoration(
                            labelText: 'Ressources (séparées par des virgules)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.library_books),
                            hintText: 'GitHub, Documentation, API',
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Visibilité
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Visibilité du projet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SwitchListTile(
                                  title: const Text('Projet public'),
                                  subtitle: Text(
                                    _isPublic
                                        ? 'Visible par tous les utilisateurs'
                                        : 'Visible uniquement par vous',
                                  ),
                                  value: _isPublic,
                                  onChanged: (value) {
                                    setState(() => _isPublic = value);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Bouton de sauvegarde
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveProject,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Enregistrer les modifications',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

