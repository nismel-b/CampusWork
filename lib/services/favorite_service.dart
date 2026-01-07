
import 'package:flutter/foundation.dart';
import 'package:campuswork/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Service pour gérer les projets mis en favoris
class FavoriteService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Ajouter un projet aux favoris
  Future<bool> addProjectToFavorites({
    required String userId,
    required String projectId,
  }) async {
    try {
      final db = await _dbHelper.database;
      final favoriteId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('favorites', {
        'favoriteId': favoriteId,
        'userId': userId,
        'projectId': projectId,
        'createdAt': now,
      });

      return true;
    } catch (e) {
      debugPrint('Error adding project to favorites: $e');
      return false;
    }
  }

  /// Retirer un projet des favoris
  Future<bool> removeProjectFromFavorites(String userId, String projectId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'favorites',
        where: 'userId = ? AND projectId = ?',
        whereArgs: [userId, projectId],
      );
      return true;
    } catch (e) {
      debugPrint('Error removing project from favorites: $e');
      return false;
    }
  }

  /// Obtenir tous les projets favoris
  Future<List<Map<String, dynamic>>> getFavoriteProjects(String userId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT p.*, f.createdAt as favoritedAt
        FROM favorites f
        JOIN projects p ON f.projectId = p.projectId
        WHERE f.userId = ?
        ORDER BY f.createdAt DESC
      ''', [userId]);
    } catch (e) {
      debugPrint('Error getting favorite projects: $e');
      return [];
    }
  }
}


