enum NotificationType { like, comment, evaluation, approval, projectUpdate }

class AppNotification {
  final String notificationId;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final String? relatedId;
  final DateTime createdAt;

  AppNotification({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.relatedId,
    required this.createdAt,
  });
}
