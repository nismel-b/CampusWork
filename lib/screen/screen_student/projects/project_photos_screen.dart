import 'package:flutter/material.dart';
import 'package:store_buy/service/store_photo_service.dart';
import 'package:image_picker/image_picker.dart';


/// Écran pour gérer les photos du magasin physique
class StorePhotosScreen extends StatefulWidget {
  final String storeId;
  const StorePhotosScreen({super.key, required this.storeId});

  @override
  State<StorePhotosScreen> createState() => _StorePhotosScreenState();
}

class _StorePhotosScreenState extends State<StorePhotosScreen> {
  final StorePhotoService _photoService = StorePhotoService();
  final ImagePicker _imagePicker = ImagePicker();
  List<Map<String, dynamic>> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final photos = await _photoService.getStorePhotos(widget.storeId);
    setState(() {
      _photos = photos;
      _isLoading = false;
    });
  }

  Future<void> _addPhoto() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      // In a real app, upload to cloud storage and get URL
      // For now, use file path
      final success = await _photoService.addStorePhoto(
        storeId: widget.storeId,
        photoUrl: pickedFile.path,
      );

      if (success) {
        _loadPhotos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo ajoutée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Future<void> _deletePhoto(String photoId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la photo'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette photo?'),
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
      await _photoService.deletePhoto(photoId);
      _loadPhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos du magasin'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: _photos.length + 1, // +1 for add button
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: _addPhoto,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('Ajouter une photo', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }

                final photo = _photos[index - 1];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        photo['photoUrl'] ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePhoto(photo['photoId']),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}


