import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:campuswork/model/project.dart';
import 'package:campuswork/services/data_sync_service.dart';
import 'package:campuswork/database/database_helper.dart';
import 'package:campuswork/auth/auth_service.dart';
import 'package:campuswork/model/user.dart';

class ProjectService extends ChangeNotifier {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  static const _projectsKey = 'projects';
  List<Project> _projects = [];
  final DataSyncService _syncService = DataSyncService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> init() async {
    await _loadProjects();
    if (_projects.isEmpty) {
      await _createSampleProjects();
    }
  }

  Future<void> _loadProjects() async {
    try {
      // Charger d'abord depuis la base de données
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> projectMaps = await db.query('projects');
      
      if (projectMaps.isNotEmpty) {
        _projects = projectMaps.map((map) => Project.fromDatabase(map)).toList();
        debugPrint('✅ Loaded ${_projects.length} projects from database');
        
        // Synchroniser avec les données globales pour compatibilité
        await _syncService.saveGlobalData('projects', _projects.map((p) => p.toJson()).toList());
        return;
      }

      // Fallback: charger depuis les données globales et migrer vers la DB
      final globalData = await _syncService.getGlobalData('projects');
      if (globalData.isNotEmpty) {
        _projects = globalData.map((json) => Project.fromJson(json)).toList();
        
        // Migrer vers la base de données
        for (final project in _projects) {
          await _saveProjectToDatabase(project);
        }
        
        debugPrint('✅ Migrated ${_projects.length} projects from global data to database');
        return;
      }

      // Fallback final: charger depuis SharedPreferences et migrer
      final prefs = await SharedPreferences.getInstance();
      final projectsData = prefs.getString(_projectsKey);
      if (projectsData != null) {
        final List<dynamic> projectsList = jsonDecode(projectsData);
        _projects = projectsList.map((json) => Project.fromJson(json)).toList();
        
        // Migrer vers la base de données
        for (final project in _projects) {
          await _saveProjectToDatabase(project);
        }
        
        debugPrint('✅ Migrated ${_projects.length} projects from SharedPreferences to database');
      }
    } catch (e) {
      debugPrint('❌ Failed to load projects: $e');
      _projects = [];
    }
  }

