enum CollaborationStatus { pending, accepted, rejected }

class CollaborationRequest {
  final String requestId;
  final String fromUserId;
  final String toUserId;
  final String projectId;
  final String? message;
  final CollaborationStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  CollaborationRequest({
    required this.requestId,
    required this.fromUserId,
    required this.toUserId,
    required this.projectId,
    this.message,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'projectId': projectId,
      'message': message,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  factory CollaborationRequest.fromMap(Map<String, dynamic> map) {
    return CollaborationRequest(
      requestId: map['requestId'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      projectId: map['projectId'] ?? '',
      message: map['message'],
      status: CollaborationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => CollaborationStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      respondedAt: map['respondedAt'] != null ? DateTime.parse(map['respondedAt']) : null,
    );
  }

  CollaborationRequest copyWith({
    String? requestId,
    String? fromUserId,
    String? toUserId,
    String? projectId,
    String? message,
    CollaborationStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return CollaborationRequest(
      requestId: requestId ?? this.requestId,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      projectId: projectId ?? this.projectId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  bool get isPending => status == CollaborationStatus.pending;
  bool get isAccepted => status == CollaborationStatus.accepted;
  bool get isRejected => status == CollaborationStatus.rejected;
}