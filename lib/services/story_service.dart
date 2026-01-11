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

  // Create story (method needed by create_story_page.dart)
  Future<bool> createStory({
    required String userId,
    required String title,
    required String description,
    required String type,
    String? imageUrl,
    String? projectId,
    int hoursToExpire = 24,
  }) async {
    final storyId = const Uuid().v4();
    final now = DateTime.now();
    final expiresAt = now.add(Duration(hours: hoursToExpire));
    
    return await addStory(
      userId: userId,
      storyId: storyId,
      imageUrl: imageUrl ?? '',
      type: type,
      title: title,
      description: description,
      projectId: projectId,
      createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
      expiresAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(expiresAt),
      hoursToExpire: hoursToExpire,
    );
  }

  // Get all stories (method needed by story_page.dart)
  Future<List<Map<String, dynamic>>> getAllStories() async {
    try {
      final db = await _dbHelper.database;
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      return await db.rawQuery('''
        SELECT * FROM stories
        WHERE expiresAt > ?
        ORDER BY createdAt DESC
      ''', [now]);
    } catch (e) {
      debugPrint('Error getting all stories: $e');
      return [];
    }
  }

  // Get stories by project (method needed by stories_screen.dart)
  Future<List<Map<String, dynamic>>> getStoriesByProject(String projectId) async {
    try {
      final db = await _dbHelper.database;
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      return await db.rawQuery('''
        SELECT * FROM stories
        WHERE projectId = ? AND expiresAt > ?
        ORDER BY createdAt DESC
      ''', [projectId, now]);
    } catch (e) {
      debugPrint('Error getting stories by project: $e');
      return [];
    }
  }
}


