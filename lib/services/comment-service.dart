import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/model/comments.dart';

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
        _comments = commentsList.map((json) => Comment.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load comments: $e');
      _comments = [];
    }
  }

  Future<void> _saveComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_commentsKey, jsonEncode(_comments.map((c) => c.toJson()).toList()));
    } catch (e) {
      debugPrint('Failed to save comments: $e');
    }
  }

  List<Comment> getCommentsByProject(String projectId) =>
      _comments.where((c) => c.projectId == projectId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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

  Future<bool> deleteComment(String commentId) async {
    try {
      _comments.removeWhere((c) => c.id == commentId);
      await _saveComments();
      return true;
    } catch (e) {
      debugPrint('Failed to delete comment: $e');
      return false;
    }
  }

  int getCommentCountByProject(String projectId) =>
      _comments.where((c) => c.projectId == projectId).length;
}
