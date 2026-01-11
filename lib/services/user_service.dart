import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/model/student.dart';
import 'package:campuswork/model/lecturer.dart';
import 'package:campuswork/model/admin.dart';
import 'package:campuswork/auth/auth_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  static const _usersKey = 'users_cache';
  List<User> _users = [];

  Future<void> init() async {
    await _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersData = prefs.getString(_usersKey);
      if (usersData != null) {
        final List<dynamic> usersList = jsonDecode(usersData);
        _users = usersList.map((json) => _userFromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load users: $e');
      _users = [];
    }
  }

  Future<void> _saveUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usersKey, jsonEncode(_users.map((u) => _userToJson(u)).toList()));
    } catch (e) {
      debugPrint('Failed to save users: $e');
    }
  }

  User _userFromJson(Map<String, dynamic> json) {
    final role = json['userRole'] as String;
    switch (role) {
      case 'student':
        return Student(
          userId: json['userId'] as String,
          username: json['username'] as String,
          firstName: json['firstName'] as String,
          lastName: json['lastName'] as String,
          email: json['email'] as String,
          phonenumber: json['phonenumber'] as String,
          password: json['password'] as String,
          isApproved: json['isApproved'] as bool? ?? false,
          createdAt: DateTime.parse(json['createdAt'] as String),
          updatedAt: DateTime.parse(json['updatedAt'] as String),
          matricule: json['matricule'] as String,
          birthday: DateTime.parse(json['birthday'] as String),
          level: json['level'] as String,
          semester: json['semester'] as String,
          section: json['section'] as String,
          filiere: json['filiere'] as String,
          academicYear: json['academicYear'] as String,
          githubLink: json['githubLink'] as String?,
          linkedinLink: json['linkedinLink'] as String?,
          otherLinks: List<String>.from(json['otherLinks'] ?? []),
        );
      case 'lecturer':
        return Lecturer(
          userId: json['userId'] as String,
          username: json['username'] as String,
          firstName: json['firstName'] as String,
          lastName: json['lastName'] as String,
          email: json['email'] as String,
          phonenumber: json['phonenumber'] as String,
          password: json['password'] as String,
          isApproved: json['isApproved'] as bool? ?? false,
          createdAt: DateTime.parse(json['createdAt'] as String),
          updatedAt: DateTime.parse(json['updatedAt'] as String),
          uniteDenseignement: json['uniteDenseignement'] as String,
          section: json['section'] as String,
          evaluationGrid: json['evaluationGrid'] as String?,
          validationRequirements: json['validationRequirements'] as String?,
          finalSubmissionRequirements: json['finalSubmissionRequirements'] as String?,
        );
      case 'admin':
        return Admin(
          userId: json['userId'] as String,
          username: json['username'] as String,
          firstName: json['firstName'] as String,
          lastName: json['lastName'] as String,
          email: json['email'] as String,
          phonenumber: json['phonenumber'] as String,
          password: json['password'] as String,
          isApproved: json['isApproved'] as bool? ?? true,
          createdAt: DateTime.parse(json['createdAt'] as String),
          updatedAt: DateTime.parse(json['updatedAt'] as String),
          department: json['department'] as String?,
          permissions: List<String>.from(json['permissions'] ?? []),
        );
      default:
        return User(
          userId: json['userId'] as String,
          username: json['username'] as String,
          firstName: json['firstName'] as String,
          lastName: json['lastName'] as String,
          email: json['email'] as String,
          phonenumber: json['phonenumber'] as String,
          password: json['password'] as String,
          userRole: UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == role,
            orElse: () => UserRole.student,
          ),
          isApproved: json['isApproved'] as bool? ?? false,
          createdAt: DateTime.parse(json['createdAt'] as String),
          updatedAt: DateTime.parse(json['updatedAt'] as String),
        );
    }
  }

  Map<String, dynamic> _userToJson(User user) {
    final baseJson = <String, dynamic>{
      'userId': user.userId,
      'username': user.username,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'phonenumber': user.phonenumber,
      'password': user.password,
      'userRole': user.userRole.toString().split('.').last,
      'isApproved': user.isApproved,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt.toIso8601String(),
    };

    if (user is Student) {
      baseJson.addAll({
        'matricule': user.matricule,
        'birthday': user.birthday.toIso8601String(),
        'level': user.level,
        'semester': user.semester,
        'section': user.section,
        'filiere': user.filiere,
        'academicYear': user.academicYear,
        'githubLink': user.githubLink ?? '',
        'linkedinLink': user.linkedinLink ?? '',
        'otherLinks': user.otherLinks,
      });
    } else if (user is Lecturer) {
      baseJson.addAll({
        'uniteDenseignement': user.uniteDenseignement,
        'section': user.section,
        'evaluationGrid': user.evaluationGrid ?? '',
        'validationRequirements': user.validationRequirements ?? '',
        'finalSubmissionRequirements': user.finalSubmissionRequirements ?? '',
      });
    } else if (user is Admin) {
      baseJson.addAll({
        'department': user.department ?? '',
        'permissions': user.permissions,
      });
    }

    return baseJson;
  }

  List<User> getAllUsers() => List.unmodifiable(_users);

  List<Student> getAllStudents() =>
      _users.whereType<Student>().toList();

  List<Lecturer> getAllLecturers() =>
      _users.whereType<Lecturer>().toList();

  List<Admin> getAllAdmins() =>
      _users.whereType<Admin>().toList();

  User? getUserById(String userId) {
    try {
      return _users.firstWhere((u) => u.userId == userId);
    } catch (e) {
      return null;
    }
  }

  User? getUserByEmail(String email) {
    try {
      return _users.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  User? getUserByUsername(String username) {
    try {
      return _users.firstWhere((u) => u.username == username);
    } catch (e) {
      return null;
    }
  }

  List<User> searchUsers(String query) {
    if (query.isEmpty) return getAllUsers();
    
    final lowerQuery = query.toLowerCase();
    return _users.where((user) =>
      user.firstName.toLowerCase().contains(lowerQuery) ||
      user.lastName.toLowerCase().contains(lowerQuery) ||
      user.username.toLowerCase().contains(lowerQuery) ||
      user.email.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  List<User> getUsersByRole(UserRole role) =>
      _users.where((u) => u.userRole == role).toList();

  List<User> getPendingUsers() =>
      _users.where((u) => !u.isApproved).toList();

  Future<bool> addUser(User user) async {
    try {
      _users.add(user);
      await _saveUsers();
      return true;
    } catch (e) {
      debugPrint('Failed to add user: $e');
      return false;
    }
  }

  Future<bool> updateUser(User updatedUser) async {
    try {
      final index = _users.indexWhere((u) => u.userId == updatedUser.userId);
      if (index == -1) return false;

      _users[index] = updatedUser;
      await _saveUsers();
      return true;
    } catch (e) {
      debugPrint('Failed to update user: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      _users.removeWhere((u) => u.userId == userId);
      await _saveUsers();
      return true;
    } catch (e) {
      debugPrint('Failed to delete user: $e');
      return false;
    }
  }

  Future<bool> approveUser(String userId) async {
    try {
      final index = _users.indexWhere((u) => u.userId == userId);
      if (index == -1) return false;

      final user = _users[index];
      User updatedUser;

      if (user is Student) {
        updatedUser = Student(
          userId: user.userId,
          username: user.username,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          phonenumber: user.phonenumber,
          password: user.password,
          isApproved: true,
          createdAt: user.createdAt,
          updatedAt: DateTime.now(),
          matricule: user.matricule,
          birthday: user.birthday,
          level: user.level,
          semester: user.semester,
          section: user.section,
          filiere: user.filiere,
          academicYear: user.academicYear,
          githubLink: user.githubLink,
          linkedinLink: user.linkedinLink,
          otherLinks: user.otherLinks,
        );
      } else if (user is Lecturer) {
        updatedUser = Lecturer(
          userId: user.userId,
          username: user.username,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          phonenumber: user.phonenumber,
          password: user.password,
          isApproved: true,
          createdAt: user.createdAt,
          updatedAt: DateTime.now(),
          uniteDenseignement: user.uniteDenseignement,
          section: user.section,
          evaluationGrid: user.evaluationGrid,
          validationRequirements: user.validationRequirements,
          finalSubmissionRequirements: user.finalSubmissionRequirements,
        );
      } else {
        return false;
      }

      _users[index] = updatedUser;
      await _saveUsers();
      return true;
    } catch (e) {
      debugPrint('Failed to approve user: $e');
      return false;
    }
  }

  Future<void> syncWithAuthService() async {
    try {
      // Sync with database through AuthService
      final students = await AuthService().getAllStudents();
      final lecturers = await AuthService().getAllLecturers();
      
      _users.clear();
      _users.addAll(students);
      _users.addAll(lecturers);
      
      await _saveUsers();
    } catch (e) {
      debugPrint('Failed to sync with AuthService: $e');
    }
  }
}