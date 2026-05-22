import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';
import '../data/app_constants.dart';

class ReviewProvider extends ChangeNotifier {
  final Map<String, List<Review>> _reviews = {};
  ReviewProvider() {
    _initializeReviews();
  }

  Future<void> _initializeReviews() async {
    await _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reviewsJsonStr = prefs.getString('all_food_reviews');
      if (reviewsJsonStr != null) {
        final Map<String, dynamic> decoded = json.decode(reviewsJsonStr);
        _reviews.clear();
        decoded.forEach((foodId, reviewsListJson) {
          if (reviewsListJson is List) {
            _reviews[foodId] = reviewsListJson
                .map((rMap) => Review.fromMap(rMap as Map<String, dynamic>))
                .toList();
          }
        });
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading reviews: $e');
    }
  }

  Future<void> _saveReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> mapToEncode = {};
      _reviews.forEach((foodId, reviewsList) {
        mapToEncode[foodId] = reviewsList.map((r) => r.toMap()).toList();
      });
      await prefs.setString('all_food_reviews', json.encode(mapToEncode));
    } catch (e) {
      debugPrint('Error saving reviews: $e');
    }
  }

  List<Review> getReviews(String foodItemId) {
    return _reviews[foodItemId] ?? [];
  }

  int getReviewCount(String foodItemId) {
    return _reviews[foodItemId]?.length ?? 0;
  }

  double getAverageRating(String foodItemId) {
    final reviews = _reviews[foodItemId];
    if (reviews == null || reviews.isEmpty) return 0.0;
    final total = reviews.fold<double>(0, (sum, r) => sum + r.rating);
    return double.parse((total / reviews.length).toStringAsFixed(1));
  }

  Future<void> addReview({
    required String foodItemId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    final clampedRating =
        rating.clamp(AppConstants.minRating, AppConstants.maxRating);

    String trimmedComment = comment.trim();
    if (trimmedComment.length > AppConstants.maxReviewLength) {
      trimmedComment =
          trimmedComment.substring(0, AppConstants.maxReviewLength);
    }

    final review = Review(
      id: '${foodItemId}_${DateTime.now().millisecondsSinceEpoch}',
      foodItemId: foodItemId,
      userId: userId,
      userName: userName,
      rating: clampedRating,
      comment: trimmedComment,
      dateTime: DateTime.now(),
    );

    _reviews.putIfAbsent(foodItemId, () => []);
    _reviews[foodItemId]!.insert(0, review);
    await _saveReviews();
    notifyListeners();
  }

  bool hasUserReviewed(String foodItemId, String userId) {
    final reviews = _reviews[foodItemId];
    if (reviews == null || userId.isEmpty) return false;
    return reviews.any((r) => r.userId == userId);
  }
}
