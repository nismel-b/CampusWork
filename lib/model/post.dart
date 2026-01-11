enum PostType { help, idea, announcement, question }
enum PostStatus { active, archived, resolved }

class Post {
  final String id;
  final String userId;
  final String userFullName;
  final String title;
  final String content;
  final PostType type;
  final PostStatus status;
  final String? projectId; // Lié à un projet spécifique (optionnel)
  final String? courseName;
  final List<String> tags;
  final List<String> attachments; // URLs des fichiers attachés
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.title,
    required this.content,
    required this.type,
    this.status = PostStatus.active,
    this.projectId,
    this.courseName,
    this.tags = const [],
    this.attachments = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userFullName: json['userFullName'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: PostType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => PostType.question,
      ),
      status: PostStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PostStatus.active,
      ),
      projectId: json['projectId'] as String?,
      courseName: json['courseName'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      attachments: List<String>.from(json['attachments'] ?? []),
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      viewsCount: json['viewsCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userFullName': userFullName,
      'title': title,
      'content': content,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'projectId': projectId,
      'courseName': courseName,
      'tags': tags,
      'attachments': attachments,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'viewsCount': viewsCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? userFullName,
    String? title,
    String? content,
    PostType? type,
    PostStatus? status,
    String? projectId,
    String? courseName,
    List<String>? tags,
    List<String>? attachments,
    int? likesCount,
    int? commentsCount,
    int? viewsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userFullName: userFullName ?? this.userFullName,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      courseName: courseName ?? this.courseName,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case PostType.help:
        return 'Demande d\'aide';
      case PostType.idea:
        return 'Idée de projet';
      case PostType.announcement:
        return 'Annonce';
      case PostType.question:
        return 'Question';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case PostStatus.active:
        return 'Actif';
      case PostStatus.archived:
        return 'Archivé';
      case PostStatus.resolved:
        return 'Résolu';
    }
  }
}