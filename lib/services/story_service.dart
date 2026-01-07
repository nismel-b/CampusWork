import 'package:flutter/foundation.dart';
import 'package:campuswork/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class StoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Add story
  Future<bool> addStory({
    required String userId,
    required String storyId,
    required String imageUrl,
    required String type, // 'pour demander de l'aide par exemple'
    required String title,
    required String description,
    String? projectId,
    required String createdAt,
    required String expiresAt,
    int hoursToExpire = 24,
  }) async {
    try {
      final db = await _dbHelper.database;
      final storyId = const Uuid().v4();
      final now = DateTime.now();
      final expiresAt = now.add(Duration(hours: hoursToExpire));

      await db.insert('stories', {
        'storyId': storyId,
        'userId': userId,
        'imageUrl': imageUrl,
        'type': type,
        'title': title,
        'description': description,
        'projectId': projectId,
        'createdAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
        'expiresAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(expiresAt),
      });

      return true;
    } catch (e) {
      debugPrint('Error adding story: $e');
      return false;
    }
  }

  // Get active stories by user
  Future<List<Map<String, dynamic>>> getActiveStoriesByUser(String userId) async {
    try {
      final db = await _dbHelper.database;
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      return await db.rawQuery('''
        SELECT * FROM stories
        WHERE userId = ? AND expiresAt > ?
        ORDER BY createdAt DESC
      ''', [userId, now]);
    } catch (e) {
      debugPrint('Error getting stories: $e');
      return [];
    }
  }

  // Get all stories by user
  Future<List<Map<String, dynamic>>> getStoriesByUser(String userId) async {
    try {
      final db = await _dbHelper.database;
      return await db.query(
        'stories',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      debugPrint('Error getting stories: $e');
      return [];
    }
  }

  // Delete story
  Future<bool> deleteStory(String storyId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('stories', where: 'storyId = ?', whereArgs: [storyId]);
      return true;
    } catch (e) {
      debugPrint('Error deleting story: $e');
      return false;
    }
  }
}


