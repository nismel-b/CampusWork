class Review {
  final String reviewId;
  final String projectId;
  final String userId;
  final DateTime createdAt;
  final int rating;
  final String? comment;

  Review({
    required this.reviewId,
    required this.projectId,
    required this.userId,
    required this.createdAt,
    required this.rating,
    this.comment,
  });

}