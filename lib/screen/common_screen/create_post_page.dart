import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/services/post_service.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/model/post.dart';
import 'package:campuswork/model/project.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  
  PostType _selectedType = PostType.question;
  String? _selectedCourse;
  String? _selectedProjectId;
  bool _isLoading = false;
  
  List<String> _availableCourses = [];
  List<Project> _userProjects = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final currentUser = AuthService().currentUser;
    if (currentUser != null) {
      _availableCourses = ProjectService().getAllCourses();
      _userProjects = ProjectService().getProjectsByStudent(currentUser.userId);
      setState(() {});
    }
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = AuthService().currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();

    final post = Post(
      id: const Uuid().v4(),
      userId: currentUser.userId,
      userFullName: currentUser.fullName,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      type: _selectedType,
      courseName: _selectedCourse,
      projectId: _selectedProjectId,
      tags: tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await PostService().createPost(post);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post créé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la création du post'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau post'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createPost,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Publier'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Type de post
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type de post',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: PostType.values.map((type) {
                        return ChoiceChip(
                          label: Text(_getTypeDisplayName(type)),
                          selected: _selectedType == type,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedType = type);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Titre
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre',
                prefixIcon: Icon(Icons.title),
                hintText: 'Donnez un titre accrocheur à votre post',
              ),
              maxLength: 100,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le titre est requis';
                }
                if (value.trim().length < 5) {
                  return 'Le titre doit contenir au moins 5 caractères';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Contenu
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Contenu',
                prefixIcon: Icon(Icons.description),
                hintText: 'Décrivez votre demande, idée ou question en détail',
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              maxLength: 1000,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le contenu est requis';
                }
                if (value.trim().length < 10) {
                  return 'Le contenu doit contenir au moins 10 caractères';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Cours (optionnel)
            if (_availableCourses.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                decoration: const InputDecoration(
                  labelText: 'Cours (optionnel)',
                  prefixIcon: Icon(Icons.school),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Aucun cours spécifique'),
                  ),
                  ..._availableCourses.map((course) {
                    return DropdownMenuItem<String>(
                      value: course,
                      child: Text(course),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _selectedCourse = value);
                },
              ),
            
            const SizedBox(height: 16),
            
            // Projet lié (optionnel)
            if (_userProjects.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedProjectId,
                decoration: const InputDecoration(
                  labelText: 'Projet lié (optionnel)',
                  prefixIcon: Icon(Icons.folder),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Aucun projet spécifique'),
                  ),
                  ..._userProjects.map((project) {
                    return DropdownMenuItem<String>(
                      value: project.projectId,
                      child: Text(project.projectName),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _selectedProjectId = value);
                },
              ),
            
            const SizedBox(height: 16),
            
            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (optionnel)',
                prefixIcon: Icon(Icons.tag),
                hintText: 'flutter, mobile, aide (séparés par des virgules)',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final tags = value.split(',').map((e) => e.trim()).toList();
                  if (tags.length > 10) {
                    return 'Maximum 10 tags autorisés';
                  }
                  for (final tag in tags) {
                    if (tag.length > 20) {
                      return 'Chaque tag doit contenir moins de 20 caractères';
                    }
                  }
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Conseils
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Conseils pour un bon post',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Soyez précis dans votre titre\n'
                      '• Décrivez clairement votre problème ou idée\n'
                      '• Ajoutez des tags pertinents pour faciliter la recherche\n'
                      '• Liez votre post à un cours ou projet si applicable',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeDisplayName(PostType type) {
    switch (type) {
      case PostType.help:
        return 'Demande d\'aide';
      case PostType.idea:
        return 'Idée de projet';
      case PostType.announcement:
        return 'Annonce';
      case PostType.question:
        return 'Question';
    }
  }
}