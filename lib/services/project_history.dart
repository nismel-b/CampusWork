
import 'package:flutter/foundation.dart';
import 'package:campuswork/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ProjectHistoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Add history entry
  Future<void> addHistory({
    required String projectId,
    required String action,
    String? details,
    String? userId,
  }) async {
    try {
      final db = await _dbHelper.database;
      final historyId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('store_history', {
        'historyId': historyId,
        'projectId': projectId,
        'action': action,
        'details': details,
        'userId': userId,
        'createdAt': now,
      });
    } catch (e) {
      debugPrint('Error adding history: $e');
    }
  }

  // Get history by project with date range
  Future<List<Map<String, dynamic>>> getHistoryByProject(
      String projectId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      final db = await _dbHelper.database;
      String query = '''
        SELECT h.*, u.name as userName
        FROM store_history h
        LEFT JOIN users u ON h.userId = u.userId
        WHERE h.projectId = ?
      ''';
      List<dynamic> args = [projectId];

      if (startDate != null) {
        query += ' AND h.createdAt >= ?';
        args.add(DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate));
      }

      if (endDate != null) {
        query += ' AND h.createdAt <= ?';
        args.add(DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate));
      }

      query += ' ORDER BY h.createdAt DESC';

      return await db.rawQuery(query, args);
    } catch (e) {
      debugPrint('Error getting history: $e');
      return [];
    }
  }

  // Get monthly statistics
  Future<Map<String, dynamic>> getMonthlyStats(String projectId, int monthsBack) async {
    try {
      final db = await _dbHelper.database;
      final startDate = DateTime.now().subtract(Duration(days: 30 * monthsBack));
      final startDateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate);

      // Get projects added
      final projectsStats = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM projects
        WHERE projectId = ? AND createdAt >= ?
      ''', [projectId, startDateStr]);

      // Get history actions
      final historyStats = await db.rawQuery('''
        SELECT action, COUNT(*) as count
        FROM store_history
        WHERE projectId = ? AND createdAt >= ?
        GROUP BY action
      ''', [projectId, startDateStr]);

      return {
        'projects': {
          'count': projectsStats.first['count'] ?? 0,
        },
        'actions': historyStats.map((e) => {
          'action': e['action'],
          'count': e['count'],
        }).toList(),
      };
    } catch (e) {
      debugPrint('Error getting monthly stats: $e');
      return {};
    }
  }
}
