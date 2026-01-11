import 'package:flutter/material.dart';
import '../../../model/user.dart';
import '../../../components/components.dart';
import '../../../services/story_service.dart';
import 'create_story_page.dart';
import 'story_viewer_page.dart';

class StoryPage extends StatefulWidget {
  final User currentUser;

  const StoryPage({super.key, required this.currentUser});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final StoryService _storyService = StoryService();
  List<Map<String, dynamic>> _stories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    setState(() => _isLoading = true);
    try {
      final stories = await _storyService.getAllStories();
      setState(() {
        _stories = stories;
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

  void _openStoryViewer(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewerPage(
          stories: _stories,
          initialIndex: index,
          currentUser: widget.currentUser,
        ),
      ),
    ).then((_) => _loadStories());
  }

  void _createStory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateStoryPage(currentUser: widget.currentUser),
      ),
    ).then((_) => _loadStories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _createStory,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStories,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingState(message: 'Chargement des stories...')
          : _stories.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadStories,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _stories.length,
                    itemBuilder: (context, index) {
                      final story = _stories[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildStoryCard(story, index),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune story disponible',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Soyez le premier à partager une story !',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createStory,
            icon: const Icon(Icons.add),
            label: const Text('Créer une story'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(Map<String, dynamic> story, int index) {
    return CustomCard(
      onTap: () => _openStoryViewer(index),
      child: Row(
        children: [
          // User Avatar with Story Ring
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha:0.6),
                ],
              ),
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 22,
                backgroundImage: story['user_avatar'] != null
                    ? NetworkImage(story['user_avatar'])
                    : null,
                child: story['user_avatar'] == null
                    ? Text(
                        story['username']?[0]?.toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Story Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story['username'] ?? 'Utilisateur',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                if (story['content'] != null && story['content'].toString().isNotEmpty)
                  Text(
                    story['content'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      story['created_at'] ?? '',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Story Preview
          if (story['media_url'] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                story['media_url'],
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
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            )
          else
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.text_fields,
                color: Theme.of(context).primaryColor,
              ),
            ),
          
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
