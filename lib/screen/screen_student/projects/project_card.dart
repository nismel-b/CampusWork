import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campuswork/model/project.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/services/interaction_service.dart';
import 'package:intl/intl.dart';

class ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isLiked = false;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadLikeStatus();
  }

  void _loadLikeStatus() {
    final currentUser = AuthService().currentUser;
    if (currentUser != null) {
      _isLiked = InteractionService().isLikedByUser(widget.project.projectId!, currentUser.userId);
    }
    _likesCount = widget.project.likesCount;
  }

  Future<void> _toggleLike() async {
    final currentUser = AuthService().currentUser;
    if (currentUser == null) return;

    final wasLiked = await InteractionService().toggleLike(widget.project.projectId!, currentUser.userId);
    
    setState(() {
      _isLiked = wasLiked;
      _likesCount = wasLiked ? _likesCount + 1 : _likesCount - 1;
    });
  }

  String _getStateText(String state) {
    switch (state) {
      case 'enCours':
        return 'En cours';
      case 'termine':
        return 'Terminé';
      case 'note':
        return 'Noté';
      default:
        return 'En cours';
    }
  }

  Color _getStateColor(String state) {
    switch (state) {
      case 'enCours':
        return Colors.orange;
      case 'termine':
        return Colors.blue;
      case 'note':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap ?? () => context.push('/project/${widget.project.projectId}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec titre et statut
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.project.projectName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStateColor(widget.project.state).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStateColor(widget.project.state),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStateText(widget.project.state),
                      style: TextStyle(
                        color: _getStateColor(widget.project.state),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Cours
              Text(
                widget.project.courseName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Description
              Text(
                widget.project.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Technologies/Resources
              if (widget.project.resources.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: widget.project.resources.take(3).map((resource) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        resource,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
              
              // Footer avec stats et date
              Row(
                children: [
                  // Like button
                  InkWell(
                    onTap: _toggleLike,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: _isLiked ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _likesCount.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Comments
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.comment_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        widget.project.commentsCount.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Grade si disponible
                  if (widget.project.grade != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.project.grade}/20',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // Date
                  Text(
                    widget.project.updatedAt ?? 'Date inconnue',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
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