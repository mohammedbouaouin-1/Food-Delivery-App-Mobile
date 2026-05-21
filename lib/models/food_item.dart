import '../data/app_constants.dart';

class FoodItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final String description;
  final String category;
  final List<String> ingredients;
  final int preparationTime;
  final double rating;
  final int reviewCount;
  final bool isVegetarian;
  final bool isSpicy;
  final int calories;

  const FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    this.category = '',
    this.ingredients = const [],
    this.preparationTime = 20,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.isVegetarian = false,
    this.isSpicy = false,
    this.calories = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'description': description,
      'category': category,
      'ingredients': ingredients,
      'preparationTime': preparationTime,
      'rating': rating,
      'reviewCount': reviewCount,
      'isVegetarian': isVegetarian,
      'isSpicy': isSpicy,
      'calories': calories,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      preparationTime: map['preparationTime'] ?? 20,
      rating: (map['rating'] ?? 4.5).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isVegetarian: map['isVegetarian'] ?? false,
      isSpicy: map['isSpicy'] ?? false,
      calories: map['calories'] ?? 0,
    );
  }

  FoodItem copyWith({
    String? id,
    String? name,
    double? price,
    String? image,
    String? description,
    String? category,
    List<String>? ingredients,
    int? preparationTime,
    double? rating,
    int? reviewCount,
    bool? isVegetarian,
    bool? isSpicy,
    int? calories,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      description: description ?? this.description,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      preparationTime: preparationTime ?? this.preparationTime,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isSpicy: isSpicy ?? this.isSpicy,
      calories: calories ?? this.calories,
    );
  }

  String get formattedPrice => '${price.toStringAsFixed(2)} ${AppConstants.currency}';

  List<String> get badges {
    List<String> result = [];
    if (isVegetarian) result.add('🌱 Végétarien');
    if (isSpicy) result.add('🌶️ Épicé');
    if (rating >= AppConstants.excellentRatingThreshold) result.add('⭐ Top');
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FoodItem(id: $id, name: $name, price: $price, category: $category, rating: $rating)';
  }
}