  Future<void> _saveProjects() async {
    try {
      // Sauvegarder dans la base de données
      for (final project in _projects) {
        await _saveProjectToDatabase(project);
      }
      
      // Aussi sauvegarder dans les données globales pour la compatibilité
      await _syncService.saveGlobalData('projects', _projects.map((p) => p.toJson()).toList());
      
      // Aussi sauvegarder localement pour la compatibilité
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_projectsKey, jsonEncode(_projects.map((p) => p.toJson()).toList()));
      
      debugPrint('✅ Saved ${_projects.length} projects to database, global and local storage');
    } catch (e) {
      debugPrint('❌ Failed to save projects: $e');
    }
  }

  Future<void> _saveProjectToDatabase(Project project) async {
    try {
      final db = await _dbHelper.database;
      final projectData = project.toDatabase();
      
      // Utiliser INSERT OR REPLACE pour gérer les mises à jour
      await db.insert(
        'projects',
        projectData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('❌ Failed to save project to database: $e');
      rethrow;
    }
  }

  /// Recharger les projets depuis la base de données
  Future<void> refreshProjects() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> projectMaps = await db.query('projects');
      _projects = projectMaps.map((map) => Project.fromDatabase(map)).toList();
      debugPrint('🔄 Refreshed ${_projects.length} projects from database');
    } catch (e) {
      debugPrint('❌ Failed to refresh projects: $e');
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

  /// Obtenir tous les projets avec filtrage basé sur le rôle
  List<Project> getAllProjectsWithRoleFilter() {
    final currentUser = AuthService().currentUser;
    if (currentUser == null) return [];

    switch (currentUser.userRole) {
      case UserRole.admin:
        // Les admins peuvent voir tous les projets
        return List.unmodifiable(_projects);
      
      case UserRole.lecturer:
        // Les professeurs peuvent voir tous les projets publics et privés
        return List.unmodifiable(_projects);
      
      case UserRole.student:
        // Les étudiants ne voient que les projets publics et leurs propres projets
        return _projects.where((project) => 
          project.status == ProjectStatus.public || 
          project.userId == currentUser.userId ||
          project.collaborators.contains(currentUser.userId)
        ).toList();
      
      default:
        return [];
    }
  }

  /// Obtenir les projets publics seulement
  List<Project> getPublicProjects() => 
      _projects.where((p) => p.status == ProjectStatus.public).toList();

  /// Obtenir tous les projets pour les admins et professeurs
  List<Project> getAllProjectsForAdminAndLecturers() {
    final currentUser = AuthService().currentUser;
    if (currentUser == null) return [];

    if (currentUser.userRole == UserRole.admin || currentUser.userRole == UserRole.lecturer) {
      return List.unmodifiable(_projects);
    }
    
    // Pour les autres rôles, retourner seulement les projets publics
    return getPublicProjects();
  }

  List<Project> getProjectsByStudent(String studentId) =>
      _projects.where((p) => p.userId == studentId || p.collaborators.contains(studentId)).toList();

  List<Project> getProjectsByCourse(String courseName) =>
      _projects.where((p) => p.courseName == courseName).toList();

  List<Project> searchProjects(String query, {
    String? courseName,
    String? state,
    ProjectStatus? status,
    String? category, 
  }) {
    var filtered = _projects.where((p) => p.status == ProjectStatus.public).toList();

    if (query.isNotEmpty) {
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
      debugPrint('🔵 Creating project: ${project.projectName}');
      debugPrint('   - Project ID: ${project.projectId}');
      debugPrint('   - User ID: ${project.userId}');
      debugPrint('   - Course: ${project.courseName}');
      
      // Sauvegarder directement dans la base de données
      await _saveProjectToDatabase(project);
      
      // Ajouter à la liste en mémoire
      _projects.add(project);
      
      // Synchroniser avec les autres systèmes
      await _syncService.saveGlobalData('projects', _projects.map((p) => p.toJson()).toList());
      
      // Forcer le rechargement des données pour s'assurer de la cohérence
      await refreshProjects();
      
      debugPrint('✅ Project created successfully in database');
      debugPrint('   - Total projects now: ${_projects.length}');
      
      // Notifier les listeners du changement
      notifyListeners();
      
      return true;
    } catch (e) {
      debugPrint('❌ Failed to create project: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  Future<bool> updateProject(Project project) async {
    try {
      await refreshProjects();
      
      final index = _projects.indexWhere((p) => p.projectId == project.projectId);
      if (index == -1) return false;

      // Mettre à jour dans la base de données
      await _saveProjectToDatabase(project);
      
      // Mettre à jour en mémoire
      _projects[index] = project;
      
      // Synchroniser avec les autres systèmes
      await _syncService.saveGlobalData('projects', _projects.map((p) => p.toJson()).toList());
      
      debugPrint('✅ Updated project in database: ${project.projectName}');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to update project: $e');
      return false;
    }
  }

  Future<bool> deleteProject(String projectId) async {
    try {
      await refreshProjects();
      
      final project = _projects.firstWhere((p) => p.projectId == projectId, orElse: () => Project(
        projectName: 'Unknown',
        courseName: '',
        description: '',
        userId: '',
      ));
      
      // Supprimer de la base de données
      final db = await _dbHelper.database;
      await db.delete('projects', where: 'projectId = ?', whereArgs: [projectId]);
      
      // Supprimer de la mémoire
      _projects.removeWhere((p) => p.projectId == projectId);
      
      // Synchroniser avec les autres systèmes
      await _syncService.saveGlobalData('projects', _projects.map((p) => p.toJson()).toList());
      
      debugPrint('✅ Deleted project from database: ${project.projectName}');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete project: $e');
      return false;
    }
  }

  // Méthodes asynchrones avec synchronisation
  Future<List<Project>> getAllProjectsAsync() async {
    await refreshProjects();
    return List.unmodifiable(_projects);
  }

  Future<List<Project>> getProjectsByUserAsync(String userId) async {
    await refreshProjects();
    return _projects.where((p) => p.userId == userId).toList();
  }

  Future<List<Project>> getProjectsByCourseAsync(String courseName) async {
    await refreshProjects();
    return _projects.where((p) => p.courseName.toLowerCase().contains(courseName.toLowerCase())).toList();
  }

  Future<Project?> getProjectByIdAsync(String projectId) async {
    await refreshProjects();
    try {
      return _projects.firstWhere((p) => p.projectId == projectId);
    } catch (e) {
      return null;
    }
  }

  // Méthodes synchrones (pour compatibilité)
  Project? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((p) => p.projectId == projectId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> evaluateProject(String projectId, String grade, String? comment) async {
    try {
      final index = _projects.indexWhere((p) => p.projectId == projectId);
      if (index == -1) return false;

      final project = _projects[index];
      _projects[index] = project.copyWith(
        grade: grade,
        lecturerComment: comment,
        state: 'note',
        updatedAt: DateTime.now().toIso8601String(),
      );

      await _saveProjects();
      return true;
    } catch (e) {
      debugPrint('Failed to evaluate project: $e');
      return false;
    }
  }

  Future<void> incrementLikes(String projectId) async {
    final index = _projects.indexWhere((p) => p.projectId == projectId);
    if (index != -1) {
      _projects[index] = _projects[index].copyWith(
        likesCount: _projects[index].likesCount + 1,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _saveProjects();
    }
  }

  Future<void> decrementLikes(String projectId) async {
    final index = _projects.indexWhere((p) => p.projectId == projectId);
    if (index != -1) {
      _projects[index] = _projects[index].copyWith(
        likesCount: (_projects[index].likesCount - 1).clamp(0, double.infinity).toInt(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _saveProjects();
    }
  }

  Future<void> incrementComments(String projectId) async {
    final index = _projects.indexWhere((p) => p.projectId == projectId);
    if (index != -1) {
      _projects[index] = _projects[index].copyWith(
        commentsCount: _projects[index].commentsCount + 1,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _saveProjects();
    }
  }

  Future<void> decrementComments(String projectId) async {
    final index = _projects.indexWhere((p) => p.projectId == projectId);
    if (index != -1) {
      _projects[index] = _projects[index].copyWith(
        commentsCount: (_projects[index].commentsCount - 1).clamp(0, double.infinity).toInt(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _saveProjects();
    }
  }

  List<String> getAllCourses() {
    final courses = _projects.map((p) => p.courseName).toSet().toList();
    courses.sort();
    return courses;
  }

  // Add missing methods needed by various screens
  List<Project> getProjectsByUserId(String userId) {
    return getProjectsByStudent(userId);
  }

  Future<List<Project>> getProjectByUserId(String userId) async {
    return getProjectsByStudent(userId);
  }

  Future<List<Project>> getHistoryByProject(String projectId) async {
    // Return project history - for now just return the project itself
    final project = getProjectById(projectId);
    return project != null ? [project] : [];
  }
}
