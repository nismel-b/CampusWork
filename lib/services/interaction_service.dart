import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/model/interaction.dart';

class InteractionService {
  static final InteractionService _instance = InteractionService._internal();
  factory InteractionService() => _instance;
  InteractionService._internal();

  static const _interactionsKey = 'interactions';
  List<Interaction> _interactions = [];

  Future<void> init() async {
    await _loadInteractions();
  }

  Future<void> _loadInteractions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interactionsData = prefs.getString(_interactionsKey);
      if (interactionsData != null) {
        final List<dynamic> interactionsList = jsonDecode(interactionsData);
        _interactions = interactionsList
            .map((json) => Interaction.fromMap(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to load interactions: $e');
      _interactions = [];
    }
  }

  Future<void> _saveInteractions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_interactionsKey, jsonEncode(_interactions.map((i) => i.toMap()).toList()));
    } catch (e) {
      debugPrint('Failed to save interactions: $e');
    }
  }

  // === LIKES METHODS ===

  // Ajouter/retirer un like (toggle)
  Future<bool> toggleLike(String projectId, String userId) async {
    try {
      final existingLike = _interactions.where((i) => 
          i.projectId == projectId && i.userId == userId && i.isLike).firstOrNull;

      if (existingLike != null) {
        // Retirer le like
        _interactions.remove(existingLike);
      } else {
        // Ajouter le like
        final like = Interaction.like(
          userId: userId,
          projectId: projectId,
          interactionId: const Uuid().v4(),
        );
        _interactions.add(like);
      }

      await _saveInteractions();
      return true;
    } catch (e) {
      debugPrint('Failed to toggle like: $e');
      return false;
    }
  }

  // Vérifier si un utilisateur a liké un projet
  bool isLikedByUser(String projectId, String userId) {
    return _interactions.any((i) => i.projectId == projectId && i.userId == userId && i.isLike);
  }

  // Obtenir le nombre de likes d'un projet
  int getLikesCount(String projectId) {
    return _interactions.where((i) => i.projectId == projectId && i.isLike).length;
  }

  // Obtenir les likes d'un projet
  List<Interaction> getLikesByProject(String projectId) {
    return _interactions.where((i) => i.projectId == projectId && i.isLike).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Obtenir les likes d'un utilisateur
  List<Interaction> getLikesByUser(String userId) {
    return _interactions.where((i) => i.userId == userId && i.isLike).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // === REVIEWS METHODS ===

  // Ajouter une review
  Future<bool> addReview({
    required String projectId,
    required String userId,
    required String reviewText,
    required double rating,
  }) async {
    try {
      // Vérifier si l'utilisateur a déjà fait une review pour ce projet
      final existingReview = _interactions.where((i) => 
          i.projectId == projectId && i.userId == userId && i.isReview).firstOrNull;

      if (existingReview != null) {
        // Mettre à jour la review existante
        final updatedReview = existingReview.copyWith(
          reviewText: reviewText,
          rating: rating,
          updatedAt: DateTime.now(),
        );
        final index = _interactions.indexOf(existingReview);
        _interactions[index] = updatedReview;
      } else {
        // Ajouter une nouvelle review
        final review = Interaction.review(
          userId: userId,
          projectId: projectId,
          reviewText: reviewText,
          rating: rating,
          interactionId: const Uuid().v4(),
        );
        _interactions.add(review);
      }

      await _saveInteractions();
      return true;
    } catch (e) {
      debugPrint('Failed to add review: $e');
      return false;
    }
  }

  // Supprimer une review
  Future<bool> deleteReview(String projectId, String userId) async {
    try {
      _interactions.removeWhere((i) => 
          i.projectId == projectId && i.userId == userId && i.isReview);
      await _saveInteractions();
      return true;
    } catch (e) {
      debugPrint('Failed to delete review: $e');
      return false;
    }
  }

  // Obtenir les reviews d'un projet
  List<Interaction> getReviewsByProject(String projectId) {
    return _interactions.where((i) => i.projectId == projectId && i.isReview).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Obtenir les reviews d'un utilisateur
  List<Interaction> getReviewsByUser(String userId) {
    return _interactions.where((i) => i.userId == userId && i.isReview).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Obtenir la note moyenne d'un projet
  double getAverageRating(String projectId) {
    final reviews = getReviewsByProject(projectId);
    if (reviews.isEmpty) return 0.0;
    
    final totalRating = reviews.fold<double>(0.0, (sum, review) => sum + (review.rating ?? 0.0));
    return totalRating / reviews.length;
  }

  // Obtenir le nombre de reviews d'un projet
  int getReviewsCount(String projectId) {
    return _interactions.where((i) => i.projectId == projectId && i.isReview).length;
  }

  // === GENERAL METHODS ===

  // Obtenir toutes les interactions
  List<Interaction> getAllInteractions() => List.unmodifiable(_interactions);

  // Obtenir toutes les interactions d'un projet
  List<Interaction> getInteractionsByProject(String projectId) {
    return _interactions.where((i) => i.projectId == projectId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Obtenir toutes les interactions d'un utilisateur
  List<Interaction> getInteractionsByUser(String userId) {
    return _interactions.where((i) => i.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Obtenir les projets les plus likés
  List<String> getMostLikedProjects({int limit = 10}) {
    final projectLikes = <String, int>{};
    
    for (final interaction in _interactions.where((i) => i.isLike)) {
      projectLikes[interaction.projectId] = (projectLikes[interaction.projectId] ?? 0) + 1;
    }

    final sortedProjects = projectLikes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedProjects.take(limit).map((e) => e.key).toList();
  }

  // Obtenir les projets les mieux notés
  List<String> getTopRatedProjects({int limit = 10}) {
    final projectRatings = <String, List<double>>{};
    
    for (final interaction in _interactions.where((i) => i.isReview && i.rating != null)) {
      projectRatings.putIfAbsent(interaction.projectId, () => []);
      projectRatings[interaction.projectId]!.add(interaction.rating!);
    }

    final averageRatings = projectRatings.entries.map((entry) {
      final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return MapEntry(entry.key, average);
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return averageRatings.take(limit).map((e) => e.key).toList();
  }

  // Supprimer toutes les interactions d'un projet (quand le projet est supprimé)
  Future<bool> deleteInteractionsByProject(String projectId) async {
    try {
      _interactions.removeWhere((i) => i.projectId == projectId);
      await _saveInteractions();
      return true;
    } catch (e) {
      debugPrint('Failed to delete interactions by project: $e');
      return false;
    }
  }

  // Supprimer toutes les interactions d'un utilisateur (quand l'utilisateur est supprimé)
  Future<bool> deleteInteractionsByUser(String userId) async {
    try {
      _interactions.removeWhere((i) => i.userId == userId);
      await _saveInteractions();
      return true;
    } catch (e) {
      debugPrint('Failed to delete interactions by user: $e');
      return false;
    }
  }

  // Obtenir les statistiques d'un projet
  Map<String, dynamic> getProjectStats(String projectId) {
    final likes = getLikesCount(projectId);
    final reviews = getReviewsCount(projectId);
    final averageRating = getAverageRating(projectId);
    
    return {
      'likesCount': likes,
      'reviewsCount': reviews,
      'averageRating': averageRating,
      'totalInteractions': likes + reviews,
    };
  }

  // Obtenir les statistiques d'un utilisateur
  Map<String, dynamic> getUserStats(String userId) {
    final likes = getLikesByUser(userId).length;
    final reviews = getReviewsByUser(userId).length;
    
    return {
      'likesGiven': likes,
      'reviewsGiven': reviews,
      'totalInteractions': likes + reviews,
    };
  }
}