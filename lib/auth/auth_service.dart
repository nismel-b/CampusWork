import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/database/database_helper.dart';
import 'package:campuswork/utils/security_helper.dart';
import 'package:intl/intl.dart';

class AuthService {

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Register a new user
  Future<User?> registerUser({
    required String userId,
    required String firstname,
    required String lastname,
    required String username,
    required String email,
    required String phonenumber,
    required String password,
    required UserRole userRole,
    required createdAt,
    required updatedAt,
  }) async {
    try {
      final db = await _dbHelper.database;
      final userId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('users', {
        'userId': userId,
        'firstname': firstname,
        'lastname': lastname,
        'username': username,
        'email': email,
        'phonenumber': phonenumber,
        'password': SecurityHelper.hashPassword(password), // Hash password for security
        'userRole': userRole.toString().split('.').last,
        'createdAt': now,
        'updatedAt': now,
      });

      return User(
        userId: '',
        username: '',
        firstName: '',
        lastName: '',
        email: '',
        phonenumber: '',
        password: '',
        userRole: UserRole.student,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      debugPrint('Error registering user: $e');
      return null;
    }
  }

  // Login user
  Future<User?> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      final db = await _dbHelper.database;
      // Get user by username first
      final userResult = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (userResult.isEmpty) return null;

      // Verify password hash
      final storedHash = userResult.first['password'] as String;
      if (!SecurityHelper.verifyPassword(password, storedHash)) {
        return null;
      }

      final result = userResult;

      if (result.isNotEmpty) {
        final userData = result.first;
        return User(
          userData['userId'] as String,
          userData['firstname'] as String,
          userData['lastname'] as String,
          userData['username'] as String,
          userData['email'] as String? ?? '',
          userData['phonenumber'] as String? ?? '',
          userData['password'] as String,
          userData['createdAt'] as String,
          userData["updatedAt"] as String,
          userData['userRole'] == 'student' ? UserRole.student : UserRole.lecturer,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error logging in: $e');
      return null;
    }
  }


  // Check if username exists
  Future<bool> usernameExists(String username) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking username: $e');
      return false;
    }
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'users',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      if (result.isNotEmpty) {
        final userData = result.first;
        return User(
          userData['userId'] as String,
          userData["firstname"] as String,
          userData['lastname'] as String,
          userData['username'] as String,
          userData['email'] as String? ?? '',
          userData['phonenumber'] as String? ?? '',
          userData['password'] as String,
          userData['createdAt'] as String,
          userData["updatedAt"] as String,
          userData['userRole'] == 'student' ? UserRole.student : UserRole.lecturer,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }
}
static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const _currentUserKey = 'current_user';
  static const _usersKey = 'all_users';
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_currentUserKey);
      if (userData != null) {
        final json = jsonDecode(userData);
        _currentUser = _parseUser(json);
      }

      // Add default admin if no users exist
      final users = await _getAllUsers();
      if (users.isEmpty) {
        await _createDefaultUsers();
      }
    } catch (e) {
      debugPrint('Failed to init auth: $e');
    }
  }
/*
  Future<void> _createDefaultUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // Default admin
      final admin = User(
        id: const Uuid().v4(),
        username: "user1",
        firstName: 'Admin',
        lastName: 'System',
        phonenumber: "101010",
        email: 'admin@school.edu',
        password: 'admin123',
        role: UserRole.admin,
        isApproved: true,
        createdAt: now,
        updatedAt: now,
      );

      // Sample lecturer
      final lecturer = Lecturer(
        id: const Uuid().v4(),
        username: 'user2',
        firstName: 'Dr. Marie',
        lastName: 'Dubois',
        phonenumber: "111111",
        email: 'marie.dubois@school.edu',
        password: 'lecturer123',
        isApproved: true,
        createdAt: now,
        updatedAt: now,
        uniteDenseignement: 'Informatique',
        section: 'L3',
      );

      // Sample student
      final student = Student(
        id: const Uuid().v4(),
        username: "user3",
        firstName: 'Jean',
        lastName: 'Martin',
        phonenumber: '222222',
        email: 'jean.martin@student.school.edu',
        password: 'student123',
        isApproved: true,
        createdAt: now,
        updatedAt: now,
        matricule: '2024001',
        birthday: DateTime(2002, 5, 15),
        level: 'L3',
        semester: 'S5',
        section: 'Informatique',
        filiere: 'Génie Logiciel',
        academicYear: '2024-2025',
        githubLink: 'https://github.com/jeanmartin',
      );

      final users = [admin, lecturer, student];
      await prefs.setString(_usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));
    } catch (e) {
      debugPrint('Failed to create default users: $e');
    }
  }
*/