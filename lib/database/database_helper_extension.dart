import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Extensions pour gérer les tables students et lecturers
/// À utiliser avec DatabaseHelper
class DatabaseExtensions {

  // ========================================
  // STUDENTS OPERATIONS
  // ========================================

  /// Insert Student data
  static Future<String?> insertStudent({
    required Database db,
    required String userId,
    required String matricule,
    required DateTime birthday,
    required String level,
    required String semester,
    required String section,
    required String filiere,
    required String academicYear,
    String? githubLink,
    String? linkedinLink,
    String? otherLink,
  }) async {
    try {
      final studentId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('students', {
        'studentId': studentId,
        'userId': userId,
        'matricule': matricule,
        'birthday': DateFormat('yyyy-MM-dd').format(birthday),
        'level': level,
        'semester': semester,
        'section': section,
        'filiere': filiere,
        'academicYear': academicYear,
        'githubLink': githubLink,
        'linkedinLink': linkedinLink,
        'otherLink': otherLink,
        'createdAt': now,
        'updatedAt': now,
      });

      debugPrint('✅ Student data inserted for userId: $userId');
      return studentId;
    } catch (e) {
      debugPrint('❌ Error inserting student: $e');
      return null;
    }
  }

  /// Get Student by userId
  static Future<Map<String, dynamic>?> getStudentByUserId({
    required Database db,
    required String userId,
  }) async {
    try {
      final result = await db.query(
        'students',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      if (result.isEmpty) return null;
      return result.first;
    } catch (e) {
      debugPrint('❌ Error getting student: $e');
      return null;
    }
  }

  /// Get Student by matricule
  static Future<Map<String, dynamic>?> getStudentByMatricule({
    required Database db,
    required String matricule,
  }) async {
    try {
      final result = await db.query(
        'students',
        where: 'matricule = ?',
        whereArgs: [matricule],
      );

      if (result.isEmpty) return null;
      return result.first;
    } catch (e) {
      debugPrint('❌ Error getting student by matricule: $e');
      return null;
    }
  }

  /// Update Student
  static Future<bool> updateStudent({
    required Database db,
    required String userId,
    String? matricule,
    DateTime? birthday,
    String? level,
    String? semester,
    String? section,
    String? filiere,
    String? academicYear,
    String? githubLink,
    String? linkedinLink,
    String? otherLink,
  }) async {
    try {
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      Map<String, dynamic> updates = {'updatedAt': now};

      if (matricule != null) updates['matricule'] = matricule;
      if (birthday != null) updates['birthday'] = DateFormat('yyyy-MM-dd').format(birthday);
      if (level != null) updates['level'] = level;
      if (semester != null) updates['semester'] = semester;
      if (section != null) updates['section'] = section;
      if (filiere != null) updates['filiere'] = filiere;
      if (academicYear != null) updates['academicYear'] = academicYear;
      if (githubLink != null) updates['githubLink'] = githubLink;
      if (linkedinLink != null) updates['linkedinLink'] = linkedinLink;
      if (otherLink != null) updates['otherLink'] = otherLink;

      final result = await db.update(
        'students',
        updates,
        where: 'userId = ?',
        whereArgs: [userId],
      );

      debugPrint('✅ Student updated successfully');
      return result > 0;
    } catch (e) {
      debugPrint('❌ Error updating student: $e');
      return false;
    }
  }

  /// Delete Student
  static Future<bool> deleteStudent({
    required Database db,
    required String userId,
  }) async {
    try {
      final result = await db.delete(
        'students',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      debugPrint('✅ Student deleted successfully');
      return result > 0;
    } catch (e) {
      debugPrint('❌ Error deleting student: $e');
      return false;
    }
  }

  /// Check if matricule exists
  static Future<bool> matriculeExists({
    required Database db,
    required String matricule,
  }) async {
    try {
      final result = await db.query(
        'students',
        where: 'matricule = ?',
        whereArgs: [matricule],
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking matricule: $e');
      return false;
    }
  }

  /// Get all Students
  static Future<List<Map<String, dynamic>>> getAllStudents({
    required Database db,
  }) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          u.userId, u.username, u.firstname, u.lastname, u.email, 
          u.phonenumber, u.userRole,
          s.studentId, s.matricule, s.birthday, s.level, s.semester, 
          s.section, s.filiere, s.academicYear, s.githubLink, 
          s.linkedinLink, s.otherLink,
          s.createdAt as studentCreatedAt, s.updatedAt as studentUpdatedAt
        FROM users u
        INNER JOIN students s ON u.userId = s.userId
        ORDER BY s.createdAt DESC
      ''');

      return result;
    } catch (e) {
      debugPrint('❌ Error getting all students: $e');
      return [];
    }
  }

  /// Get students by section
  static Future<List<Map<String, dynamic>>> getStudentsBySection({
    required Database db,
    required String section,
  }) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          u.userId, u.username, u.firstname, u.lastname, u.email,
          s.studentId, s.matricule, s.level, s.semester, s.section, s.filiere
        FROM users u
        INNER JOIN students s ON u.userId = s.userId
        WHERE s.section = ?
        ORDER BY s.lastname
      ''', [section]);

      return result;
    } catch (e) {
      debugPrint('❌ Error getting students by section: $e');
      return [];
    }
  }

