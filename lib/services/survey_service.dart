
import 'package:flutter/foundation.dart';
import 'package:campuswork/database/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Service pour gérer les sondages des utilisateurs
class SurveyService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Créer un sondage
  Future<bool> createSurvey({
    required String surveyId,
    required String userId,
    required String question,
    required String type, // 'yes_no', 'multiple_choice', 'text'
    List<String>? options,
    required DateTime createdAt,
    DateTime? expiresAt,
  }) async {
    try {
      final db = await _dbHelper.database;
      final surveyId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('surveys', {
        'surveyId': surveyId,
        'userId': userId,
        'question': question,
        'type': type,
        'options': options?.join('|'),
        'createdAt': now,
        'expiresAt': expiresAt?.toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error creating survey: $e');
      return false;
    }
  }

  /// Obtenir les sondages actifs d'un utilisateur
  Future<List<Map<String, dynamic>>> getActiveSurveys(String userId) async {
    try {
      final db = await _dbHelper.database;
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      
      return await db.rawQuery('''
        SELECT * FROM surveys
        WHERE userId = ? 
          AND (expiresAt IS NULL OR expiresAt > ?)
        ORDER BY createdAt DESC
      ''', [userId, now]);
    } catch (e) {
      debugPrint('Error getting active surveys: $e');
      return [];
    }
  }

  /// Obtenir les sondages pour les utilisateurs(ceux que les autres ont postés)
  Future<List<Map<String, dynamic>>> getSurveysForCustomer(String userId) async {
    try {
      final db = await _dbHelper.database;
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      
      // Get surveys from stores where user has made purchases
      return await db.rawQuery('''
        SELECT DISTINCT s.*, st.storename
        FROM surveys s
        JOIN stores st ON s.storeId = st.storeId
        JOIN orders o ON o.storeId = s.storeId
        WHERE o.userId = ?
          AND (s.expiresAt IS NULL OR s.expiresAt > ?)
          AND s.surveyId NOT IN (
            SELECT surveyId FROM survey_responses WHERE userId = ?
          )
        ORDER BY s.createdAt DESC
      ''', [userId, now, userId]);
    } catch (e) {
      debugPrint('Error getting surveys for customer: $e');
      return [];
    }
  }

  /// Répondre à un sondage
  Future<bool> respondToSurvey({
    required String surveyId,
    required String userId,
    required String responseId,
    required String answer,
    required DateTime createdAt,
  }) async {
    try {
      final db = await _dbHelper.database;
      final responseId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('survey_responses', {
        'responseId': responseId,
        'surveyId': surveyId,
        'userId': userId,
        'answer': answer,
        'createdAt': now,
      });

      return true;
    } catch (e) {
      debugPrint('Error responding to survey: $e');
      return false;
    }
  }

  /// Obtenir les réponses d'un sondage
  Future<List<Map<String, dynamic>>> getSurveyResponses(String surveyId) async {
    try {
      final db = await _dbHelper.database;
      return await db.rawQuery('''
        SELECT sr.*, u.name as userName, u.username
        FROM survey_responses sr
        JOIN user u ON sr.userId = u.userId
        WHERE sr.surveyId = ?
        ORDER BY sr.createdAt DESC
      ''', [surveyId]);
    } catch (e) {
      debugPrint('Error getting survey responses: $e');
      return [];
    }
  }

  /// Supprimer un sondage
  Future<bool> deleteSurvey(String surveyId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('surveys', where: 'surveyId = ?', whereArgs: [surveyId]);
      return true;
    } catch (e) {
      debugPrint('Error deleting survey: $e');
      return false;
    }
  }
}


