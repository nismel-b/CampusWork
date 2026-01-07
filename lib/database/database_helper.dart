import 'package:flutter/foundation.dart' show debugPrint;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('store_buy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Updated version for new columns
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {

    // Table Users
    await db.execute('''
      CREATE TABLE user (
        userId TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        firstname TEXT NOT NULL,
        lastname TEXT UNIQUE NOT NULL,
        email TEXT,
        phonenumber TEXT NOT NULL,
        password TEXT NOT NULL,
        userRole TEXT NOT NULL,
        isApproved INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
      )
    ''');

    // Table Project
    await db.execute('''
      CREATE TABLE project (
        projectId TEXT PRIMARY KEY,
        studentId TEXT NOT NULL,
        projectName TEXT NOT NULL,
        courseName TEXT,
        description TEXT NOT NULL,
        category TEXT,
        imageurl TEXT,
        collaborators TEXT,
        architecturePatterns TEXT,
        uml TEXT,
        prototypeLink TEXT,
        downloadLink TEXT,
        status TEXT,
        ressources TEXT,
        prerequisites TEXT,
        powerpointLink TEXT,
        reportLink TEXT,
        state TEXT,
        grade DOUBLE ,
        lecturerComment TEXT,
        likesCount INTEGER DEFAULT 1,
        commentsCount INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES user (userId)
      )
    ''');

    // Table lecturer
    await db.execute('''
      CREATE TABLE lecturer (
        lecturerId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        uniteDenseignement TEXT NOT NULL,
        section TEXT NOT NULL,
        evaluationGrid TEXT,
        validationRequirements TEXT,
        finalSubmissionRequirements TEXT,
        FOREIGN KEY (userId) REFERENCES user (userId),
      )
    ''');

    // Table Student
    await db.execute('''
      CREATE TABLE student (
        studentId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        matricule TEXT NOT NULL,
        birthday TEXT,
        level TEXT NOT NULL,
        semester TEXT NOT NULL, 
        section TEXT NOT NULL,
        filiere TEXT NOT NULL,
        academicYear TEXT NOT NULL, 
        githubLink TEXT,
        linkedinLink TEXT,
        otherLink TEXT,
        FOREIGN KEY (userId) REFERENCES user (userId),
        FOREIGN KEY (projectId) REFERENCES project (projectId)
      )
    ''');

    // Table Projects Favorites
    await db.execute('''
      CREATE TABLE project_favorites (
        favoriteId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        projectId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES user (userId),
        FOREIGN KEY (projectId) REFERENCES project (projectId),
        UNIQUE(userId, projectId)
      )
    ''');

    // Table Messages
    await db.execute('''
      CREATE TABLE messages (
        messageId TEXT PRIMARY KEY,
        senderId TEXT NOT NULL,
        receiverId TEXT NOT NULL,
        content TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        synced INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (senderId) REFERENCES user (userId),
        FOREIGN KEY (receiverId) REFERENCES user (userId)
      )
    ''');

    // Table Reviews
    await db.execute('''
      CREATE TABLE reviews (
        reviewId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        projectId TEXT NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES user (userId),
        FOREIGN KEY (projectId) REFERENCES project (projectId)
      )
    ''');

    // Table Stories
    await db.execute('''
      CREATE TABLE stories (
        storyId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        projectId TEXT,
        createdAt TEXT NOT NULL,
        expiresAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES user (userId),
        FOREIGN KEY (projectId) REFERENCES project (projectId)
      )
    ''');

    // Table Notifications
    await db.execute('''
      CREATE TABLE notification (
        notificationId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        projectId TEXT,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        relatedAt TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES user (userId),
        FOREIGN KEY (projectId) REFERENCES project (projectId)
      )
    ''');

    // Table ProjectHistory
    await db.execute('''
      CREATE TABLE projet_history (
        historyId TEXT PRIMARY KEY,
        projectId TEXT NOT NULL,
        action TEXT NOT NULL,
        details TEXT,
        userId TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (projectId) REFERENCES project (projectId),
        FOREIGN KEY (userId) REFERENCES user (userId)
      )
    ''');


    // Table Card
    await db.execute('''
      CREATE TABLE card (
        cardId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        projectId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES user (userId),
        FOREIGN KEY (projectId) REFERENCES project (projectId)
      )
    ''');

    // Table notation
    await db.execute('''
      CREATE TABLE notation(
        notatiobId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        lecturerId TEXT NOT NULL,
        priority INTEGER DEFAULT 0,
        status TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES user (userId),
        FOREIGN KEY (projectId) REFERENCES project (projectId)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new tables for version 2
      await db.execute('''
        CREATE TABLE projet_history (
        historyId TEXT PRIMARY KEY,
        projectId TEXT NOT NULL,
        action TEXT NOT NULL,
        details TEXT,
        userId TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (projectId) REFERENCES project (projectId),
        FOREIGN KEY (userId) REFERENCES user (userId)
      )
      ''');

      // Update stories table to add new columns
      await db.execute('''
        ALTER TABLE stories ADD COLUMN type TEXT DEFAULT 'announcement'
      ''').catchError((e) {
        // Column might already exist
      });

      await db.execute('''
        ALTER TABLE stories ADD COLUMN title TEXT
      ''').catchError((e) {});

      await db.execute('''
        ALTER TABLE stories ADD COLUMN description TEXT
      ''').catchError((e) {});

      await db.execute('''
        ALTER TABLE stories ADD COLUMN projectId TEXT
      ''').catchError((e) {});

      // Add isRead and synced columns to messages table
      await db.execute('''
        ALTER TABLE messages ADD COLUMN isRead INTEGER DEFAULT 0
      ''').catchError((e) {});

      await db.execute('''
        ALTER TABLE messages ADD COLUMN synced INTEGER DEFAULT 0
      ''').catchError((e) {});

      // Add update column to orders table
      await db.execute('''
        ALTER TABLE project ADD COLUMN updatedAt TEXT
      ''').catchError((e) {});

      // Table projects Photos
      await db.execute('''
        CREATE TABLE IF NOT EXISTS project_image (
          imageId TEXT PRIMARY KEY,
          projectId TEXT NOT NULL,
          imageurl TEXT NOT NULL,
          description TEXT,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (projectId) REFERENCES project (projectId)
        )
      ''').catchError((e) {});

      // Table Surveys
      await db.execute('''
        CREATE TABLE IF NOT EXISTS surveys (
          surveyId TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          question TEXT NOT NULL,
          type TEXT NOT NULL,
          options TEXT,
          createdAt TEXT NOT NULL,
          expiresAt TEXT,
          FOREIGN KEY (userId) REFERENCES user (userId)
        )
      ''').catchError((e) {});

      // Table Survey Responses
      await db.execute('''
        CREATE TABLE IF NOT EXISTS survey_responses (
          responseId TEXT PRIMARY KEY,
          surveyId TEXT NOT NULL,
          userId TEXT NOT NULL,
          answer TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (surveyId) REFERENCES surveys (surveyId),
          FOREIGN KEY (userId) REFERENCES user (userId),
          UNIQUE(surveyId, userId)
        )
      ''').catchError((e) {});

      // Table Onboarding Status
      await db.execute('''
        CREATE TABLE IF NOT EXISTS onboarding_status (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL,
          completed INTEGER DEFAULT 0,
          FOREIGN KEY (userId) REFERENCES user (userId)
        )
      ''').catchError((e) {});
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