  /// Get students by level
  static Future<List<Map<String, dynamic>>> getStudentsByLevel({
    required Database db,
    required String level,
  }) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          u.userId, u.username, u.firstname, u.lastname, u.email,
          s.studentId, s.matricule, s.level, s.semester, s.section, s.filiere
        FROM users u
        INNER JOIN students s ON u.userId = s.userId
        WHERE s.level = ?
        ORDER BY s.lastname
      ''', [level]);

      return result;
    } catch (e) {
      debugPrint('❌ Error getting students by level: $e');
      return [];
    }
  }

  /// Get students by filiere
  static Future<List<Map<String, dynamic>>> getStudentsByFiliere({
    required Database db,
    required String filiere,
  }) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          u.userId, u.username, u.firstname, u.lastname, u.email,
          s.studentId, s.matricule, s.level, s.semester, s.section, s.filiere
        FROM users u
        INNER JOIN students s ON u.userId = s.userId
        WHERE s.filiere = ?
        ORDER BY s.level, s.lastname
      ''', [filiere]);

      return result;
    } catch (e) {
      debugPrint('❌ Error getting students by filiere: $e');
      return [];
    }
  }

  // ========================================
  // LECTURERS OPERATIONS
  // ========================================

  /// Insert Lecturer data
  static Future<String?> insertLecturer({
    required Database db,
    required String userId,
    required String uniteDenseignement,
    required String section,
    String? evaluationGrid,
    String? validationRequirements,
    String? finalSubmissionRequirements,
  }) async {
    try {
      final lecturerId = const Uuid().v4();
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await db.insert('lecturers', {
        'lecturerId': lecturerId,
        'userId': userId,
        'uniteDenseignement': uniteDenseignement,
        'section': section,
        'evaluationGrid': evaluationGrid,
        'validationRequirements': validationRequirements,
        'finalSubmissionRequirements': finalSubmissionRequirements,
        'createdAt': now,
        'updatedAt': now,
      });

      debugPrint('✅ Lecturer data inserted for userId: $userId');
      return lecturerId;
    } catch (e) {
      debugPrint('❌ Error inserting lecturer: $e');
      return null;
    }
  }

  /// Get Lecturer by userId
  static Future<Map<String, dynamic>?> getLecturerByUserId({
    required Database db,
    required String userId,
  }) async {
    try {
      final result = await db.query(
        'lecturers',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      if (result.isEmpty) return null;
      return result.first;
    } catch (e) {
      debugPrint('❌ Error getting lecturer: $e');
      return null;
    }
  }

  /// Update Lecturer
  static Future<bool> updateLecturer({
    required Database db,
    required String userId,
    String? uniteDenseignement,
    String? section,
    String? evaluationGrid,
    String? validationRequirements,
    String? finalSubmissionRequirements,
  }) async {
    try {
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      Map<String, dynamic> updates = {'updatedAt': now};

      if (uniteDenseignement != null) updates['uniteDenseignement'] = uniteDenseignement;
      if (section != null) updates['section'] = section;
      if (evaluationGrid != null) updates['evaluationGrid'] = evaluationGrid;
      if (validationRequirements != null) updates['validationRequirements'] = validationRequirements;
      if (finalSubmissionRequirements != null) updates['finalSubmissionRequirements'] = finalSubmissionRequirements;

      final result = await db.update(
        'lecturers',
        updates,
        where: 'userId = ?',
        whereArgs: [userId],
      );

      debugPrint('✅ Lecturer updated successfully');
      return result > 0;
    } catch (e) {
      debugPrint('❌ Error updating lecturer: $e');
      return false;
    }
  }

  /// Delete Lecturer
  static Future<bool> deleteLecturer({
    required Database db,
    required String userId,
  }) async {
    try {
      final result = await db.delete(
        'lecturers',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      debugPrint('✅ Lecturer deleted successfully');
      return result > 0;
    } catch (e) {
      debugPrint('❌ Error deleting lecturer: $e');
      return false;
    }
  }

  /// Get all Lecturers
  static Future<List<Map<String, dynamic>>> getAllLecturers({
    required Database db,
  }) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          u.userId, u.username, u.firstname, u.lastname, u.email, 
          u.phonenumber, u.userRole,
          l.lecturerId, l.uniteDenseignement, l.section,
          l.evaluationGrid, l.validationRequirements, 
          l.finalSubmissionRequirements,
          l.createdAt as lecturerCreatedAt, l.updatedAt as lecturerUpdatedAt
        FROM users u
        INNER JOIN lecturers l ON u.userId = l.userId
        ORDER BY l.createdAt DESC
      ''');

      return result;
    } catch (e) {
      debugPrint('❌ Error getting all lecturers: $e');
      return [];
    }
  }

  /// Get lecturers by section
  static Future<List<Map<String, dynamic>>> getLecturersBySection({
    required Database db,
    required String section,
  }) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          u.userId, u.username, u.firstname, u.lastname, u.email,
          l.lecturerId, l.uniteDenseignement, l.section
        FROM users u
        INNER JOIN lecturers l ON u.userId = l.userId
        WHERE l.section = ?
        ORDER BY l.uniteDenseignement
      ''', [section]);

      return result;
    } catch (e) {
      debugPrint('❌ Error getting lecturers by section: $e');
      return [];
    }
  }

  /// Get lecturers by unite d'enseignement
  static Future<List<Map<String, dynamic>>> getLecturersByUnite({
    required Database db,
    required String uniteDenseignement,
  }) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          u.userId, u.username, u.firstname, u.lastname, u.email,
          l.lecturerId, l.uniteDenseignement, l.section
        FROM users u
        INNER JOIN lecturers l ON u.userId = l.userId
        WHERE l.uniteDenseignement = ?
        ORDER BY l.section
      ''', [uniteDenseignement]);

      return result;
    } catch (e) {
      debugPrint('❌ Error getting lecturers by unite: $e');
      return [];
    }
  }

  // ========================================
  // COMBINED OPERATIONS
  // ========================================

  /// Get complete user profile (user + student/lecturer data)
  static Future<Map<String, dynamic>?> getCompleteUserProfile({
    required Database db,
    required String userId,
  }) async {
    try {
      // Get user data
      final userResult = await db.query(
        'users',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      if (userResult.isEmpty) return null;

      final userData = Map<String, dynamic>.from(userResult.first);
      final userRole = userData['userRole'] as String;

      // Get role-specific data
      if (userRole == 'student') {
        final studentData = await getStudentByUserId(db: db, userId: userId);
        if (studentData != null) {
          userData.addAll({'studentData': studentData});
        }
      } else if (userRole == 'lecturer') {
        final lecturerData = await getLecturerByUserId(db: db, userId: userId);
        if (lecturerData != null) {
          userData.addAll({'lecturerData': lecturerData});
        }
      }

      return userData;
    } catch (e) {
      debugPrint('❌ Error getting complete user profile: $e');
      return null;
    }
  }

  /// Search users by name
  static Future<List<Map<String, dynamic>>> searchUsers({
    required Database db,
    required String query,
  }) async {
    try {
      final result = await db.rawQuery('''
        SELECT userId, username, firstname, lastname, email, userRole
        FROM users
        WHERE firstname LIKE ? OR lastname LIKE ? OR username LIKE ? OR email LIKE ?
        ORDER BY firstname, lastname
        LIMIT 50
      ''', ['%$query%', '%$query%', '%$query%', '%$query%']);

      return result;
    } catch (e) {
      debugPrint('❌ Error searching users: $e');
      return [];
    }
  }
}