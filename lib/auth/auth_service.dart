import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/model/user.dart';
import 'package:campuswork/model/student.dart';
import 'package:campuswork/model/lecturer.dart';
import 'package:campuswork/database/database_helper.dart';
import 'package:campuswork/database/database_helper_extension.dart';
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
      debugPrint('🔄 Initializing AuthService...');
      
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_currentUserKey);
      
      if (userData != null) {
        final json = jsonDecode(userData);
        _currentUser = await getUserById(json['userId']);
        debugPrint('✅ Current user loaded from preferences: ${_currentUser?.username}');
      }

      // Add default users if no users exist
      final users = await _getAllUsers();
      debugPrint('📊 Found ${users.length} users in database');
      
      if (users.isEmpty) {
        debugPrint('🔄 Creating default users...');
        await _createDefaultUsers();
      }

      // Debug: List all users and test default passwords
      await debugListAllUsers();
      
      // Test default user passwords
      await debugTestPassword('admin123', 'admin');
      await debugTestPassword('lecturer123', 'lecturer');
      await debugTestPassword('student123', 'student');
      
      debugPrint('✅ AuthService initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to init auth: $e');
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
      debugPrint('🔄 Starting registration for username: $username, email: $email');
      
      // Check if username already exists
      if (await usernameExists(username)) {
        debugPrint('❌ Username already exists: $username');
        return null;
      }

      // Check if email already exists
      if (await emailExists(email)) {
        debugPrint('❌ Email already exists: $email');
        return null;
      }

      final db = await _dbHelper.database;
      final userId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final hashedPassword = SecurityHelper.hashPassword(password);

      debugPrint('🔐 Generated password hash: ${hashedPassword.substring(0, 20)}...');

      // Insert into users table
      final insertResult = await db.insert('users', {
        'userId': userId,
        'firstname': firstname,
        'lastname': lastname,
        'username': username,
        'email': email,
        'phonenumber': phonenumber,
        'password': hashedPassword,
        'userRole': userRole.toString().split('.').last,
        'isApproved': 1, // Auto-approve for now
        'createdAt': now,
        'updatedAt': now,
      });

      debugPrint('✅ User inserted with ID: $insertResult');

      // Verify the user was actually inserted
      final verifyResult = await db.query(
        'users',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      if (verifyResult.isEmpty) {
        debugPrint('❌ Failed to verify user insertion');
        return null;
      }

      debugPrint('✅ User registration verified in database');

      // Return the created user
      final user = User(
        userId: userId,
        firstName: firstname,
        lastName: lastname,
        username: username,
        email: email,
        phonenumber: phonenumber,
        password: hashedPassword,
        userRole: userRole,
        isApproved: true,
        createdAt: DateTime.parse(now),
        updatedAt: DateTime.parse(now),
      );

      debugPrint('✅ User registered successfully: $username (ID: $userId)');
      return user;
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
      debugPrint('🔍 Attempting login for username: $username');
      final db = await _dbHelper.database;
      
      // First, try to find user by username
      var userResult = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      // If not found by username, try by email
      if (userResult.isEmpty) {
        debugPrint('🔍 User not found by username, trying email...');
        userResult = await db.query(
          'users',
          where: 'email = ?',
          whereArgs: [username],
        );
      }

      if (userResult.isEmpty) {
        debugPrint('❌ User not found with username/email: $username');
        
        // Debug: List all users in database
        final allUsers = await db.query('users');
        debugPrint('📋 Total users in database: ${allUsers.length}');
        for (var user in allUsers) {
          debugPrint('   - Username: ${user['username']}, Email: ${user['email']}');
        }
        
        return null;
      }

      // Verify password hash
      final userData = userResult.first;
      final storedHash = userData['password'] as String;
      
      debugPrint('🔐 Verifying password for user: ${userData['username']}');
      debugPrint('🔐 Stored hash: ${storedHash.substring(0, 20)}...');
      
      if (!SecurityHelper.verifyPassword(password, storedHash)) {
        debugPrint('❌ Invalid password for user: ${userData['username']}');
        return null;
      }

      // Check if user is approved
      final isApproved = userData['isApproved'] as int;
      if (isApproved == 0) {
        debugPrint('⏳ User not approved yet: ${userData['username']}');
        return null;
      }

      debugPrint('✅ Login successful for user: ${userData['username']}');

      // Create user object with role-specific data
      final user = await _createUserWithRoleData(userData);

      // Save current user to SharedPreferences
      if (user != null) {
        await _saveCurrentUser(user);
        _currentUser = user;
        debugPrint('✅ User logged in and saved: ${user.username}');
      }

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
        return await _createUserWithRoleData(userData);
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
        return await _createUserWithRoleData(userData);
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
      // Validate email format if provided
      if (email != null && !_isValidEmail(email)) {
        debugPrint('❌ Invalid email format');
        return false;
      }

      // Check if email already exists (for other users)
      if (email != null) {
        final existingUser = await getUserByEmail(email);
        if (existingUser != null && existingUser.userId != userId) {
          debugPrint('❌ Email already exists for another user');
          return false;
        }
      }

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

  // Update username (separate method for validation)
  Future<bool> updateUsername({
    required String userId,
    required String newUsername,
  }) async {
    try {
      // Check if username already exists
      if (await usernameExists(newUsername)) {
        final existingUser = await getUserById(userId);
        if (existingUser?.username != newUsername) {
          debugPrint('❌ Username already exists');
          return false;
        }
      }

      final db = await _dbHelper.database;
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final result = await db.update(
        'users',
        {
          'username': newUsername,
          'updatedAt': now,
        },
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

      debugPrint('✅ Username updated successfully');
      return result > 0;
    } catch (e) {
      debugPrint('❌ Error updating username: $e');
      return false;
    }
  }

  // Helper method to validate email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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
          userRole: _parseUserRole(userData['userRole'] as String),
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
      // Create default admin
      await registerUser(
        firstname: 'Admin',
        lastname: 'CampusWork',
        username: 'admin',
        email: 'admin@campuswork.com',
        phonenumber: '+237000000000',
        password: 'admin123',
        userRole: UserRole.admin,
      );

      // Create default lecturer
      await registerUser(
        firstname: 'Lecturer',
        lastname: 'Test',
        username: 'lecturer',
        email: 'lecturer@campuswork.com',
        phonenumber: '+237000000001',
        password: 'lecturer123',
        userRole: UserRole.lecturer,
      );

      // Create default student
      await registerUser(
        firstname: 'Student',
        lastname: 'Test',
        username: 'student',
        email: 'student@campuswork.com',
        phonenumber: '+237000000002',
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

  // Get pending users (admin function)
  Future<List<User>> getPendingUsers() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'users',
        where: 'isApproved = ?',
        whereArgs: [0],
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
          userRole: _parseUserRole(userData['userRole'] as String),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting pending users: $e');
      return [];
    }
  }

  // Reject user (admin function)
  Future<bool> rejectUser(String userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'users',
        where: 'userId = ? AND isApproved = ?',
        whereArgs: [userId, 0],
      );

      debugPrint('✅ User rejected and deleted successfully');
      return result > 0;
    } catch (e) {
      debugPrint('❌ Error rejecting user: $e');
      return false;
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

  // Helper method to parse user role
  UserRole _parseUserRole(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'lecturer':
        return UserRole.lecturer;
      case 'student':
        return UserRole.student;
      default:
        return UserRole.student;
    }
  }

  // Debug method to list all users
  Future<void> debugListAllUsers() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query('users');
      
      debugPrint('📋 === DEBUG: All users in database ===');
      debugPrint('📋 Total users: ${result.length}');
      
      for (var user in result) {
        debugPrint('📋 User: ${user['username']} | Email: ${user['email']} | Role: ${user['userRole']} | Approved: ${user['isApproved']}');
        debugPrint('    Password hash: ${(user['password'] as String).substring(0, 20)}...');
      }
      debugPrint('📋 === End of user list ===');
    } catch (e) {
      debugPrint('❌ Error listing users: $e');
    }
  }

  // Test method to verify password hashing
  Future<void> debugTestPassword(String plainPassword, String username) async {
    try {
      final hashedPassword = SecurityHelper.hashPassword(plainPassword);
      debugPrint('🔐 === DEBUG: Password test for $username ===');
      debugPrint('🔐 Plain password: $plainPassword');
      debugPrint('🔐 Hashed password: ${hashedPassword.substring(0, 20)}...');
      
      final db = await _dbHelper.database;
      final result = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      
      if (result.isNotEmpty) {
        final storedHash = result.first['password'] as String;
        debugPrint('🔐 Stored hash: ${storedHash.substring(0, 20)}...');
        debugPrint('🔐 Hashes match: ${hashedPassword == storedHash}');
        debugPrint('🔐 Verify function result: ${SecurityHelper.verifyPassword(plainPassword, storedHash)}');
      } else {
        debugPrint('🔐 User not found in database');
      }
      debugPrint('🔐 === End of password test ===');
    } catch (e) {
      debugPrint('❌ Error testing password: $e');
    }
  }
  Future<User?> _createUserWithRoleData(Map<String, dynamic> userData) async {
    try {
      final userRole = _parseUserRole(userData['userRole'] as String);
      final userId = userData['userId'] as String;

      if (userRole == UserRole.student) {
        // Get student-specific data
        final db = await _dbHelper.database;
        final studentData = await DatabaseExtensions.getStudentByUserId(
          db: db, 
          userId: userId,
        );

        if (studentData != null) {
          return Student(
            userId: userId,
            username: userData['username'] as String,
            firstName: userData['firstname'] as String,
            lastName: userData['lastname'] as String,
            email: userData['email'] as String? ?? '',
            phonenumber: userData['phonenumber'] as String? ?? '',
            password: userData['password'] as String,
            isApproved: (userData['isApproved'] as int) == 1,
            createdAt: DateTime.parse(userData['createdAt'] as String),
            updatedAt: DateTime.parse(userData['updatedAt'] as String),
            matricule: studentData['matricule'] as String,
            birthday: DateTime.parse(studentData['birthday'] as String),
            level: studentData['level'] as String,
            semester: studentData['semester'] as String,
            section: studentData['section'] as String,
            filiere: studentData['filiere'] as String,
            academicYear: studentData['academicYear'] as String,
            githubLink: studentData['githubLink'] as String?,
            linkedinLink: studentData['linkedinLink'] as String?,
          );
        }
      } else if (userRole == UserRole.lecturer) {
        // Get lecturer-specific data
        final db = await _dbHelper.database;
        final lecturerData = await DatabaseExtensions.getLecturerByUserId(
          db: db, 
          userId: userId,
        );

        if (lecturerData != null) {
          return Lecturer(
            userId: userId,
            username: userData['username'] as String,
            firstName: userData['firstname'] as String,
            lastName: userData['lastname'] as String,
            email: userData['email'] as String? ?? '',
            phonenumber: userData['phonenumber'] as String? ?? '',
            password: userData['password'] as String,
            isApproved: (userData['isApproved'] as int) == 1,
            createdAt: DateTime.parse(userData['createdAt'] as String),
            updatedAt: DateTime.parse(userData['updatedAt'] as String),
            uniteDenseignement: lecturerData['uniteDenseignement'] as String,
            section: lecturerData['section'] as String,
            evaluationGrid: lecturerData['evaluationGrid'] as String?,
            validationRequirements: lecturerData['validationRequirements'] as String?,
            finalSubmissionRequirements: lecturerData['finalSubmissionRequirements'] as String?,
          );
        }
      }

      // Default to basic User for admin or if role-specific data not found
      return User(
        userId: userId,
        username: userData['username'] as String,
        firstName: userData['firstname'] as String,
        lastName: userData['lastname'] as String,
        email: userData['email'] as String? ?? '',
        phonenumber: userData['phonenumber'] as String? ?? '',
        password: userData['password'] as String,
        userRole: userRole,
        isApproved: (userData['isApproved'] as int) == 1,
        createdAt: DateTime.parse(userData['createdAt'] as String),
        updatedAt: DateTime.parse(userData['updatedAt'] as String),
      );
    } catch (e) {
      debugPrint('❌ Error creating user with role data: $e');
      return null;
    }
  }
}