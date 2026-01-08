import 'package:flutter/foundation.dart';
import 'package:campuswork/database/database_helper.dart';
import 'package:intl/intl.dart';

class CardService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Add project to user panel (card)
  Future<bool> addToPanel({
    required String cardId,
    required String userId,
    required String projectId,
  }) async {
    try {
      final db = await _dbHelper.database;

      final existing = await db.query(
        'card',
        where: 'userId = ? AND projectId = ?',
        whereArgs: [userId, projectId],
      );

      if (existing.isEmpty) {
        await db.insert('card', {
          'cardId': cardId,
          'userId': userId,
          'projectId': projectId,
          'createdAt':
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        });
      }

      return true;
    } catch (e) {
      debugPrint('Error adding to panel: $e');
      return false;
    }
  }

  /// Get user panel items with project details
  Future<List<Map<String, dynamic>>> getPanelItems(String userId) async {
    try {
      final db = await _dbHelper.database;

      return await db.rawQuery('''
        SELECT 
          c.cardId,
          c.createdAt,
          p.projectId,
          p.projectName,
          p.imageUrl,
          u.username
        FROM card c
        JOIN projects p ON c.projectId = p.projectId
        JOIN users u ON p.userId = u.userId
        WHERE c.userId = ?
        ORDER BY c.createdAt DESC
      ''', [userId]);
    } catch (e) {
      debugPrint('Error getting panel items: $e');
      return [];
    }
  }

  /// Remove a project from user panel
  Future<bool> removeFromPanel(String userId, String projectId) async {
    try {
      final db = await _dbHelper.database;

      await db.delete(
        'card',
        where: 'userId = ? AND projectId = ?',
        whereArgs: [userId, projectId],
      );

      return true;
    } catch (e) {
      debugPrint('Error removing from panel: $e');
      return false;
    }
  }

  /// Clear user panel
  Future<bool> clearPanel(String userId) async {
    try {
      final db = await _dbHelper.database;

      await db.delete(
        'card',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      return true;
    } catch (e) {
      debugPrint('Error clearing panel: $e');
      return false;
    }
  }

  /// Get number of items in panel
  Future<int> getPanelCount(String userId) async {
    try {
      final db = await _dbHelper.database;

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM card WHERE userId = ?',
        [userId],
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('Error getting panel count: $e');
      return 0;
    }
  }
}
