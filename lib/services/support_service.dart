
import 'package:flutter/foundation.dart';
import 'package:campuswork/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class SupportService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create support ticket
  Future<String?> createTicket({
    required String userId,
    required String subject,
    required String message,
    String? projectId,
  }) async {
    try {
      final db = await _dbHelper.database;
      final ticketId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('support_tickets', {
        'ticketId': ticketId,
        'userId': userId,
        'projectId': projectId,
        'subject': subject,
        'message': message,
        'status': 'open',
        'createdAt': now,
      });

      return ticketId;
    } catch (e) {
      debugPrint('Error creating ticket: $e');
      return null;
    }
  }

  // Get tickets by user
  Future<List<Map<String, dynamic>>> getTicketsByUser(String userId) async {
    try {
      final db = await _dbHelper.database;
      return await db.query(
        'support_tickets',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      debugPrint('Error getting tickets: $e');
      return [];
    }
  }

  // Get tickets by project
  Future<List<Map<String, dynamic>>> getTicketsByProject(String projectId) async {
    try {
      final db = await _dbHelper.database;
      return await db.query(
        'support_tickets',
        where: 'projectId = ?',
        whereArgs: [projectId],
        orderBy: 'createdAt DESC',
      );
    } catch (e) {
      debugPrint('Error getting tickets: $e');
      return [];
    }
  }

  // Update ticket status
  Future<bool> updateTicketStatus(String ticketId, String status) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'support_tickets',
        {'status': status},
        where: 'ticketId = ?',
        whereArgs: [ticketId],
      );
      return true;
    } catch (e) {
      debugPrint('Error updating ticket: $e');
      return false;
    }
  }
}


