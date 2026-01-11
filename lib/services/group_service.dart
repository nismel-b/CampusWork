import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/model/group.dart';

class GroupService {
  static final GroupService _instance = GroupService._internal();
  factory GroupService() => _instance;
  GroupService._internal();

  static const _groupsKey = 'groups';
  List<Group> _groups = [];

  Future<void> init() async {
    await _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupsData = prefs.getString(_groupsKey);
      if (groupsData != null) {
        final List<dynamic> groupsList = jsonDecode(groupsData);
        _groups = groupsList.map((json) => Group.fromMap(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load groups: $e');
      _groups = [];
    }
  }

  Future<void> _saveGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_groupsKey, jsonEncode(_groups.map((g) => g.toMap()).toList()));
    } catch (e) {
      debugPrint('Failed to save groups: $e');
    }
  }

  // Créer un groupe
  Future<bool> createGroup(Group group) async {
    try {
      final newGroup = group.copyWith(
        groupId: const Uuid().v4(),
        createdAt: DateTime.now(),
      );
      _groups.add(newGroup);
      await _saveGroups();
      return true;
    } catch (e) {
      debugPrint('Failed to create group: $e');
      return false;
    }
  }

  // Obtenir tous les groupes
  List<Group> getAllGroups() => List.unmodifiable(_groups);

  // Obtenir les groupes créés par un utilisateur
  List<Group> getGroupsByCreator(String userId) =>
      _groups.where((g) => g.createdBy == userId).toList();

  // Obtenir les groupes dont un utilisateur est membre
  List<Group> getGroupsByMember(String userId) =>
      _groups.where((g) => g.isMember(userId)).toList();

  // Obtenir les groupes par cours
  List<Group> getGroupsByCourse(String courseName) =>
      _groups.where((g) => g.courseName == courseName).toList();

  // Obtenir un groupe par ID
  Group? getGroupById(String groupId) {
    try {
      return _groups.firstWhere((g) => g.groupId == groupId);
    } catch (e) {
      return null;
    }
  }

  // Ajouter un membre à un groupe
  Future<bool> addMemberToGroup(String groupId, String userId) async {
    try {
      final index = _groups.indexWhere((g) => g.groupId == groupId);
      if (index == -1) return false;

      final group = _groups[index];
      if (group.isFull || group.isMember(userId)) return false;

      final updatedMembers = List<String>.from(group.members)..add(userId);
      _groups[index] = group.copyWith(
        members: updatedMembers,
        updatedAt: DateTime.now(),
      );

      await _saveGroups();
      return true;
    } catch (e) {
      debugPrint('Failed to add member to group: $e');
      return false;
    }
  }

  // Retirer un membre d'un groupe
  Future<bool> removeMemberFromGroup(String groupId, String userId) async {
    try {
      final index = _groups.indexWhere((g) => g.groupId == groupId);
      if (index == -1) return false;

      final group = _groups[index];
      if (!group.isMember(userId)) return false;

      final updatedMembers = List<String>.from(group.members)..remove(userId);
      _groups[index] = group.copyWith(
        members: updatedMembers,
        updatedAt: DateTime.now(),
      );

      await _saveGroups();
      return true;
    } catch (e) {
      debugPrint('Failed to remove member from group: $e');
      return false;
    }
  }

  // Ajouter un projet à un groupe
  Future<bool> addProjectToGroup(String groupId, String projectId) async {
    try {
      final index = _groups.indexWhere((g) => g.groupId == groupId);
      if (index == -1) return false;

      final group = _groups[index];
      if (group.projects.contains(projectId)) return false;

      final updatedProjects = List<String>.from(group.projects)..add(projectId);
      _groups[index] = group.copyWith(
        projects: updatedProjects,
        updatedAt: DateTime.now(),
      );

      await _saveGroups();
      return true;
    } catch (e) {
      debugPrint('Failed to add project to group: $e');
      return false;
    }
  }

  // Retirer un projet d'un groupe
  Future<bool> removeProjectFromGroup(String groupId, String projectId) async {
    try {
      final index = _groups.indexWhere((g) => g.groupId == groupId);
      if (index == -1) return false;

      final group = _groups[index];
      if (!group.projects.contains(projectId)) return false;

      final updatedProjects = List<String>.from(group.projects)..remove(projectId);
      _groups[index] = group.copyWith(
        projects: updatedProjects,
        updatedAt: DateTime.now(),
      );

      await _saveGroups();
      return true;
    } catch (e) {
      debugPrint('Failed to remove project from group: $e');
      return false;
    }
  }

  // Mettre à jour un groupe
  Future<bool> updateGroup(Group group) async {
    try {
      final index = _groups.indexWhere((g) => g.groupId == group.groupId);
      if (index == -1) return false;

      _groups[index] = group.copyWith(updatedAt: DateTime.now());
      await _saveGroups();
      return true;
    } catch (e) {
      debugPrint('Failed to update group: $e');
      return false;
    }
  }

  // Supprimer un groupe
  Future<bool> deleteGroup(String groupId) async {
    try {
      _groups.removeWhere((g) => g.groupId == groupId);
      await _saveGroups();
      return true;
    } catch (e) {
      debugPrint('Failed to delete group: $e');
      return false;
    }
  }

  // Rechercher des groupes
  List<Group> searchGroups(String query) {
    if (query.isEmpty) return getAllGroups();
    
    return _groups.where((group) =>
      group.name.toLowerCase().contains(query.toLowerCase()) ||
      group.description.toLowerCase().contains(query.toLowerCase()) ||
      (group.courseName?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  // Obtenir les groupes ouverts (que les étudiants peuvent rejoindre)
  List<Group> getOpenGroups() =>
      _groups.where((g) => g.isOpen && !g.isFull).toList();

  // Obtenir les statistiques des groupes
  Map<String, int> getGroupStats() {
    return {
      'total': _groups.length,
      'project': _groups.where((g) => g.type == GroupType.project).length,
      'study': _groups.where((g) => g.type == GroupType.study).length,
      'collaboration': _groups.where((g) => g.type == GroupType.collaboration).length,
      'open': _groups.where((g) => g.isOpen).length,
      'full': _groups.where((g) => g.isFull).length,
    };
  }
}