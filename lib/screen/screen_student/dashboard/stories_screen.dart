import 'package:flutter/material.dart';
import 'package:campuswork/services/story_service.dart';
import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/model/user.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StoriesScreen extends StatefulWidget {
  final User currentUser;
  const StoriesScreen({super.key, required this.currentUser});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final StoryService _storyService = StoryService();
  final ProjectService _projectService = ProjectService();
  List<Map<String, dynamic>> _stories = [];
  List<Map<String, dynamic>> _projects = [];
  String? _selectedProjectId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Get user's projects
      final projects = await _projectService.getProjectByUserId(widget.currentUser.userId);
      
      // Get user's stories
      final stories = await _storyService.getStoriesByUser(widget.currentUser.userId);
      
      setState(() {
        _stories = stories;
        _projects = projects.map((p) => {
          'projectId': p.projectId,
          'projectName': p.projectName,
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addStory(String type) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddStoryDialog(projects: _projects, type: type),
    );

    if (result != null) {
      await _storyService.createStory(
        userId: widget.currentUser.userId,
        title: result['title'] ?? '',
        description: result['description'] ?? '',
        type: type,
        imageUrl: result['imageUrl'],
        projectId: result['projectId'],
      );
      _loadData();
    }
  }

  Future<void> _deleteStory(String storyId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la story'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette story?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storyService.deleteStory(storyId);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _addStory('announcement'),
                          icon: const Icon(Icons.campaign),
                          label: const Text('Annonce'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _addStory('Confession'),
                          icon: const Icon(Icons.local_offer),
                          label: const Text('Confession'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _stories.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_stories, size: 100, color: Colors.grey),
                              SizedBox(height: 20),
                              Text(
                                'Aucune story',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: _stories.length,
                            itemBuilder: (context, index) {
                              final story = _stories[index];
                              return Card(
                                child: Stack(
                                  children: [
                                    story['imageUrl'] != null && story['imageUrl'].toString().isNotEmpty
                                        ? Image.network(
                                            story['imageUrl'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(Icons.image, size: 50);
                                            },
                                          )
                                        : const Icon(Icons.image, size: 50),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteStory(story['storyId']),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withValues(alpha:0.7),
                                            ],
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (story['title'] != null)
                                              Text(
                                                story['title'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            if (story['type'] == 'confession' && story['confession'] != null)
                                              Text(
                                                '${story['mots_clé']}',
                                                style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _AddStoryDialog extends StatefulWidget {
  final List<Map<String, dynamic>> projects;
  final String type;
  const _AddStoryDialog({required this.projects, required this.type});

  @override
  State<_AddStoryDialog> createState() => _AddStoryDialogState();
}

class _AddStoryDialogState extends State<_AddStoryDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  String? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.type == 'confession' ? 'Nouvelle confession' : 'Nouvelle annonce'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                final image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() => _imagePath = image.path);
                }
              },
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _imagePath != null
                    ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                    : const Icon(Icons.add_photo_alternate, size: 50),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            if (widget.type == 'confession') ...[
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Mots_clé'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedProjectId,
                decoration: const InputDecoration(labelText: 'Projet'),
                items: widget.projects.map<DropdownMenuItem<String>>((p) {
                  return DropdownMenuItem<String>(
                    value: p['projectId'] as String?,
                    child: Text(p['projectName'] ?? ''),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedProjectId = value),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'imageUrl': _imagePath ?? '',
              'title': _titleController.text,
              'description': _descriptionController.text,
              'promotionPrice': _priceController.text.isNotEmpty
                  ? double.tryParse(_priceController.text)
                  : null,
              'projectId': _selectedProjectId,
            });
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}

