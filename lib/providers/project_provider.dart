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
      final data = await _projectService.getAllProjects();
      // on va prendre tous les projects dans la base de données
      _projects = data.map((item) => Project.fromMap(item)).toList();
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
      final data = await _projectService.getProjectsByStudent(userId);
      _projects = data.map((item) => Project.fromMap(item)).toList();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading projects by store: $e');
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
        final data = await _projectService.searchProjects(query);
        _filteredProjects = data.map((item) => Project.fromMap(item)).toList();
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
  void filterByArchitecturePatterns (String? architecturePatterns) {
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
    if (_searchQuery == null && _selectedCategory == null ) {
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
        matches = matches && project.category == _selectedCategory;
      }
      if (_selectedCourseName != null && _selectedCourseName!.isNotEmpty) {
        matches = matches && project.courseName == _selectedCourseName;
      }
      if (_selectedArchitecturePatterns != null && _selectedArchitecturePatterns!.isNotEmpty) {
        matches = matches && project.architecturePatterns == _selectedArchitecturePatterns;
      }
      if (_selectedState != null && _selectedState!.isNotEmpty) {
        matches = matches && project.state == _selectedState;
      }
      if (_selectedGrade != null && _selectedGrade!.isNotEmpty) {
        matches = matches && project.grade == _selectedGrade;
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
}


