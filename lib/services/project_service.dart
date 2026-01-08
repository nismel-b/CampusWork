import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/model/project.dart';

class ProjectService {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  static const _projectsKey = 'projects';
  List<Project> _projects = [];

  Future<void> init() async {
    await _loadProjects();
    if (_projects.isEmpty) {
      await _createSampleProjects();
    }
  }

  Future<void> _loadProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsData = prefs.getString(_projectsKey);
      if (projectsData != null) {
        final List<dynamic> projectsList = jsonDecode(projectsData);
        _projects = projectsList.map((json) => Project.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load projects: $e');
      _projects = [];
    }
  }

  Future<void> _saveProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_projectsKey, jsonEncode(_projects.map((p) => p.toJson()).toList()));
    } catch (e) {
      debugPrint('Failed to save projects: $e');
    }
  }

  Future<void> _createSampleProjects() async {
    final now = DateTime.now();
/*
    _projects = [
      Project(
        id: const Uuid().v4(),
        projectName: 'E-Commerce Mobile App',
        courseName: 'Développement Mobile',
        description: 'Application mobile complète de commerce électronique avec panier, paiement et gestion des commandes.',
        studentId: 'sample-student-1',
        architecturePatterns: 'MVVM, Repository Pattern',
        status: ProjectStatus.public,
        state: ProjectState.termine,
        grade: 18.5,
        likesCount: 24,
        commentsCount: 8,
        resources: ['Flutter', 'Firebase', 'Stripe'],
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Project(
        id: const Uuid().v4(),
        projectName: 'Gestion de Bibliothèque',
        courseName: 'Base de Données',
        description: 'Système de gestion de bibliothèque universitaire avec catalogue, emprunts et réservations.',
        studentId: 'sample-student-2',
        architecturePatterns: 'MVC',
        status: ProjectStatus.public,
        state: ProjectState.note,
        grade: 16.0,
        likesCount: 15,
        commentsCount: 5,
        resources: ['MySQL', 'PHP', 'Bootstrap'],
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      Project(
        id: const Uuid().v4(),
        projectName: 'Chatbot IA',
        courseName: 'Intelligence Artificielle',
        description: 'Chatbot intelligent utilisant le traitement du langage naturel pour répondre aux questions des étudiants.',
        studentId: 'sample-student-3',
        status: ProjectStatus.public,
        state: ProjectState.enCours,
        likesCount: 32,
        commentsCount: 12,
        resources: ['Python', 'TensorFlow', 'NLTK'],
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Project(
        id: const Uuid().v4(),
        projectName: 'Plateforme de Streaming',
        courseName: 'Réseaux et Multimédia',
        description: 'Plateforme de streaming vidéo avec système de recommandation basé sur les préférences utilisateur.',
        studentId: 'sample-student-1',
        status: ProjectStatus.public,
        state: ProjectState.termine,
        grade: 17.5,
        likesCount: 28,
        commentsCount: 9,
        resources: ['Node.js', 'WebRTC', 'MongoDB'],
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 20)),
      ),
    ];
*/
    await _saveProjects();
  }

  List<Project> getAllProjects() => List.unmodifiable(_projects);

  List<Project> getProjectsByStudent(String studentId) =>
      _projects.where((p) => p.studentId == studentId || p.collaborators.contains(studentId)).toList();

  List<Project> getProjectsByCourse(String courseName) =>
      _projects.where((p) => p.courseName == courseName).toList();

  List<Project> searchProjects(String query, {
    String? courseName,
    ProjectState? state,
    ProjectStatus? status,
    String? category, 
  }) {
    var filtered = _projects.where((p) => p.status == ProjectStatus.public).toList();

    if (query != null && query.isNotEmpty) {
      filtered = filtered.where((p) =>
      p.projectName.toLowerCase().contains(query.toLowerCase()) ||
          p.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }

    if (courseName != null && courseName.isNotEmpty) {
      filtered = filtered.where((p) => p.courseName == courseName).toList();
    }

    if (state != null) {
      filtered = filtered.where((p) => p.state == state).toList();
    }

    if (status != null) {
      filtered = filtered.where((p) => p.status == status).toList();
    }

    return filtered;
  }

  Future<bool> createProject(Project project) async {
    try {
      _projects.add(project);
      await _saveProjects();
      return true;
    } catch (e) {
      debugPrint('Failed to create project: $e');
      return false;
    }
  }

  Future<bool> updateProject(Project project) async {
    try {
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index == -1) return false;

      _projects[index] = project;
      await _saveProjects();
      return true;
    } catch (e) {
      debugPrint('Failed to update project: $e');
      return false;
    }
  }

  Future<bool> deleteProject(String projectId) async {
    try {
      _projects.removeWhere((p) => p.id == projectId);
      await _saveProjects();
      return true;
    } catch (e) {
      debugPrint('Failed to delete project: $e');
      return false;
    }
  }

  Project? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((p) => p.id == projectId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> evaluateProject(String projectId, double grade, String? comment) async {
    try {
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index == -1) return false;

      final project = _projects[index];
      _projects[index] = project.copyWith(
        grade: grade,
        lecturerComment: comment,
        state: ProjectState.note,
        updatedAt: DateTime.now(),
      );

      await _saveProjects();
      return true;
    } catch (e) {
      debugPrint('Failed to evaluate project: $e');
      return false;
    }
  }

  Future<void> incrementLikes(String projectId) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      _projects[index] = _projects[index].copyWith(
        likesCount: _projects[index].likesCount + 1,
        updatedAt: DateTime.now(),
      );
      await _saveProjects();
    }
  }

  Future<void> decrementLikes(String projectId) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      _projects[index] = _projects[index].copyWith(
        likesCount: (_projects[index].likesCount - 1).clamp(0, double.infinity).toInt(),
        updatedAt: DateTime.now(),
      );
      await _saveProjects();
    }
  }

  Future<void> incrementComments(String projectId) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      _projects[index] = _projects[index].copyWith(
        commentsCount: _projects[index].commentsCount + 1,
        updatedAt: DateTime.now(),
      );
      await _saveProjects();
    }
  }

  Future<void> decrementComments(String projectId) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      _projects[index] = _projects[index].copyWith(
        commentsCount: (_projects[index].commentsCount - 1).clamp(0, double.infinity).toInt(),
        updatedAt: DateTime.now(),
      );
      await _saveProjects();
    }
  }

  List<String> getAllCourses() {
    final courses = _projects.map((p) => p.courseName).toSet().toList();
    courses.sort();
    return courses;
  }
}
