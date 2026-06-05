class ReviewModel {
  final String id;
  final String orderId;
  final String userId;
  final String providerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.providerId,
    required this.rating,
    this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'orderId': orderId,
        'userId': userId,
        'providerId': providerId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt,
      };

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) =>
      ReviewModel(
        id: id,
        orderId: map['orderId'] as String,
        userId: map['userId'] as String,
        providerId: map['providerId'] as String,
        rating: (map['rating'] as num).toInt(),
        comment: map['comment'] as String?,
        createdAt: map['createdAt'] != null
            ? (map['createdAt'] is DateTime
                ? map['createdAt'] as DateTime
                : (map['createdAt'] as dynamic).toDate())
            : DateTime.now(),
      );
}
