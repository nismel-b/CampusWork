import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/model/post.dart';

class PostService {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  static const _postsKey = 'posts';
  List<Post> _posts = [];

  Future<void> init() async {
    await _loadPosts();
    if (_posts.isEmpty) {
      await _createSamplePosts();
    }
  }

  Future<void> _loadPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final postsData = prefs.getString(_postsKey);
      if (postsData != null) {
        final List<dynamic> postsList = jsonDecode(postsData);
        _posts = postsList.map((json) => Post.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load posts: $e');
      _posts = [];
    }
  }

  Future<void> _savePosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_postsKey, jsonEncode(_posts.map((p) => p.toJson()).toList()));
    } catch (e) {
      debugPrint('Failed to save posts: $e');
    }
  }

  Future<void> _createSamplePosts() async {
    final now = DateTime.now();
    
    _posts = [
      Post(
        id: const Uuid().v4(),
        userId: 'sample-student-1',
        userFullName: 'Marie Dupont',
        title: 'Besoin d\'aide pour l\'architecture de mon app mobile',
        content: 'Salut ! Je développe une app de gestion de tâches et je me demande quelle architecture utiliser. MVVM ou Clean Architecture ? Vos avis ?',
        type: PostType.help,
        courseName: 'Développement Mobile',
        tags: ['flutter', 'architecture', 'mvvm'],
        likesCount: 12,
        commentsCount: 8,
        viewsCount: 45,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      Post(
        id: const Uuid().v4(),
        userId: 'sample-student-2',
        userFullName: 'Jean Martin',
        title: 'Idée : Plateforme de covoiturage étudiant',
        content: 'J\'ai une idée pour un projet : une app de covoiturage spécialement pour les étudiants de notre université. Qu\'en pensez-vous ? Quelqu\'un veut collaborer ?',
        type: PostType.idea,
        courseName: 'Projet Innovant',
        tags: ['covoiturage', 'mobile', 'collaboration'],
        likesCount: 18,
        commentsCount: 15,
        viewsCount: 67,
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      Post(
        id: const Uuid().v4(),
        userId: 'sample-lecturer-1',
        userFullName: 'Prof. Dubois',
        title: 'Rappel : Date limite des projets de fin de semestre',
        content: 'N\'oubliez pas que la date limite pour soumettre vos projets de fin de semestre est le 15 décembre. Assurez-vous d\'avoir tous les livrables requis.',
        type: PostType.announcement,
        courseName: 'Développement Web',
        tags: ['deadline', 'projet', 'important'],
        likesCount: 5,
        commentsCount: 3,
        viewsCount: 89,
        createdAt: now.subtract(const Duration(hours: 8)),
        updatedAt: now.subtract(const Duration(hours: 8)),
      ),
      Post(
        id: const Uuid().v4(),
        userId: 'sample-student-3',
        userFullName: 'Sophie Leroy',
        title: 'Question sur l\'intégration d\'API REST',
        content: 'Comment gérer l\'authentification JWT dans une app Flutter ? J\'ai des problèmes avec le refresh token.',
        type: PostType.question,
        courseName: 'Développement Mobile',
        tags: ['flutter', 'api', 'jwt', 'authentification'],
        likesCount: 8,
        commentsCount: 12,
        viewsCount: 34,
        createdAt: now.subtract(const Duration(hours: 12)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
    ];

    await _savePosts();
  }

  List<Post> getAllPosts() => List.unmodifiable(_posts)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Post> getPostsByUser(String userId) =>
      _posts.where((p) => p.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Post> getPostsByType(PostType type) =>
      _posts.where((p) => p.type == type).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Post> getPostsByCourse(String courseName) =>
      _posts.where((p) => p.courseName == courseName).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Post> searchPosts(String query, {
    PostType? type,
    String? courseName,
    PostStatus? status,
    List<String>? tags,
  }) {
    var filtered = _posts.where((p) => p.status == PostStatus.active).toList();

    if (query.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.title.toLowerCase().contains(query.toLowerCase()) ||
        p.content.toLowerCase().contains(query.toLowerCase()) ||
        p.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    }

    if (type != null) {
      filtered = filtered.where((p) => p.type == type).toList();
    }

    if (courseName != null && courseName.isNotEmpty) {
      filtered = filtered.where((p) => p.courseName == courseName).toList();
    }

    if (status != null) {
      filtered = filtered.where((p) => p.status == status).toList();
    }

    if (tags != null && tags.isNotEmpty) {
      filtered = filtered.where((p) => 
        tags.any((tag) => p.tags.contains(tag))
      ).toList();
    }

    return filtered..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<bool> createPost(Post post) async {
    try {
      _posts.add(post);
      await _savePosts();
      return true;
    } catch (e) {
      debugPrint('Failed to create post: $e');
      return false;
    }
  }

  Future<bool> updatePost(Post post) async {
    try {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index == -1) return false;

      _posts[index] = post.copyWith(updatedAt: DateTime.now());
      await _savePosts();
      return true;
    } catch (e) {
      debugPrint('Failed to update post: $e');
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      _posts.removeWhere((p) => p.id == postId);
      await _savePosts();
      return true;
    } catch (e) {
      debugPrint('Failed to delete post: $e');
      return false;
    }
  }

  Post? getPostById(String postId) {
    try {
      return _posts.firstWhere((p) => p.id == postId);
    } catch (e) {
      return null;
    }
  }

  Future<void> incrementViews(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        viewsCount: _posts[index].viewsCount + 1,
        updatedAt: DateTime.now(),
      );
      await _savePosts();
    }
  }

  Future<void> incrementLikes(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        likesCount: _posts[index].likesCount + 1,
        updatedAt: DateTime.now(),
      );
      await _savePosts();
    }
  }

  Future<void> decrementLikes(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        likesCount: (_posts[index].likesCount - 1).clamp(0, double.infinity).toInt(),
        updatedAt: DateTime.now(),
      );
      await _savePosts();
    }
  }

  Future<void> incrementComments(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        commentsCount: _posts[index].commentsCount + 1,
        updatedAt: DateTime.now(),
      );
      await _savePosts();
    }
  }

  Future<void> decrementComments(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        commentsCount: (_posts[index].commentsCount - 1).clamp(0, double.infinity).toInt(),
        updatedAt: DateTime.now(),
      );
      await _savePosts();
    }
  }

  List<String> getAllTags() {
    final tags = <String>{};
    for (final post in _posts) {
      tags.addAll(post.tags);
    }
    return tags.toList()..sort();
  }

  List<String> getAllCourses() {
    final courses = _posts
        .where((p) => p.courseName != null)
        .map((p) => p.courseName!)
        .toSet()
        .toList();
    courses.sort();
    return courses;
  }

  Future<bool> markAsResolved(String postId) async {
    try {
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index == -1) return false;

      _posts[index] = _posts[index].copyWith(
        status: PostStatus.resolved,
        updatedAt: DateTime.now(),
      );
      await _savePosts();
      return true;
    } catch (e) {
      debugPrint('Failed to mark post as resolved: $e');
      return false;
    }
  }

  Future<bool> archivePost(String postId) async {
    try {
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index == -1) return false;

      _posts[index] = _posts[index].copyWith(
        status: PostStatus.archived,
        updatedAt: DateTime.now(),
      );
      await _savePosts();
      return true;
    } catch (e) {
      debugPrint('Failed to archive post: $e');
      return false;
    }
  }
}