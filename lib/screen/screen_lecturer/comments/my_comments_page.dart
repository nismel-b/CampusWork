import 'package:flutter/material.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/services/comment_service.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/components/components.dart';

class MyCommentsPage extends StatefulWidget {
  final User currentUser;

  const MyCommentsPage({super.key, required this.currentUser});

  @override
  State<MyCommentsPage> createState() => _MyCommentsPageState();
}

class _MyCommentsPageState extends State<MyCommentsPage> {
  final CommentService _commentService = CommentService();
  final ProjectService _projectService = ProjectService();
  List<Map<String, dynamic>> _myComments = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // all, recent, projects

  @override
  void initState() {
    super.initState();
    _loadMyComments();
  }

  Future<void> _loadMyComments() async {
    setState(() => _isLoading = true);
    try {
      final comments = await _commentService.getCommentsByUser(widget.currentUser.userId);
      
      // Enrichir les commentaires avec les informations du projet
      final enrichedComments = <Map<String, dynamic>>[];
      for (var comment in comments) {
        final projectId = comment['projectId'];
        final project = await _projectService.getProjectById(projectId);
        
        enrichedComments.add({
          ...comment,
          'projectName': project?.projectName ?? 'Projet supprimé',
          'projectDescription': project?.description ?? '',
        });
      }
      
      setState(() {
        _myComments = enrichedComments;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading comments: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredComments {
    switch (_selectedFilter) {
      case 'recent':
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        return _myComments.where((comment) {
          final createdAt = DateTime.parse(comment['createdAt']);
          return createdAt.isAfter(weekAgo);
        }).toList();
      case 'projects':
        // Group by project - for now just return all
        return _myComments;
      default:
        return _myComments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes commentaires'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMyComments,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'Tous', Icons.comment),
                        const SizedBox(width: 8),
                        _buildFilterChip('recent', 'Récents', Icons.access_time),
                        const SizedBox(width: 8),
                        _buildFilterChip('projects', 'Par projet', Icons.folder),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Comments list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredComments.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadMyComments,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredComments.length,
                          itemBuilder: (context, index) {
                            final comment = _filteredComments[index];
                            return _buildCommentCard(comment);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
      selectedColor: const Color(0xFF4A90E2).withOpacity(0.2),
      checkmarkColor: const Color(0xFF4A90E2),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.comment_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun commentaire',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous n\'avez pas encore laissé de commentaires sur les projets.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.folder),
            label: const Text('Voir les projets'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment) {
    final createdAt = DateTime.parse(comment['createdAt']);
    final timeAgo = _getTimeAgo(createdAt);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project info header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.folder,
                    size: 20,
                    color: Color(0xFF4A90E2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment['projectName'] ?? 'Projet',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (comment['projectDescription'] != null && 
                          comment['projectDescription'].isNotEmpty)
                        Text(
                          comment['projectDescription'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          // Comment content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment['content'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Actions
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _viewProject(comment['projectId']),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Voir le projet'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _editComment(comment),
                      icon: const Icon(Icons.edit, size: 18),
                      tooltip: 'Modifier',
                    ),
                    IconButton(
                      onPressed: () => _deleteComment(comment['commentId']),
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      tooltip: 'Supprimer',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  void _viewProject(String projectId) {
    // Navigate to project details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation vers le projet - À implémenter')),
    );
  }

  void _editComment(Map<String, dynamic> comment) {
    final controller = TextEditingController(text: comment['content']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le commentaire'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Commentaire',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _commentService.updateComment(
                  comment['commentId'],
                  controller.text.trim(),
                );
                Navigator.pop(context);
                _loadMyComments();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Commentaire modifié')),
                );
              }
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _deleteComment(String commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le commentaire'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce commentaire ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _commentService.deleteComment(commentId);
              Navigator.pop(context);
              _loadMyComments();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Commentaire supprimé')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}