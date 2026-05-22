class Review {
  final String id;
  final String foodItemId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime dateTime;

  const Review({
    required this.id,
    required this.foodItemId,
    this.userId = '',
    required this.userName,
    required this.rating,
    required this.comment,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodItemId': foodItemId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      foodItemId: map['foodItemId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      dateTime: DateTime.tryParse(map['dateTime'] ?? '') ?? DateTime.now(),
    );
  }

  Review copyWith({
    String? id,
    String? foodItemId,
    String? userId,
    String? userName,
    double? rating,
    String? comment,
    DateTime? dateTime,
  }) {
    return Review(
      id: id ?? this.id,
      foodItemId: foodItemId ?? this.foodItemId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7)
      return 'Il y a ${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}';
    if (diff.inDays < 30)
      return 'Il y a ${(diff.inDays / 7).floor()} semaine${(diff.inDays / 7).floor() > 1 ? 's' : ''}';
    return 'Il y a ${(diff.inDays / 30).floor()} mois';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review &&
        other.id == id &&
        other.foodItemId == foodItemId &&
        other.userId == userId &&
        other.userName == userName &&
        other.rating == rating &&
        other.comment == comment &&
        other.dateTime == dateTime;
  }

  @override
  int get hashCode {
    return Object.hash(
        id, foodItemId, userId, userName, rating, comment, dateTime);
  }

  @override
  String toString() {
    return 'Review(id: $id, foodItemId: $foodItemId, userId: $userId, userName: $userName, rating: $rating)';
  }
}
