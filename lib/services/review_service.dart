
import 'package:flutter/foundation.dart';
import 'package:store_buy/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ReviewService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Add review
  Future<bool> addReview({
    required String userId,
    required String productId,
    required int rating,
    String? comment,
  }) async {
    try {
      final db = await _dbHelper.database;
      final reviewId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('reviews', {
        'reviewId': reviewId,
        'userId': userId,
        'productId': productId,
        'rating': rating,
        'comment': comment,
        'createdAt': now,
      });

      return true;
    } catch (e) {
      debugPrint('Error adding review: $e');
      return false;
    }
  }

  // Get reviews by product
  Future<List<Map<String, dynamic>>> getReviewsByProduct(String productId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT r.*, u.name as userName, u.username
        FROM reviews r
        JOIN users u ON r.userId = u.userId
        WHERE r.productId = ?
        ORDER BY r.createdAt DESC
      ''', [productId]);
    } catch (e) {
      debugPrint('Error getting reviews: $e');
      return [];
    }
  }

  // Get reviews by store
  Future<List<Map<String, dynamic>>> getReviewsByStore(String storeId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT r.*, p.productName, u.name as userName
        FROM reviews r
        JOIN products p ON r.productId = p.productId
        JOIN users u ON r.userId = u.userId
        WHERE p.storeId = ?
        ORDER BY r.createdAt DESC
      ''', [storeId]);
    } catch (e) {
      debugPrint('Error getting reviews by store: $e');
      return [];
    }
  }

  // Get average rating for product
  Future<double> getAverageRating(String productId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT AVG(rating) as avgRating
        FROM reviews
        WHERE productId = ?
      ''', [productId]);
      return (result.first['avgRating'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('Error getting average rating: $e');
      return 0.0;
    }
  }
}


