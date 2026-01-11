enum NotificationType { like, comment, evaluation, approval, projectUpdate, message_, }

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

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      notificationId: json['notificationId'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.projectUpdate,
      ),
      isRead: json['isRead'] as bool? ?? false,
      relatedId: json['relatedId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'isRead': isRead,
      'relatedId': relatedId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    String? relatedId,
    DateTime? createdAt,
  }) {
    return AppNotification(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
