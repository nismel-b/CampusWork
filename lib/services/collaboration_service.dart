import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/model/collaboration_request.dart';

class CollaborationService {
  static final CollaborationService _instance = CollaborationService._internal();
  factory CollaborationService() => _instance;
  CollaborationService._internal();

  static const _requestsKey = 'collaboration_requests';
  List<CollaborationRequest> _requests = [];

  Future<void> init() async {
    await _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsData = prefs.getString(_requestsKey);
      if (requestsData != null) {
        final List<dynamic> requestsList = jsonDecode(requestsData);
        _requests = requestsList.map((json) => CollaborationRequest.fromMap(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load collaboration requests: $e');
      _requests = [];
    }
  }

  Future<void> _saveRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_requestsKey, jsonEncode(_requests.map((r) => r.toMap()).toList()));
    } catch (e) {
      debugPrint('Failed to save collaboration requests: $e');
    }
  }

  // Envoyer une demande de collaboration
  Future<bool> sendCollaborationRequest({
    required String fromUserId,
    required String toUserId,
    required String projectId,
    String? message,
  }) async {
    try {
      // Vérifier si une demande existe déjà
      final existingRequest = _requests.where((r) =>
          r.fromUserId == fromUserId &&
          r.toUserId == toUserId &&
          r.projectId == projectId &&
          r.status == CollaborationStatus.pending).isNotEmpty;

      if (existingRequest) {
        return false; // Demande déjà envoyée
      }

      final request = CollaborationRequest(
        requestId: const Uuid().v4(),
        fromUserId: fromUserId,
        toUserId: toUserId,
        projectId: projectId,
        message: message,
        status: CollaborationStatus.pending,
        createdAt: DateTime.now(),
      );

      _requests.add(request);
      await _saveRequests();
      return true;
    } catch (e) {
      debugPrint('Failed to send collaboration request: $e');
      return false;
    }
  }

  // Obtenir les demandes reçues par un utilisateur
  List<CollaborationRequest> getReceivedRequests(String userId) {
    return _requests
        .where((r) => r.toUserId == userId && r.status == CollaborationStatus.pending)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Obtenir les demandes envoyées par un utilisateur
  List<CollaborationRequest> getSentRequests(String userId) {
    return _requests
        .where((r) => r.fromUserId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Accepter une demande de collaboration
  Future<bool> acceptRequest(String requestId) async {
    try {
      final index = _requests.indexWhere((r) => r.requestId == requestId);
      if (index == -1) return false;

      _requests[index] = _requests[index].copyWith(
        status: CollaborationStatus.accepted,
        respondedAt: DateTime.now(),
      );

      await _saveRequests();
      return true;
    } catch (e) {
      debugPrint('Failed to accept collaboration request: $e');
      return false;
    }
  }

  // Rejeter une demande de collaboration
  Future<bool> rejectRequest(String requestId) async {
    try {
      final index = _requests.indexWhere((r) => r.requestId == requestId);
      if (index == -1) return false;

      _requests[index] = _requests[index].copyWith(
        status: CollaborationStatus.rejected,
        respondedAt: DateTime.now(),
      );

      await _saveRequests();
      return true;
    } catch (e) {
      debugPrint('Failed to reject collaboration request: $e');
      return false;
    }
  }

  // Obtenir une demande par ID
  CollaborationRequest? getRequestById(String requestId) {
    try {
      return _requests.firstWhere((r) => r.requestId == requestId);
    } catch (e) {
      return null;
    }
  }

  // Obtenir toutes les demandes pour un projet
  List<CollaborationRequest> getRequestsForProject(String projectId) {
    return _requests.where((r) => r.projectId == projectId).toList();
  }

  // Supprimer une demande
  Future<bool> deleteRequest(String requestId) async {
    try {
      _requests.removeWhere((r) => r.requestId == requestId);
      await _saveRequests();
      return true;
    } catch (e) {
      debugPrint('Failed to delete collaboration request: $e');
      return false;
    }
  }

  // Obtenir les statistiques des demandes pour un utilisateur
  Map<String, int> getRequestStats(String userId) {
    final received = getReceivedRequests(userId);
    final sent = getSentRequests(userId);
    final accepted = _requests.where((r) =>
        (r.fromUserId == userId || r.toUserId == userId) &&
        r.status == CollaborationStatus.accepted).length;

    return {
      'received': received.length,
      'sent': sent.length,
      'accepted': accepted,
      'pending': received.length + sent.where((r) => r.status == CollaborationStatus.pending).length,
    };
  }
}