enum ProjectStatus { private, public }
enum ProjectState { enCours, termine, note }

class Project {
  final String? projectId; // Changé de 'id' à 'projectId' pour correspondre à la DB
  final String projectName;
  final String courseName;
  final String description;
  final String? category;
  final String? imageUrl; // Changé de 'imageurl' à 'imageUrl'
  final String userId; // Changé de 'studentId' à 'userId' pour correspondre à la DB
  final List<String> collaborators;
  final String? architecturePatterns;
  final String? uml;
  final String? prototypeLink;
  final String? downloadLink;
  final ProjectStatus status;
  final List<String> resources;
  final List<String> prerequisites;
  final String? powerpointLink;
  final String? reportLink;
  final String state; // Changé en String pour correspondre à la DB
  final String? grade; // Changé en String pour correspondre à la DB
  final String? lecturerComment;
  final int likesCount;
  final int commentsCount;
  final String? createdAt; // Changé en String pour correspondre à la DB
  final String? updatedAt; // Changé en String pour correspondre à la DB

  Project({
    this.projectId,
    required this.projectName,
    required this.courseName,
    required this.description,
    required this.userId,
    this.imageUrl,
    this.category,
    this.collaborators = const [],
    this.architecturePatterns,
    this.uml,
    this.prototypeLink,
    this.downloadLink,
    this.status = ProjectStatus.public,
    this.resources = const [],
    this.prerequisites = const [],
    this.powerpointLink,
    this.reportLink,
    this.state = 'enCours',
    this.grade,
    this.lecturerComment,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  // Factory pour créer un Project depuis les données de la base de données
  factory Project.fromDatabase(Map<String, dynamic> dbData) {
    return Project(
      projectId: dbData['project_id'] as String?,
      projectName: dbData['project_name'] as String? ?? '',
      courseName: dbData['course_name'] as String? ?? '',
      description: dbData['description'] as String? ?? '',
      userId: dbData['user_id'] as String? ?? '',
      imageUrl: dbData['image_url'] as String?,
      category: dbData['category'] as String?,
      collaborators: _parseStringList(dbData['collaborators']),
      architecturePatterns: dbData['architecture_patterns'] as String?,
      uml: dbData['uml'] as String?,
      prototypeLink: dbData['prototype_link'] as String?,
      downloadLink: dbData['download_link'] as String?,
      status: _parseProjectStatus(dbData['status']),
      resources: _parseStringList(dbData['resources']),
      prerequisites: _parseStringList(dbData['prerequisites']),
      powerpointLink: dbData['powerpoint_link'] as String?,
      reportLink: dbData['report_link'] as String?,
      state: dbData['state'] as String? ?? 'enCours',
      grade: dbData['grade'] as String?,
      lecturerComment: dbData['lecturer_comment'] as String?,
      likesCount: dbData['likes_count'] as int? ?? 0,
      commentsCount: dbData['comments_count'] as int? ?? 0,
      createdAt: dbData['created_at'] as String?,
      updatedAt: dbData['updated_at'] as String?,
    );
  }

  // Factory pour créer un Project depuis JSON (API)
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['projectId'] as String?,
      projectName: json['projectName'] as String? ?? '',
      courseName: json['courseName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String?,
      collaborators: List<String>.from(json['collaborators'] ?? []),
      architecturePatterns: json['architecturePatterns'] as String?,
      uml: json['uml'] as String?,
      prototypeLink: json['prototypeLink'] as String?,
      downloadLink: json['downloadLink'] as String?,
      status: ProjectStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ProjectStatus.public,
      ),
      resources: List<String>.from(json['resources'] ?? []),
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      powerpointLink: json['powerpointLink'] as String?,
      reportLink: json['reportLink'] as String?,
      state: json['state'] as String? ?? 'enCours',
      grade: json['grade'] as String?,
      lecturerComment: json['lecturerComment'] as String?,
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  // Méthode fromMap pour compatibilité (délègue à fromDatabase)
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project.fromDatabase(map);
  }

  // Convertir en Map pour la base de données
  Map<String, dynamic> toDatabase() {
    return {
      'project_id': projectId,
      'project_name': projectName,
      'course_name': courseName,
      'description': description,
      'user_id': userId,
      'image_url': imageUrl,
      'category': category,
      'collaborators': collaborators.join(','),
      'architecture_patterns': architecturePatterns,
      'uml': uml,
      'prototype_link': prototypeLink,
      'download_link': downloadLink,
      'status': status.toString().split('.').last,
      'resources': resources.join(','),
      'prerequisites': prerequisites.join(','),
      'powerpoint_link': powerpointLink,
      'report_link': reportLink,
      'state': state,
      'grade': grade,
      'lecturer_comment': lecturerComment,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'projectName': projectName,
      'courseName': courseName,
      'description': description,
      'userId': userId,
      'imageUrl': imageUrl,
      'category': category,
      'collaborators': collaborators,
      'architecturePatterns': architecturePatterns,
      'uml': uml,
      'prototypeLink': prototypeLink,
      'downloadLink': downloadLink,
      'status': status.toString().split('.').last,
      'resources': resources,
      'prerequisites': prerequisites,
      'powerpointLink': powerpointLink,
      'reportLink': reportLink,
      'state': state,
      'grade': grade,
      'lecturerComment': lecturerComment,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Méthodes utilitaires privées
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is String) {
      return value.isEmpty ? [] : value.split(',').map((e) => e.trim()).toList();
    }
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static ProjectStatus _parseProjectStatus(dynamic value) {
    if (value == null) return ProjectStatus.public;
    if (value is String) {
      return ProjectStatus.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => ProjectStatus.public,
      );
    }
    return ProjectStatus.public;
  }

  Project copyWith({
    String? projectId,
    String? projectName,
    String? courseName,
    String? description,
    String? userId,
    String? imageUrl,
    String? category,
    List<String>? collaborators,
    String? architecturePatterns,
    String? uml,
    String? prototypeLink,
    String? downloadLink,
    ProjectStatus? status,
    List<String>? resources,
    List<String>? prerequisites,
    String? powerpointLink,
    String? reportLink,
    String? state,
    String? grade,
    String? lecturerComment,
    int? likesCount,
    int? commentsCount,
    String? createdAt,
    String? updatedAt,
  }) {
    return Project(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      courseName: courseName ?? this.courseName,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      collaborators: collaborators ?? this.collaborators,
      architecturePatterns: architecturePatterns ?? this.architecturePatterns,
      uml: uml ?? this.uml,
      prototypeLink: prototypeLink ?? this.prototypeLink,
      downloadLink: downloadLink ?? this.downloadLink,
      status: status ?? this.status,
      resources: resources ?? this.resources,
      prerequisites: prerequisites ?? this.prerequisites,
      powerpointLink: powerpointLink ?? this.powerpointLink,
      reportLink: reportLink ?? this.reportLink,
      state: state ?? this.state,
      grade: grade ?? this.grade,
      lecturerComment: lecturerComment ?? this.lecturerComment,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
