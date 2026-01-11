import 'package:flutter/foundation.dart';
import 'package:campuswork/model/project.dart';
import 'package:campuswork/services/project_service.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  List<Project> _projects = [];
  List<Project> _filteredProjects = [];
  bool _isLoading = false;
  String? _searchQuery;
  String? _selectedCategory;
  String? _selectedArchitecturePatterns;
  String? _selectedGrade;
  String? _selectedState;
  String? _selectedCourseName;

  List<Project> get projects => _filteredProjects.isEmpty && _searchQuery == null && _selectedCategory == null
      ? _projects
      : _filteredProjects;
  bool get isLoading => _isLoading;

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Les méthodes du service sont synchrones et retournent directement List<Project>
      _projects = _projectService.getAllProjects();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading projects: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProjectsByUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Les méthodes du service sont synchrones et retournent directement List<Project>
      _projects = _projectService.getProjectsByStudent(userId);
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading projects by user: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchProjects(String query) async {
    _searchQuery = query.isEmpty ? null : query;
    _isLoading = true;
    notifyListeners();

    try {
      if (query.isEmpty) {
        _filteredProjects = _projects;
      } else {
        // Les méthodes du service sont synchrones et retournent directement List<Project>
        _filteredProjects = _projectService.searchProjects(query);
      }
    } catch (e) {
      debugPrint('Error searching projects: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void filterByCourseName(String? courseName) {
    _selectedCourseName = courseName;
    _applyFilters();
  }

  void filterByArchitecturePatterns(String? architecturePatterns) {
    _selectedArchitecturePatterns = architecturePatterns;
    _applyFilters();
  }

  void filterByState(String? state) {
    _selectedState = state;
    _applyFilters();
  }

  void filterByGrade(String? grade) {
    _selectedGrade = grade;
    _applyFilters();
  }

  void _applyFilters() {
    if (_searchQuery == null && 
        _selectedCategory == null && 
        _selectedCourseName == null &&
        _selectedArchitecturePatterns == null &&
        _selectedState == null &&
        _selectedGrade == null) {
      _filteredProjects = _projects;
      return;
    }

    _filteredProjects = _projects.where((project) {
      bool matches = true;

      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        matches = matches &&
            (project.projectName.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
                project.description.toLowerCase().contains(_searchQuery!.toLowerCase()));
      }

      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        matches = matches && (project.category != null && project.category == _selectedCategory);
      }

      if (_selectedCourseName != null && _selectedCourseName!.isNotEmpty) {
        matches = matches && project.courseName == _selectedCourseName;
      }

      if (_selectedArchitecturePatterns != null && _selectedArchitecturePatterns!.isNotEmpty) {
        matches = matches && (project.architecturePatterns != null && project.architecturePatterns == _selectedArchitecturePatterns);
      }

      if (_selectedState != null && _selectedState!.isNotEmpty) {
        matches = matches && project.state == _selectedState;
      }

      if (_selectedGrade != null && _selectedGrade!.isNotEmpty) {
        matches = matches && (project.grade != null && project.grade == _selectedGrade);
      }

      return matches;
    }).toList();

    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = null;
    _selectedCategory = null;
    _selectedArchitecturePatterns = null;
    _selectedCourseName = null;
    _selectedGrade = null;
    _selectedState = null;
    _filteredProjects = [];
    notifyListeners();
  }

  // Méthodes utilitaires
  Project? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((project) => project.projectId == projectId);
    } catch (e) {
      return null;
    }
  }

  List<Project> getProjectsByCategory(String category) {
    return _projects.where((project) => project.category != null && project.category == category).toList();
  }

  List<Project> getProjectsByState(String state) {
    return _projects.where((project) => project.state == state).toList();
  }

  int get totalProjects => _projects.length;
  int get filteredProjectsCount => _filteredProjects.length;
}


