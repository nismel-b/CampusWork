
import 'package:flutter/foundation.dart';
import 'package:campuswork/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:campuswork/model/project.dart';
import 'package:campuswork/components/projects/project_card.dart';

class CardService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Add item to panel
  Future<bool> addToPanel({
    required String userId,
    required String projectId,
    required String cardId,
    required DateTime createdAt,
  }) async {
    try {
      final db = await _dbHelper.database;
      
      // Check if item already exists in cart
      final existing = await db.query(
        'card',
        where: 'userId = ? AND projectId = ?',
        whereArgs: [userId, projectId],
      );

      if (existing.isNotEmpty) {
        // Update information
        await db.update(
          'card',
          where: 'userId = ? AND projectId = ?',
          whereArgs: [userId, projectId],
        );
      } else {
        // Add new item
        final projectId = const Uuid().v4();
        final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        await db.insert('card', {
          'cardId': cardId,
          'userId': userId,
          'projectId': projectId,
          'createdAt': now,
        });
      }
      return true;
    } catch (e) {
      debugPrint('Error adding to card: $e');
      return false;
    }
  }

  // Get cart items with project details
  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT c.*, p.projectName, p.imageurl, p.userId, s.username
        FROM cart c
        JOIN projects p ON c.projectId = p.projectId
        JOIN user ON p.userId = s.userId
        WHERE c.userId = ?
        ORDER BY c.createdAt DESC
      ''', [userId]);
    } catch (e) {
      debugPrint('Error getting cart items: $e');
      return [];
    }
  }
/*
  // Update cart item quantity
  Future<bool> updateCartItemQuantity({
    required String userId,
    required String productId,
  
  }) async {
    try {
      final db = await _dbHelper.database;
      if (quantity <= 0) {
        await db.delete(
          'cart',
          where: 'userId = ? AND productId = ?',
          whereArgs: [userId, productId],
        );
      } else {
        await db.update(
          'cart',
          {'quantity': quantity},
          where: 'userId = ? AND productId = ?',
          whereArgs: [userId, productId],
        );
      }
      return true;
    } catch (e) {
      debugPrint('Error updating cart item: $e');
      return false;
    }
  }
*/
  // Remove item from cart
  Future<bool> removeFromCart(String userId, String projectId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'cart',
        where: 'userId = ? AND productId = ?',
        whereArgs: [userId, projectId],
      );
      return true;
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      return false;
    }
  }

  // Clear cart
  Future<bool> clearCart(String userId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('cart', where: 'userId = ?', whereArgs: [userId]);
      return true;
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      return false;
    }
  }
  /*

  // Get cart total
  Future<double> getCartTotal(String userId) async {
    try {
     // final db = await _dbHelper.database;
      final items = await getCartItems(userId);
      double total = 0;
      for (var item in items) {
        total += (item['price'] as double) * (item['quantity'] as int);
      }
      return total;
    } catch (e) {
      debugPrint('Error getting cart total: $e');
      return 0.0;
    }
  }

  // Get card item count
  Future<int> getCartItemCount(String userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM cart WHERE userId = ?',
        [userId],
      );
      return result.isNotEmpty 
          ? (result.first['count'] as int?) ?? 0
          : 0;
    } catch (e) {
      debugPrint('Error getting cart count: $e');
      return 0;
    }
  }
}
*/
}