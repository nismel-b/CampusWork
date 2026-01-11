
import 'package:flutter/foundation.dart';
import 'package:campuswork/database/database_helper.dart';
import 'package:campuswork/utils/security_helper.dart';
import 'package:campuswork/services/notification_services.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class MessageService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService();

  // Send message
  Future<bool> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? senderName,
  }) async {
    try {
      final db = await _dbHelper.database;
      final messageId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      // Sanitize content
      final sanitizedContent = SecurityHelper.sanitizeInput(content);

      await db.insert('messages', {
        'messageId': messageId,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': sanitizedContent,
        'isRead': 0,
        'createdAt': now,
      });

      // Send push notification to receiver
      await _notificationService.createNotification(receiverId, senderId);

      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  // Mark messages as read
  Future<bool> markMessagesAsRead(String userId, String otherUserId) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'messages',
        {'isRead': 1},
        where: 'senderId = ? AND receiverId = ?',
        whereArgs: [otherUserId, userId],
      );
      return true;
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
      return false;
    }
  }

  // Get unread message count
  Future<int> getUnreadCount(String userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM messages
        WHERE receiverId = ? AND isRead = 0
      ''', [userId]);
      return result.isNotEmpty
          ? (result.first['count'] as int?) ?? 0
          : 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  // Get conversation between two users
  Future<List<Map<String, dynamic>>> getConversation(
      String userId1,
      String userId2,
      ) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT m.*, u.name as senderName
        FROM messages m
        JOIN users u ON m.senderId = u.userId
        WHERE (m.senderId = ? AND m.receiverId = ?)
           OR (m.senderId = ? AND m.receiverId = ?)
        ORDER BY m.createdAt ASC
      ''', [userId1, userId2, userId2, userId1]);
    } catch (e) {
      debugPrint('Error getting conversation: $e');
      return [];
    }
  }

  // Get all conversations for a user
  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT DISTINCT
          CASE 
            WHEN m.senderId = ? THEN m.receiverId
            ELSE m.senderId
          END as otherUserId,
          u.name as otherUserName,
          (SELECT content FROM messages 
           WHERE (senderId = ? AND receiverId = otherUserId)
              OR (senderId = otherUserId AND receiverId = ?)
           ORDER BY createdAt DESC LIMIT 1) as lastMessage,
          (SELECT createdAt FROM messages 
           WHERE (senderId = ? AND receiverId = otherUserId)
              OR (senderId = otherUserId AND receiverId = ?)
           ORDER BY createdAt DESC LIMIT 1) as lastMessageTime
        FROM messages m
        JOIN users u ON (
          CASE 
            WHEN m.senderId = ? THEN m.receiverId
            ELSE m.senderId
          END = u.userId
        )
        WHERE m.senderId = ? OR m.receiverId = ?
        ORDER BY lastMessageTime DESC
      ''', [
        userId, userId, userId, userId, userId, userId, userId, userId
      ]);
    } catch (e) {
      debugPrint('Error getting conversations: $e');
      return [];
    }
  }
}
