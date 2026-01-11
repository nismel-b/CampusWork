import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('campuswork.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5, // Incrémenté pour les nouvelles tables
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // ========================================
    // TABLE: users
    // ========================================
    await db.execute('''
      CREATE TABLE users (
        userId TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        firstname TEXT NOT NULL,
        lastname TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phonenumber TEXT,
        password TEXT NOT NULL,
        userRole TEXT NOT NULL,
        isApproved INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // ========================================
    // TABLE: students
    // ========================================
    await db.execute('''
      CREATE TABLE students (
        studentId TEXT PRIMARY KEY,
        userId TEXT NOT NULL UNIQUE,
        matricule TEXT NOT NULL UNIQUE,
        birthday TEXT,
        level TEXT NOT NULL,
        semester TEXT NOT NULL, 
        section TEXT NOT NULL,
        filiere TEXT NOT NULL,
        academicYear TEXT NOT NULL, 
        githubLink TEXT,
        linkedinLink TEXT,
        otherLink TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE
      )
    ''');

    // ========================================
    // TABLE: lecturers
    // ========================================
    await db.execute('''
      CREATE TABLE lecturers (
        lecturerId TEXT PRIMARY KEY,
        userId TEXT NOT NULL UNIQUE,
        uniteDenseignement TEXT NOT NULL,
        section TEXT NOT NULL,
        evaluationGrid TEXT,
        validationRequirements TEXT,
        finalSubmissionRequirements TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE
      )
    ''');

    // ========================================
    // TABLE: projects
    // ========================================
    await db.execute('''
      CREATE TABLE projects (
        projectId TEXT PRIMARY KEY,
        studentId TEXT NOT NULL,
        projectName TEXT NOT NULL,
        courseName TEXT,
        description TEXT NOT NULL,
        category TEXT,
        imageUrl TEXT,
        collaborators TEXT,
        architecturePatterns TEXT,
        uml TEXT,
        prototypeLink TEXT,
        downloadLink TEXT,
        status TEXT DEFAULT 'draft',
        resources TEXT,
        prerequisites TEXT,
        powerpointLink TEXT,
        reportLink TEXT,
        state TEXT DEFAULT 'pending',
        grade REAL,
        lecturerComment TEXT,
        likesCount INTEGER DEFAULT 0,
        commentsCount INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (studentId) REFERENCES students (studentId) ON DELETE CASCADE
      )
    ''');

    // ========================================
    // TABLE: project_images
    // ========================================
    await db.execute('''
      CREATE TABLE project_images (
        imageId TEXT PRIMARY KEY,
        projectId TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (projectId) REFERENCES projects (projectId) ON DELETE CASCADE
      )
    ''');

    // ========================================
    // TABLE: project_favorites
    // ========================================
    await db.execute('''
      CREATE TABLE project_favorites (
        favoriteId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        projectId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE,
        FOREIGN KEY (projectId) REFERENCES projects (projectId) ON DELETE CASCADE,
        UNIQUE(userId, projectId)
      )
    ''');

    // ========================================
    // TABLE: project_history
    // ========================================
    await db.execute('''
      CREATE TABLE project_history (
        historyId TEXT PRIMARY KEY,
        projectId TEXT NOT NULL,
        action TEXT NOT NULL,
        details TEXT,
        userId TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (projectId) REFERENCES projects (projectId) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE SET NULL
      )
    ''');

    // ========================================
    // TABLE: messages
    // ========================================
    await db.execute('''
      CREATE TABLE messages (
        messageId TEXT PRIMARY KEY,
        senderId TEXT NOT NULL,
        receiverId TEXT NOT NULL,
        content TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        synced INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (senderId) REFERENCES users (userId) ON DELETE CASCADE,
        FOREIGN KEY (receiverId) REFERENCES users (userId) ON DELETE CASCADE
      )
    ''');

    // ========================================
    // TABLE: reviews
    // ========================================
    await db.execute('''
      CREATE TABLE reviews (
        reviewId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        projectId TEXT NOT NULL,
        rating INTEGER NOT NULL CHECK(rating >= 1 AND rating <= 5),
        comment TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE,
        FOREIGN KEY (projectId) REFERENCES projects (projectId) ON DELETE CASCADE,
        UNIQUE(userId, projectId)
      )
    ''');

    // ========================================
    // TABLE: stories
    // ========================================
    await db.execute('''
      CREATE TABLE stories (
        storyId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'announcement',
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        projectId TEXT,
        createdAt TEXT NOT NULL,
        expiresAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE,
        FOREIGN KEY (projectId) REFERENCES projects (projectId) ON DELETE SET NULL
      )
    ''');

    // ========================================
    // TABLE: notifications
    // ========================================
    await db.execute('''
      CREATE TABLE notifications (
        notificationId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        projectId TEXT,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        relatedId TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE,
        FOREIGN KEY (projectId) REFERENCES projects (projectId) ON DELETE SET NULL
      )
    ''');

    // ========================================
    // TABLE: cards (Kanban/Tasks)
    // ========================================
    await db.execute('''
      CREATE TABLE cards (
        cardId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        projectId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT DEFAULT 'todo',
        priority INTEGER DEFAULT 0,
        dueDate TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE,
        FOREIGN KEY (projectId) REFERENCES projects (projectId) ON DELETE CASCADE
      )
    ''');

    // ========================================
    // TABLE: notations (Grading/Evaluation)
    // ========================================
    await db.execute('''
      CREATE TABLE notations (
        notationId TEXT PRIMARY KEY,
        projectId TEXT NOT NULL,
        lecturerId TEXT NOT NULL,
        studentId TEXT NOT NULL,
        grade REAL,
        criteria TEXT,
        comment TEXT,
        status TEXT DEFAULT 'pending',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (projectId) REFERENCES projects (projectId) ON DELETE CASCADE,
        FOREIGN KEY (lecturerId) REFERENCES lecturers (lecturerId) ON DELETE CASCADE,
        FOREIGN KEY (studentId) REFERENCES students (studentId) ON DELETE CASCADE
      )
    ''');

    // ========================================
    // TABLE: surveys
    // ========================================
    await db.execute('''
      CREATE TABLE surveys (
        surveyId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        question TEXT NOT NULL,
        type TEXT NOT NULL,
        options TEXT,
        createdAt TEXT NOT NULL,
        expiresAt TEXT,
        FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE
      )
    ''');

    // ========================================
    // TABLE: survey_responses
    // ========================================
    await db.execute('''
      CREATE TABLE survey_responses (
        responseId TEXT PRIMARY KEY,
        surveyId TEXT NOT NULL,
        userId TEXT NOT NULL,
        answer TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (surveyId) REFERENCES surveys (surveyId) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE,
        UNIQUE(surveyId, userId)
      )
    ''');

    // ========================================
    // TABLE: onboarding_status
    // ========================================
    await db.execute('''
      CREATE TABLE onboarding_status (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL UNIQUE,
        completed INTEGER DEFAULT 0,
        currentStep INTEGER DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE
      )
    ''');

    // ========================================
    // INDEXES for better performance
    // ========================================
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_users_username ON users(username)');
    await db.execute('CREATE INDEX idx_students_matricule ON students(matricule)');
    await db.execute('CREATE INDEX idx_students_userId ON students(userId)');
    await db.execute('CREATE INDEX idx_lecturers_userId ON lecturers(userId)');
    await db.execute('CREATE INDEX idx_projects_studentId ON projects(studentId)');
    await db.execute('CREATE INDEX idx_projects_status ON projects(status)');
    await db.execute('CREATE INDEX idx_messages_senderId ON messages(senderId)');
    await db.execute('CREATE INDEX idx_messages_receiverId ON messages(receiverId)');
    await db.execute('CREATE INDEX idx_notifications_userId ON notifications(userId)');
    await db.execute('CREATE INDEX idx_notifications_isRead ON notifications(isRead)');

    debugPrint('✅ Database created successfully with version $version');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('🔄 Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      // Add project_history table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS project_history (
          historyId TEXT PRIMARY KEY,
          projectId TEXT NOT NULL,
          action TEXT NOT NULL,
          details TEXT,
          userId TEXT,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (projectId) REFERENCES projects (projectId) ON DELETE CASCADE,
          FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE SET NULL
        )
      ''');

      // Update stories table
      await db.execute('ALTER TABLE stories ADD COLUMN type TEXT DEFAULT "announcement"').catchError((e) => debugPrint('Column type already exists'));
      await db.execute('ALTER TABLE stories ADD COLUMN title TEXT').catchError((e) => debugPrint('Column title already exists'));
      await db.execute('ALTER TABLE stories ADD COLUMN description TEXT').catchError((e) => debugPrint('Column description already exists'));
      await db.execute('ALTER TABLE stories ADD COLUMN projectId TEXT').catchError((e) => debugPrint('Column projectId already exists'));

      // Update messages table
      await db.execute('ALTER TABLE messages ADD COLUMN isRead INTEGER DEFAULT 0').catchError((e) => debugPrint('Column isRead already exists'));
      await db.execute('ALTER TABLE messages ADD COLUMN synced INTEGER DEFAULT 0').catchError((e) => debugPrint('Column synced already exists'));

      // Update projects table
      await db.execute('ALTER TABLE projects ADD COLUMN updatedAt TEXT').catchError((e) => debugPrint('Column updatedAt already exists'));

      // Add project_images table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS project_images (
          imageId TEXT PRIMARY KEY,
          projectId TEXT NOT NULL,
          imageUrl TEXT NOT NULL,
          description TEXT,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (projectId) REFERENCES projects (projectId) ON DELETE CASCADE
        )
      ''');

      // Add surveys tables
      await db.execute('''
        CREATE TABLE IF NOT EXISTS surveys (
          surveyId TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          question TEXT NOT NULL,
          type TEXT NOT NULL,
          options TEXT,
          createdAt TEXT NOT NULL,
          expiresAt TEXT,
          FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS survey_responses (
          responseId TEXT PRIMARY KEY,
          surveyId TEXT NOT NULL,
          userId TEXT NOT NULL,
          answer TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (surveyId) REFERENCES surveys (surveyId) ON DELETE CASCADE,
          FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE,
          UNIQUE(surveyId, userId)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS onboarding_status (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL UNIQUE,
          completed INTEGER DEFAULT 0,
          FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 3) {
      // Rename old tables if they exist
      await _renameTableIfExists(db, 'user', 'users');
      await _renameTableIfExists(db, 'project', 'projects');
      await _renameTableIfExists(db, 'student', 'students');
      await _renameTableIfExists(db, 'lecturer', 'lecturers');
      await _renameTableIfExists(db, 'notification', 'notifications');
      await _renameTableIfExists(db, 'card', 'cards');
      await _renameTableIfExists(db, 'notation', 'notations');

      // Add missing columns to students
      await db.execute('ALTER TABLE students ADD COLUMN createdAt TEXT').catchError((e) => debugPrint('Column createdAt already exists'));
      await db.execute('ALTER TABLE students ADD COLUMN updatedAt TEXT').catchError((e) => debugPrint('Column updatedAt already exists'));

      // Add missing columns to lecturers
      await db.execute('ALTER TABLE lecturers ADD COLUMN createdAt TEXT').catchError((e) => debugPrint('Column createdAt already exists'));
      await db.execute('ALTER TABLE lecturers ADD COLUMN updatedAt TEXT').catchError((e) => debugPrint('Column updatedAt already exists'));

      // Fix cards table structure
      await db.execute('ALTER TABLE cards ADD COLUMN title TEXT').catchError((e) => debugPrint('Column title already exists'));
      await db.execute('ALTER TABLE cards ADD COLUMN description TEXT').catchError((e) => debugPrint('Column description already exists'));
      await db.execute('ALTER TABLE cards ADD COLUMN status TEXT DEFAULT "todo"').catchError((e) => debugPrint('Column status already exists'));
      await db.execute('ALTER TABLE cards ADD COLUMN priority INTEGER DEFAULT 0').catchError((e) => debugPrint('Column priority already exists'));
      await db.execute('ALTER TABLE cards ADD COLUMN dueDate TEXT').catchError((e) => debugPrint('Column dueDate already exists'));
      await db.execute('ALTER TABLE cards ADD COLUMN updatedAt TEXT').catchError((e) => debugPrint('Column updatedAt already exists'));

      // Fix notations table structure
      await db.execute('ALTER TABLE notations ADD COLUMN studentId TEXT').catchError((e) => debugPrint('Column studentId already exists'));
      await db.execute('ALTER TABLE notations ADD COLUMN grade REAL').catchError((e) => debugPrint('Column grade already exists'));
      await db.execute('ALTER TABLE notations ADD COLUMN criteria TEXT').catchError((e) => debugPrint('Column criteria already exists'));
      await db.execute('ALTER TABLE notations ADD COLUMN comment TEXT').catchError((e) => debugPrint('Column comment already exists'));
      await db.execute('ALTER TABLE notations ADD COLUMN updatedAt TEXT').catchError((e) => debugPrint('Column updatedAt already exists'));
    }

    if (oldVersion < 4) {
      // Add indexes for better performance
      await db.execute('CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_students_matricule ON students(matricule)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_students_userId ON students(userId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_lecturers_userId ON lecturers(userId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_projects_studentId ON projects(studentId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_senderId ON messages(senderId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_receiverId ON messages(receiverId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_notifications_userId ON notifications(userId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_notifications_isRead ON notifications(isRead)');

      // Add onboarding step tracking
      await db.execute('ALTER TABLE onboarding_status ADD COLUMN currentStep INTEGER DEFAULT 0').catchError((e) => debugPrint('Column currentStep already exists'));
    }

    // Version 5: Nouvelles tables pour les groupes, interactions et paramètres
    if (oldVersion < 5) {
      // Table des groupes
      await db.execute('''
        CREATE TABLE IF NOT EXISTS groups (
          groupId TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          createdBy TEXT NOT NULL,
          type TEXT NOT NULL,
          courseName TEXT,
          academicYear TEXT,
          section TEXT,
          members TEXT,
          projects TEXT,
          evaluationCriteria TEXT,
          maxMembers INTEGER DEFAULT 10,
          isOpen INTEGER DEFAULT 0,
          createdAt TEXT NOT NULL,
          updatedAt TEXT,
          FOREIGN KEY (createdBy) REFERENCES users (userId) ON DELETE CASCADE
        )
      ''');

      // Table des interactions (likes et reviews fusionnés)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS interactions (
          interactionId TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          projectId TEXT NOT NULL,
          type TEXT NOT NULL,
          reviewText TEXT,
          rating REAL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT,
          FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE,
          FOREIGN KEY (projectId) REFERENCES projects (projectId) ON DELETE CASCADE
        )
      ''');

      // Table des commentaires
      await db.execute('''
        CREATE TABLE IF NOT EXISTS comments (
          commentId TEXT PRIMARY KEY,
          projectId TEXT NOT NULL,
          userId TEXT NOT NULL,
          userFullName TEXT NOT NULL,
          content TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (projectId) REFERENCES projects (projectId) ON DELETE CASCADE,
          FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE
        )
      ''');

      // Table des paramètres de profil
      await db.execute('''
        CREATE TABLE IF NOT EXISTS profile_settings (
          userId TEXT PRIMARY KEY,
          theme TEXT DEFAULT 'system',
          language TEXT DEFAULT 'french',
          notificationsEnabled INTEGER DEFAULT 1,
          emailNotifications INTEGER DEFAULT 1,
          projectUpdates INTEGER DEFAULT 1,
          groupInvitations INTEGER DEFAULT 1,
          commentReplies INTEGER DEFAULT 1,
          likesNotifications INTEGER DEFAULT 0,
          privacyMode INTEGER DEFAULT 0,
          showEmail INTEGER DEFAULT 1,
          showPhone INTEGER DEFAULT 0,
          allowCollaboration INTEGER DEFAULT 1,
          lastUpdated TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE
        )
      ''');

      // Table des demandes de collaboration
      await db.execute('''
        CREATE TABLE IF NOT EXISTS collaboration_requests (
          requestId TEXT PRIMARY KEY,
          fromUserId TEXT NOT NULL,
          toUserId TEXT NOT NULL,
          projectId TEXT NOT NULL,
          message TEXT,
          status TEXT DEFAULT 'pending',
          createdAt TEXT NOT NULL,
          respondedAt TEXT,
          FOREIGN KEY (fromUserId) REFERENCES users (userId) ON DELETE CASCADE,
          FOREIGN KEY (toUserId) REFERENCES users (userId) ON DELETE CASCADE,
          FOREIGN KEY (projectId) REFERENCES projects (projectId) ON DELETE CASCADE
        )
      ''');

      debugPrint('✅ Added new tables for version 5');
    }

    debugPrint('✅ Database upgrade completed successfully');
  }

  Future<void> _renameTableIfExists(Database db, String oldName, String newName) async {
    try {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [oldName],
      );

      if (tables.isNotEmpty) {
        await db.execute('ALTER TABLE $oldName RENAME TO $newName');
        debugPrint('✅ Renamed table $oldName to $newName');
      }
    } catch (e) {
      debugPrint('⚠️ Could not rename table $oldName: $e');
    }
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  Future<void> clearAllTables() async {
    final db = await database;
    final tables = [
      'survey_responses',
      'surveys',
      'onboarding_status',
      'notations',
      'cards',
      'notifications',
      'stories',
      'reviews',
      'messages',
      'project_history',
      'project_favorites',
      'project_images',
      'projects',
      'lecturers',
      'students',
      'users',
    ];

    for (final table in tables) {
      await db.delete(table);
    }
    debugPrint('🗑️ All tables cleared');
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'campuswork.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
    debugPrint('🗑️ Database deleted');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      debugPrint('🔒 Database closed');
    }
  }

  // Get database info
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;
    final version = await db.getVersion();
    final path = db.path;

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
    );

    return {
      'version': version,
      'path': path,
      'tables': tables.map((t) => t['name']).toList(),
    };
  }
}
