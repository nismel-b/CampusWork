
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Service pour gérer les commentaires sur les stories
class StoryCommentService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Ajouter un commentaire sur une story
  Future<bool> addComment({
    required String storyId,
    required String userId,
    required String content,
  }) async {
    try {
      final db = await _dbHelper.database;
      final commentId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('story_comments', {
        'commentId': commentId,
        'storyId': storyId,
        'userId': userId,
        'content': content,
        'createdAt': now,
      });

      return true;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return false;
    }
  }

  /// Obtenir les commentaires d'une story
  Future<List<Map<String, dynamic>>> getStoryComments(String storyId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT sc.*, u.name as userName, u.username
        FROM story_comments sc
        JOIN users u ON sc.userId = u.userId
        WHERE sc.storyId = ?
        ORDER BY sc.createdAt ASC
      ''', [storyId]);
    } catch (e) {
      debugPrint('Error getting comments: $e');
      return [];
    }
  }

  /// Supprimer un commentaire
  Future<bool> deleteComment(String commentId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('story_comments', where: 'commentId = ?', whereArgs: [commentId]);
      return true;
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      return false;
    }
  }
}


