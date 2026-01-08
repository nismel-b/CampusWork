import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/database/database_helper.dart';
import 'package:campuswork/utils/security_helper.dart';
import 'package:intl/intl.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Properties
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static const _currentUserKey = 'current_user';
  User? _currentUser;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Initialize auth service
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_currentUserKey);
      
      if (userData != null) {
        final json = jsonDecode(userData);
        _currentUser = await getUserById(json['userId']);
      }

      // Add default users if no users exist
      final users = await _getAllUsers();
      if (users.isEmpty) {
        await _createDefaultUsers();
      }
    } catch (e) {
      debugPrint('Failed to init auth: $e');
    }
  }

  // Register a new user
  Future<User?> registerUser({
    required String firstname,
    required String lastname,
    required String username,
    required String email,
    required String phonenumber,
    required String password,
    required UserRole userRole,
  }) async {
    try {
      // Check if username already exists
      if (await usernameExists(username)) {
        debugPrint('Username already exists');
        return null;
      }

      // Check if email already exists
      if (await emailExists(email)) {
        debugPrint('Email already exists');
        return null;
      }

      final db = await _dbHelper.database;
      final userId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final hashedPassword = SecurityHelper.hashPassword(password);

      // Insert into users table
      await db.insert('users', {
        'userId': userId,
        'firstname': firstname,
        'lastname': lastname,
        'username': username,
        'email': email,
        'phonenumber': phonenumber,
        'password': hashedPassword,
        'userRole': userRole.toString().split('.').last,
        'isApproved': 1,
        'createdAt': now,
        'updatedAt': now,
      });

      debugPrint('✅ User registered successfully: $username');

      // Return the created user
      return User(
        userId: userId,
        firstName: firstname,
        lastName: lastname,
        username: username,
        email: email,
        phonenumber: phonenumber,
        password: hashedPassword,
        userRole: userRole,
        createdAt: DateTime.parse(now),
        updatedAt: DateTime.parse(now),
      );
    } catch (e) {
      debugPrint('❌ Error registering user: $e');
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
      
      // Get user by username
      final userResult = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (userResult.isEmpty) {
        debugPrint('User not found');
        return null;
      }

      // Verify password hash
      final userData = userResult.first;
      final storedHash = userData['password'] as String;
      
      if (!SecurityHelper.verifyPassword(password, storedHash)) {
        debugPrint('Invalid password');
        return null;
      }

      // Check if user is approved
      final isApproved = userData['isApproved'] as int;
      if (isApproved == 0) {
        debugPrint('User not approved yet');
        return null;
      }

      // Create user object
      final user = User(
        userId: userData['userId'] as String,
        firstName: userData['firstname'] as String,
        lastName: userData['lastname'] as String,
        username: userData['username'] as String,
        email: userData['email'] as String? ?? '',
        phonenumber: userData['phonenumber'] as String? ?? '',
        password: userData['password'] as String,
        createdAt: DateTime.parse(userData['createdAt'] as String),
        updatedAt: DateTime.parse(userData['updatedAt'] as String),
        userRole: userData['userRole'] == 'student' 
            ? UserRole.student 
            : UserRole.lecturer,
      );

      // Save current user to SharedPreferences
      await _saveCurrentUser(user);
      _currentUser = user;

      debugPrint('✅ User logged in: ${user.username}');
      return user;
    } catch (e) {
      debugPrint('❌ Error logging in: $e');
      return null;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      _currentUser = null;
      debugPrint('✅ User logged out');
    } catch (e) {
      debugPrint('❌ Error logging out: $e');
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

  // Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking email: $e');
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
          userId: userData['userId'] as String,
          firstName: userData['firstname'] as String,
          lastName: userData['lastname'] as String,
          username: userData['username'] as String,
          email: userData['email'] as String? ?? '',
          phonenumber: userData['phonenumber'] as String? ?? '',
          password: userData['password'] as String,
          createdAt: DateTime.parse(userData['createdAt'] as String),
          updatedAt: DateTime.parse(userData['updatedAt'] as String),
          userRole: userData['userRole'] == 'student' 
              ? UserRole.student 
              : UserRole.lecturer,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  // Get user by email
  Future<User?> getUserByEmail(String email) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (result.isNotEmpty) {
        final userData = result.first;
        return User(
          userId: userData['userId'] as String,
          firstName: userData['firstname'] as String,
          lastName: userData['lastname'] as String,
          username: userData['username'] as String,
          email: userData['email'] as String? ?? '',
          phonenumber: userData['phonenumber'] as String? ?? '',
          password: userData['password'] as String,
          createdAt: DateTime.parse(userData['createdAt'] as String),
          updatedAt: DateTime.parse(userData['updatedAt'] as String),
          userRole: userData['userRole'] == 'student' 
              ? UserRole.student 
              : UserRole.lecturer,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by email: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUser({
    required String userId,
    String? firstname,
    String? lastname,
    String? email,
    String? phonenumber,
  }) async {
    try {
      final db = await _dbHelper.database;
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      Map<String, dynamic> updates = {'updatedAt': now};
      
      if (firstname != null) updates['firstname'] = firstname;
      if (lastname != null) updates['lastname'] = lastname;
      if (email != null) updates['email'] = email;
      if (phonenumber != null) updates['phonenumber'] = phonenumber;

      final result = await db.update(
        'users',
        updates,
        where: 'userId = ?',
        whereArgs: [userId],
      );

      // Update current user if it's the same user
      if (_currentUser?.userId == userId) {
        _currentUser = await getUserById(userId);
        if (_currentUser != null) {
          await _saveCurrentUser(_currentUser!);
        }
      }

      debugPrint('✅ User updated successfully');
      return result > 0;
    } catch (e) {
      debugPrint('❌ Error updating user: $e');
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return false;

      // Verify old password
      if (!SecurityHelper.verifyPassword(oldPassword, user.password)) {
        debugPrint('Old password is incorrect');
        return false;
      }

      final db = await _dbHelper.database;
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final hashedPassword = SecurityHelper.hashPassword(newPassword);

      final result = await db.update(
        'users',
        {
          'password': hashedPassword,
          'updatedAt': now,
        },
        where: 'userId = ?',
        whereArgs: [userId],
      );

      debugPrint('✅ Password changed successfully');
      return result > 0;
    } catch (e) {
      debugPrint('❌ Error changing password: $e');
      return false;
    }
  }

  // Approve user (admin function)
  Future<bool> approveUser(String userId) async {
    try {
      final db = await _dbHelper.database;
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final result = await db.update(
        'users',
        {
          'isApproved': 1,
          'updatedAt': now,
        },
        where: 'userId = ?',
        whereArgs: [userId],
      );

      debugPrint('✅ User approved successfully');
      return result > 0;
    } catch (e) {
      debugPrint('❌ Error approving user: $e');
      return false;
    }
  }

  // Get all users (admin function)
  Future<List<User>> _getAllUsers() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query('users');

      return result.map((userData) {
        return User(
          userId: userData['userId'] as String,
          firstName: userData['firstname'] as String,
          lastName: userData['lastname'] as String,
          username: userData['username'] as String,
          email: userData['email'] as String? ?? '',
          phonenumber: userData['phonenumber'] as String? ?? '',
          password: userData['password'] as String,
          createdAt: DateTime.parse(userData['createdAt'] as String),
          updatedAt: DateTime.parse(userData['updatedAt'] as String),
          userRole: userData['userRole'] == 'student' 
              ? UserRole.student 
              : UserRole.lecturer,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  // Get all students
  Future<List<User>> getAllStudents() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'users',
        where: 'userRole = ?',
        whereArgs: ['student'],
      );

      return result.map((userData) {
        return User(
          userId: userData['userId'] as String,
          firstName: userData['firstname'] as String,
          lastName: userData['lastname'] as String,
          username: userData['username'] as String,
          email: userData['email'] as String? ?? '',
          phonenumber: userData['phonenumber'] as String? ?? '',
          password: userData['password'] as String,
          createdAt: DateTime.parse(userData['createdAt'] as String),
          updatedAt: DateTime.parse(userData['updatedAt'] as String),
          userRole: UserRole.student,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting students: $e');
      return [];
    }
  }

  // Get all lecturers
  Future<List<User>> getAllLecturers() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'users',
        where: 'userRole = ?',
        whereArgs: ['lecturer'],
      );

      return result.map((userData) {
        return User(
          userId: userData['userId'] as String,
          firstName: userData['firstname'] as String,
          lastName: userData['lastname'] as String,
          username: userData['username'] as String,
          email: userData['email'] as String? ?? '',
          phonenumber: userData['phonenumber'] as String? ?? '',
          password: userData['password'] as String,
          createdAt: DateTime.parse(userData['createdAt'] as String),
          updatedAt: DateTime.parse(userData['updatedAt'] as String),
          userRole: UserRole.lecturer,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting lecturers: $e');
      return [];
    }
  }

  // Create default users (admin/test accounts)
  Future<void> _createDefaultUsers() async {
    try {
      // Create default admin/lecturer
      await registerUser(
        firstname: 'Admin',
        lastname: 'CampusWork',
        username: 'admin',
        email: 'admin@campuswork.com',
        phonenumber: '+237000000000',
        password: 'admin123',
        userRole: UserRole.lecturer,
      );

      // Create default student
      await registerUser(
        firstname: 'Student',
        lastname: 'Test',
        username: 'student',
        email: 'student@campuswork.com',
        phonenumber: '+237000000001',
        password: 'student123',
        userRole: UserRole.student,
      );

      debugPrint('✅ Default users created successfully');
    } catch (e) {
      debugPrint('❌ Error creating default users: $e');
    }
  }

  // Save current user to SharedPreferences
  Future<void> _saveCurrentUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({
        'userId': user.userId,
        'username': user.username,
        'firstname': user.firstName,
        'lastname': user.lastName,
        'email': user.email,
        'phonenumber': user.phonenumber,
        'userRole': user.userRole.toString().split('.').last,
      });
      await prefs.setString(_currentUserKey, userData);
    } catch (e) {
      debugPrint('Error saving current user: $e');
    }
  }

  // Delete user (admin function)
  Future<bool> deleteUser(String userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'users',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      
      debugPrint('✅ User deleted successfully');
      return result > 0;
    } catch (e) {
      debugPrint('❌ Error deleting user: $e');
      return false;
    }
  }
}