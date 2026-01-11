enum InteractionType { like, review }

class Interaction {
  final String? interactionId;
  final String userId;
  final String projectId;
  final InteractionType type;
  final String? reviewText;
  final double? rating; // Pour les reviews (1-5 étoiles)
  final DateTime createdAt;
  final DateTime? updatedAt;

  Interaction({
    this.interactionId,
    required this.userId,
    required this.projectId,
    required this.type,
    this.reviewText,
    this.rating,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory pour créer un like
  factory Interaction.like({
    required String userId,
    required String projectId,
    String? interactionId,
  }) {
    return Interaction(
      interactionId: interactionId,
      userId: userId,
      projectId: projectId,
      type: InteractionType.like,
      createdAt: DateTime.now(),
    );
  }

  // Factory pour créer une review
  factory Interaction.review({
    required String userId,
    required String projectId,
    required String reviewText,
    required double rating,
    String? interactionId,
  }) {
    return Interaction(
      interactionId: interactionId,
      userId: userId,
      projectId: projectId,
      type: InteractionType.review,
      reviewText: reviewText,
      rating: rating,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'interactionId': interactionId,
      'userId': userId,
      'projectId': projectId,
      'type': type.toString().split('.').last,
      'reviewText': reviewText,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Interaction.fromMap(Map<String, dynamic> map) {
    return Interaction(
      interactionId: map['interactionId'],
      userId: map['userId'] ?? '',
      projectId: map['projectId'] ?? '',
      type: InteractionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => InteractionType.like,
      ),
      reviewText: map['reviewText'],
      rating: map['rating']?.toDouble(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  bool get isLike => type == InteractionType.like;
  bool get isReview => type == InteractionType.review;

  Interaction copyWith({
    String? interactionId,
    String? userId,
    String? projectId,
    InteractionType? type,
    String? reviewText,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Interaction(
      interactionId: interactionId ?? this.interactionId,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      type: type ?? this.type,
      reviewText: reviewText ?? this.reviewText,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}