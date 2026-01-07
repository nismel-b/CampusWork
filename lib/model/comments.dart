class Comment {
  final String id;
  final String projectId;
  final String userId;
  final String userFullName;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.userFullName,
    required this.content,
    required this.createdAt,
  });

}
