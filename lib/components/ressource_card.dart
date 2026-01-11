import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum ResourceType {
  document,
  video,
  link,
  image,
  code,
  presentation,
  other,
}

class Resource {
  final String title;
  final String? description;
  final String url;
  final ResourceType type;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final String? author;

  Resource({
    required this.title,
    this.description,
    required this.url,
    required this.type,
    this.thumbnailUrl,
    this.createdAt,
    this.author,
  });
}

class ResourceCard extends StatelessWidget {
  final Resource resource;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final bool showActions;

  const ResourceCard({
    super.key,
    required this.resource,
    this.onTap,
    this.onDownload,
    this.onShare,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap ?? () => _openResource(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec icône et type
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(resource.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(resource.type),
                      color: _getTypeColor(resource.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _getTypeLabel(resource.type),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getTypeColor(resource.type),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Thumbnail si disponible
              if (resource.thumbnailUrl != null && resource.thumbnailUrl!.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      resource.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getTypeIcon(resource.type),
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Description
              if (resource.description != null && resource.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    resource.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Informations supplémentaires
              Row(
                children: [
                  if (resource.author != null)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              resource.author!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (resource.createdAt != null)
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(resource.createdAt!),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Actions
              if (showActions)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _openResource(context),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Ouvrir'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      if (onDownload != null)
                        TextButton.icon(
                          onPressed: onDownload,
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Télécharger'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      if (onShare != null)
                        TextButton.icon(
                          onPressed: onShare,
                          icon: const Icon(Icons.share, size: 16),
                          label: const Text('Partager'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(ResourceType type) {
    switch (type) {
      case ResourceType.document:
        return Icons.description;
      case ResourceType.video:
        return Icons.play_circle;
      case ResourceType.link:
        return Icons.link;
      case ResourceType.image:
        return Icons.image;
      case ResourceType.code:
        return Icons.code;
      case ResourceType.presentation:
        return Icons.slideshow;
      case ResourceType.other:
        return Icons.attachment;
    }
  }

  Color _getTypeColor(ResourceType type) {
    switch (type) {
      case ResourceType.document:
        return Colors.blue;
      case ResourceType.video:
        return Colors.red;
      case ResourceType.link:
        return Colors.green;
      case ResourceType.image:
        return Colors.purple;
      case ResourceType.code:
        return Colors.orange;
      case ResourceType.presentation:
        return Colors.teal;
      case ResourceType.other:
        return Colors.grey;
    }
  }

  String _getTypeLabel(ResourceType type) {
    switch (type) {
      case ResourceType.document:
        return 'Document';
      case ResourceType.video:
        return 'Vidéo';
      case ResourceType.link:
        return 'Lien';
      case ResourceType.image:
        return 'Image';
      case ResourceType.code:
        return 'Code';
      case ResourceType.presentation:
        return 'Présentation';
      case ResourceType.other:
        return 'Autre';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  Future<void> _openResource(BuildContext context) async {
    try {
      final uri = Uri.parse(resource.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir cette ressource'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
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

// Widget pour afficher une grille de ressources
class ResourceGrid extends StatelessWidget {
  final List<Resource> resources;
  final Function(Resource)? onResourceTap;
  final Function(Resource)? onResourceDownload;
  final Function(Resource)? onResourceShare;

  const ResourceGrid({
    super.key,
    required this.resources,
    this.onResourceTap,
    this.onResourceDownload,
    this.onResourceShare,
  });

  @override
  Widget build(BuildContext context) {
    if (resources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucune ressource disponible',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return ResourceCard(
          resource: resource,
          onTap: onResourceTap != null ? () => onResourceTap!(resource) : null,
          onDownload: onResourceDownload != null ? () => onResourceDownload!(resource) : null,
          onShare: onResourceShare != null ? () => onResourceShare!(resource) : null,
        );
      },
    );
  }
}

// Widget pour afficher une liste de ressources
class ResourceList extends StatelessWidget {
  final List<Resource> resources;
  final Function(Resource)? onResourceTap;
  final Function(Resource)? onResourceDownload;
  final Function(Resource)? onResourceShare;

  const ResourceList({
    super.key,
    required this.resources,
    this.onResourceTap,
    this.onResourceDownload,
    this.onResourceShare,
  });

  @override
  Widget build(BuildContext context) {
    if (resources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucune ressource disponible',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ResourceCard(
            resource: resource,
            onTap: onResourceTap != null ? () => onResourceTap!(resource) : null,
            onDownload: onResourceDownload != null ? () => onResourceDownload!(resource) : null,
            onShare: onResourceShare != null ? () => onResourceShare!(resource) : null,
          ),
        );
      },
    );
  }
}