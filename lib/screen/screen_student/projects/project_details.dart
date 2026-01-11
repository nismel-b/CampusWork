import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/services/interaction_service.dart';
import 'package:campuswork/services/comment_service.dart';
import 'package:campuswork/services/notification_services.dart';
import 'package:campuswork/model/project.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/model/comment.dart';
import 'package:campuswork/components/user_avatar.dart';

class ProjectDetailsPage extends StatefulWidget {
  final String projectId;

  const ProjectDetailsPage({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  final _commentController = TextEditingController();
  final _gradeController = TextEditingController();
  final _lecturerCommentController = TextEditingController();

  Project? _project;
  User? _currentUser;
  bool _isLiked = false;
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _currentUser = AuthService().currentUser;
    _loadProject();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _gradeController.dispose();
    _lecturerCommentController.dispose();
    super.dispose();
  }

  void _loadProject() {
    final project = ProjectService().getProjectById(widget.projectId);
    if (project != null) {
      setState(() {
        _project = project;
        _isLiked = InteractionService().isLikedByUser(project.projectId ?? '', _currentUser!.userId);
        _comments = CommentService().getCommentsByProject(project.projectId ?? '');
        if (project.grade != null && project.grade!.isNotEmpty) {
          _gradeController.text = project.grade!;
        }
        if (project.lecturerComment != null && project.lecturerComment!.isNotEmpty) {
          _lecturerCommentController.text = project.lecturerComment!;
        }
      });
    }
  }

  Future<void> _toggleLike() async {
    if (_project == null || _currentUser == null || _project!.projectId == null) return;

    await InteractionService().toggleLike(_project!.projectId!, _currentUser!.userId);

    if (!_isLiked) {
      await ProjectService().incrementLikes(_project!.projectId!);
      final projectOwner = await AuthService().getUserById(_project!.userId);
      if (projectOwner != null && projectOwner.userId != _currentUser!.userId) {
        await NotificationService().createLikeNotification(
          projectOwner.userId,
          _currentUser!.fullName,
          _project!.projectName,
          _project!.projectId!,
        );
      }
    } else {
      await ProjectService().decrementLikes(_project!.projectId!);
    }

    _loadProject();
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty || _project == null || _project!.projectId == null) return;

    final comment = Comment(
      userId: _currentUser!.userId,
      projectId: _project!.projectId!,
      userFullName: _currentUser!.fullName,
      content: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    await CommentService().addComment(comment);
    await ProjectService().incrementComments(_project!.projectId!);

    final projectOwner = await AuthService().getUserById(_project!.userId);
    if (projectOwner != null && projectOwner.userId != _currentUser!.userId) {
      await NotificationService().createCommentNotification(
        projectOwner.userId,
        _currentUser!.fullName,
        _project!.projectName,
        _project!.projectId!,
      );
    }

    _commentController.clear();
    _loadProject();
  }

  Future<void> _evaluateProject() async {
    if (_project == null || _gradeController.text.isEmpty) return;

    final grade = double.tryParse(_gradeController.text);
    if (grade == null || grade < 0 || grade > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note invalide (0-20)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ProjectService().evaluateProject(
      _project!.projectId!,
      _gradeController.text,
      _lecturerCommentController.text.trim().isEmpty
          ? null
          : _lecturerCommentController.text.trim(),
    );

    await NotificationService().createEvaluationNotification(
      _project!.userId,
      _project!.projectName,
      double.parse(_gradeController.text),
      _project!.projectId!,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Projet évalué avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      _loadProject();
    }
  }

  void _showEvaluationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Évaluer le projet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _gradeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Note (sur 20)',
                prefixIcon: Icon(Icons.grade),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lecturerCommentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Commentaire',
                prefixIcon: Icon(Icons.comment),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _evaluateProject,
              child: const Text('Évaluer'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Projet')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isOwner = _currentUser?.userId == _project!.userId;
    final isLecturer = _currentUser?.userRole == UserRole.lecturer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du projet'),
        actions: [
          if (isLecturer && _project!.state == 'termine')
            IconButton(
              icon: const Icon(Icons.grade),
              onPressed: _showEvaluationSheet,
              tooltip: 'Évaluer',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.folder,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _project!.projectName,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _project!.courseName,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            color: _isLiked ? Colors.red : null,
                          ),
                          onPressed: _toggleLike,
                        ),
                        Text('${_project!.likesCount}'),
                        const SizedBox(width: 24),
                        const Icon(Icons.comment_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text('${_project!.commentsCount}'),
                        const Spacer(),
                        _buildStateChip(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_project!.grade != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getGradeColor(_project!.grade!).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getGradeColor(_project!.grade!).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.grade,
                              color: _getGradeColor(_project!.grade!),
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Note: ${_project!.grade}/20',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  if (_project!.lecturerComment != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      _project!.lecturerComment!,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _project!.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (_project!.architecturePatterns != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Architecture & Design Patterns',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _project!.architecturePatterns!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (_project!.resources.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Ressources utilisées',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _project!.resources.map((resource) => Chip(
                          label: Text(resource),
                          backgroundColor: Theme.of(context).colorScheme.surface,
                        )).toList(),
                      ),
                    ],
                    const SizedBox(height: 32),
                    Text(
                      'Commentaires',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (_comments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Aucun commentaire',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      )
                    else
                      ..._comments.map((comment) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserAvatar(
                              userId: comment.userId,
                              name: comment.userFullName,
                              size: 36,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment.userFullName,
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment.content,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Ajouter un commentaire...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addComment,
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateChip() {
    Color color;
    String label;

    switch (_project!.state) {
      case 'enCours':
        color = Colors.orange;
        label = 'En cours';
        break;
      case 'termine':
        color = Colors.green;
        label = 'Terminé';
        break;
      case 'note':
        color = Colors.blue;
        label = 'Noté';
        break;
      default:
        color = Colors.orange;
        label = 'En cours';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    final gradeValue = double.tryParse(grade) ?? 0.0;
    if (gradeValue >= 16) return Colors.green;
    if (gradeValue >= 12) return Colors.blue;
    if (gradeValue >= 10) return Colors.orange;
    return Colors.red;
  }
}