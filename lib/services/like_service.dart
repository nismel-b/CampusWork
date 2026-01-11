import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:campuswork/model/interaction.dart';
import 'package:campuswork/services/interaction_service.dart';

class LikeService {
  static final LikeService _instance = LikeService._internal();
  factory LikeService() => _instance;
  LikeService._internal();

  final InteractionService _interactionService = InteractionService();

  Future<void> init() async {
    await _interactionService.init();
  }

  // Ajouter/retirer un like (toggle)
  Future<bool> toggleLike(String projectId, String userId) async {
    return await _interactionService.toggleLike(projectId, userId);
  }

  // Vérifier si un utilisateur a liké un projet
  bool isLikedByUser(String projectId, String userId) {
    return _interactionService.isLikedByUser(projectId, userId);
  }

  // Obtenir le nombre de likes d'un projet
  int getLikesCount(String projectId) {
    return _interactionService.getLikesCount(projectId);
  }

  // Obtenir les likes d'un projet
  List<Interaction> getLikesByProject(String projectId) {
    return _interactionService.getLikesByProject(projectId);
  }

  // Obtenir les likes d'un utilisateur
  List<Interaction> getLikesByUser(String userId) {
    return _interactionService.getLikesByUser(userId);
  }

  // Obtenir tous les likes
  List<Interaction> getAllLikes() {
    return _interactionService.getAllInteractions()
        .where((i) => i.isLike)
        .toList();
  }

  // Obtenir les projets les plus likés
  List<String> getMostLikedProjects({int limit = 10}) {
    return _interactionService.getMostLikedProjects(limit: limit);
  }

  // Supprimer tous les likes d'un projet (quand le projet est supprimé)
  Future<bool> deleteLikesByProject(String projectId) async {
    return await _interactionService.deleteInteractionsByProject(projectId);
  }

  // Supprimer tous les likes d'un utilisateur (quand l'utilisateur est supprimé)
  Future<bool> deleteLikesByUser(String userId) async {
    return await _interactionService.deleteInteractionsByUser(userId);
  }
}