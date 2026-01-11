class Comment {
  final String? commentId;
  final String projectId;
  final String userId;
  final String userFullName;
  final String content;
  final DateTime createdAt;

  Comment({
    this.commentId,
    required this.projectId,
    required this.userId,
    required this.userFullName,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'projectId': projectId,
      'userId': userId,
      'userFullName': userFullName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      commentId: map['commentId'],
      projectId: map['projectId'] ?? '',
      userId: map['userId'] ?? '',
      userFullName: map['userFullName'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}