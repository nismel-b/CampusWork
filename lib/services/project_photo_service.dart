import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ProjectPhotoService {
  static final ProjectPhotoService _instance = ProjectPhotoService._internal();
  factory ProjectPhotoService() => _instance;
  ProjectPhotoService._internal();

  static const _photosKey = 'project_photos';
  List<Map<String, dynamic>> _photos = [];

  Future<void> init() async {
    await _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photosData = prefs.getString(_photosKey);
      if (photosData != null) {
        final List<dynamic> photosList = jsonDecode(photosData);
        _photos = photosList.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Failed to load project photos: $e');
      _photos = [];
    }
  }

  Future<void> _savePhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_photosKey, jsonEncode(_photos));
    } catch (e) {
      debugPrint('Failed to save project photos: $e');
    }
  }

  /// Obtenir toutes les photos d'un projet
  Future<List<Map<String, dynamic>>> getProjectPhotos(String projectId) async {
    await _loadPhotos();
    return _photos.where((photo) => photo['projectId'] == projectId).toList();
  }

  /// Ajouter une photo à un projet
  Future<bool> addProjectPhoto({
    required String projectId,
    required String photoUrl,
    String? description,
  }) async {
    try {
      final photoId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final photo = {
        'photoId': photoId,
        'projectId': projectId,
        'photoUrl': photoUrl,
        'description': description,
        'createdAt': now,
      };

      _photos.add(photo);
      await _savePhotos();
      return true;
    } catch (e) {
      debugPrint('Failed to add project photo: $e');
      return false;
    }
  }

  /// Supprimer une photo
  Future<bool> deletePhoto(String photoId) async {
    try {
      _photos.removeWhere((photo) => photo['photoId'] == photoId);
      await _savePhotos();
      return true;
    } catch (e) {
      debugPrint('Failed to delete project photo: $e');
      return false;
    }
  }

  /// Mettre à jour la description d'une photo
  Future<bool> updatePhotoDescription(String photoId, String description) async {
    try {
      final index = _photos.indexWhere((photo) => photo['photoId'] == photoId);
      if (index != -1) {
        _photos[index]['description'] = description;
        await _savePhotos();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Failed to update photo description: $e');
      return false;
    }
  }

  /// Supprimer toutes les photos d'un projet
  Future<bool> deleteProjectPhotos(String projectId) async {
    try {
      _photos.removeWhere((photo) => photo['projectId'] == projectId);
      await _savePhotos();
      return true;
    } catch (e) {
      debugPrint('Failed to delete project photos: $e');
      return false;
    }
  }

  /// Obtenir le nombre de photos d'un projet
  Future<int> getProjectPhotosCount(String projectId) async {
    await _loadPhotos();
    return _photos.where((photo) => photo['projectId'] == projectId).length;
  }

  /// Obtenir toutes les photos (pour administration)
  Future<List<Map<String, dynamic>>> getAllPhotos() async {
    await _loadPhotos();
    return List.unmodifiable(_photos);
  }
}