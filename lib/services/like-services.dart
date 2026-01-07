import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/model/review.dart';

class LikeService {
  static final LikeService _instance = LikeService._internal();
  factory LikeService() => _instance;
  LikeService._internal();

  static const _likesKey = 'likes';
  List<Like> _likes = [];

  Future<void> init() async {
    await _loadLikes();
  }

  Future<void> _loadLikes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likesData = prefs.getString(_likesKey);
      if (likesData != null) {
        final List<dynamic> likesList = jsonDecode(likesData);
        _likes = likesList.map((json) => Like.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load likes: $e');
      _likes = [];
    }
  }

  Future<void> _saveLikes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_likesKey, jsonEncode(_likes.map((l) => l.toJson()).toList()));
    } catch (e) {
      debugPrint('Failed to save likes: $e');
    }
  }

  bool isLikedByUser(String projectId, String userId) =>
      _likes.any((l) => l.projectId == projectId && l.userId == userId);

  int getLikeCountByProject(String projectId) =>
      _likes.where((l) => l.projectId == projectId).length;

  Future<bool> toggleLike(String projectId, String userId) async {
    try {
      final existingLike = _likes.firstWhere(
            (l) => l.projectId == projectId && l.userId == userId,
        orElse: () => Like(id: '', projectId: '', userId: '', createdAt: DateTime.now()),
      );

      if (existingLike.id.isNotEmpty) {
        // Unlike
        _likes.removeWhere((l) => l.projectId == projectId && l.userId == userId);
      } else {
        // Like
        final newLike = Like(
          id: const Uuid().v4(),
          projectId: projectId,
          userId: userId,
          createdAt: DateTime.now(),
        );
        _likes.add(newLike);
      }

      await _saveLikes();
      return existingLike.id.isEmpty; // Return true if liked, false if unliked
    } catch (e) {
      debugPrint('Failed to toggle like: $e');
      return false;
    }
  }
}
