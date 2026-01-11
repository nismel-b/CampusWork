import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:campuswork/model/comment.dart';

class CommentService {
  static final CommentService _instance = CommentService._internal();
  factory CommentService() => _instance;
  CommentService._internal();

  static const _commentsKey = 'comments';
  List<Comment> _comments = [];

  Future<void> init() async {
    await _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsData = prefs.getString(_commentsKey);
      if (commentsData != null) {
        final List<dynamic> commentsList = jsonDecode(commentsData);
        _comments = commentsList.map((json) => Comment.fromMap(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load comments: $e');
      _comments = [];
    }
  }

  Future<void> _saveComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_commentsKey, jsonEncode(_comments.map((c) => c.toMap()).toList()));
    } catch (e) {
      debugPrint('Failed to save comments: $e');
    }
  }

  // Ajouter un commentaire
  Future<bool> addComment(Comment comment) async {
    try {
      _comments.add(comment);
      await _saveComments();
      return true;
    } catch (e) {
      debugPrint('Failed to add comment: $e');
      return false;
    }
  }

  // Obtenir les commentaires d'un projet
  List<Comment> getCommentsByProject(String projectId) {
    return _comments.where((c) => c.projectId == projectId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Obtenir les commentaires d'un utilisateur (format Map pour compatibilité)
  Future<List<Map<String, dynamic>>> getCommentsByUser(String userId) async {
    await _loadComments();
    final userComments = _comments.where((c) => c.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return userComments.map((comment) => {
      'commentId': comment.commentId,
      'projectId': comment.projectId,
      'userId': comment.userId,
      'userFullName': comment.userFullName,
      'content': comment.content,
      'createdAt': comment.createdAt.toIso8601String(),
    }).toList();
  }

  // Mettre à jour un commentaire
  Future<bool> updateComment(String commentId, String newContent) async {
    try {
      final commentIndex = _comments.indexWhere((c) => c.commentId == commentId);
      if (commentIndex != -1) {
        final oldComment = _comments[commentIndex];
        _comments[commentIndex] = Comment(
          commentId: oldComment.commentId,
          projectId: oldComment.projectId,
          userId: oldComment.userId,
          userFullName: oldComment.userFullName,
          content: newContent,
          createdAt: oldComment.createdAt,
        );
        await _saveComments();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Failed to update comment: $e');
      return false;
    }
  }

  // Supprimer un commentaire
  Future<bool> deleteComment(String commentId) async {
    try {
      _comments.removeWhere((c) => c.commentId == commentId);
      await _saveComments();
      return true;
    } catch (e) {
      debugPrint('Failed to delete comment: $e');
      return false;
    }
  }

  // Obtenir un commentaire par ID
  Comment? getCommentById(String commentId) {
    try {
      return _comments.firstWhere((c) => c.commentId == commentId);
    } catch (e) {
      return null;
    }
  }

  // Obtenir le nombre de commentaires d'un projet
  int getCommentsCount(String projectId) {
    return _comments.where((c) => c.projectId == projectId).length;
  }

  // Obtenir tous les commentaires
  List<Comment> getAllComments() => List.unmodifiable(_comments);

  // Rechercher des commentaires
  List<Comment> searchComments(String query) {
    if (query.isEmpty) return getAllComments();
    
    return _comments.where((comment) =>
      comment.content.toLowerCase().contains(query.toLowerCase()) ||
      comment.userFullName.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}