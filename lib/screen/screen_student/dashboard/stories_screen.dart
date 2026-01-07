import 'package:flutter/material.dart';
import 'package:store_buy/service/story_service.dart';
import 'package:store_buy/service/store_service.dart';
import 'package:store_buy/service/product_service.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StoriesScreen extends StatefulWidget {
  final String? storeId;
  const StoriesScreen({super.key, this.storeId});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final StoryService _storyService = StoryService();
  final StoreService _storeService = StoreService();
  final ProductService _productService = ProductService();
  List<Map<String, dynamic>> _stories = [];
  List<Map<String, dynamic>> _products = [];
  String? _selectedStoreId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (widget.storeId != null) {
      _selectedStoreId = widget.storeId;
    } else if (authProvider.currentUser != null) {
      final stores = await _storeService.getStoresByUserId(
        authProvider.currentUser!.userId,
      );
      if (stores.isNotEmpty) {
        _selectedStoreId = stores.first['storeId'];
      }
    }

    if (_selectedStoreId != null) {
      final stories = await _storyService.getStoriesByStore(_selectedStoreId!);
      final products = await _productService.getProductsByStore(_selectedStoreId!);
      setState(() {
        _stories = stories;
        _products = products;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addStory(String type) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddStoryDialog(products: _products, type: type),
    );

    if (result != null && _selectedStoreId != null) {
      await _storyService.addStory(
        storeId: _selectedStoreId!,
        imageUrl: result['imageUrl'] ?? '',
        type: type,
        title: result['title'],
        description: result['description'],
        promotionPrice: result['promotionPrice'],
        productId: result['productId'],
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
                          onPressed: () => _addStory('promotion'),
                          icon: const Icon(Icons.local_offer),
                          label: const Text('Promotion'),
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
                                            if (story['type'] == 'promotion' && story['promotionPrice'] != null)
                                              Text(
                                                '${story['promotionPrice']} FCFA',
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
  final List<Map<String, dynamic>> products;
  final String type;
  const _AddStoryDialog({required this.products, required this.type});

  @override
  State<_AddStoryDialog> createState() => _AddStoryDialogState();
}

class _AddStoryDialogState extends State<_AddStoryDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  String? _selectedProductId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.type == 'promotion' ? 'Nouvelle promotion' : 'Nouvelle annonce'),
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
            if (widget.type == 'promotion') ...[
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Prix promotionnel'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedProductId,
                decoration: const InputDecoration(labelText: 'Produit'),
                items: widget.products.map<DropdownMenuItem<String>>((p) {
                  return DropdownMenuItem<String>(
                    value: p['productId'] as String?,
                    child: Text(p['productName'] ?? ''),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedProductId = value),
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
              'productId': _selectedProductId,
            });
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}

