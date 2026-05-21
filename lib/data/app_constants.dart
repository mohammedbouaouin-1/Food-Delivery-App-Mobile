class AppConstants {
  static const String appName = 'Food Delivery';
  static const String currency = 'MAD';
  static const double deliveryFee = 5.0;
  static const int maxQuantity = 20;
  static const int loyaltySilverThreshold = 500;
  static const int loyaltyGoldThreshold = 1500;
  static const double freeDeliveryThreshold = 100.0;
  static const int maxReviewLength = 500;
  static const double maxRating = 5.0;
  static const double minRating = 0.0;

  // Rating badge thresholds
  static const double excellentRatingThreshold = 4.5;
  static const double goodRatingThreshold = 3.5;
  static const double averageRatingThreshold = 2.5;

  static String ratingLabel(double rating) {
    if (rating >= excellentRatingThreshold) return 'Excellent';
    if (rating >= goodRatingThreshold) return 'Très bien';
    if (rating >= averageRatingThreshold) return 'Bien';
    return 'Moyen';
  }
}
