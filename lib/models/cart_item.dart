import 'food_item.dart';

class CartItem {
  final FoodItem foodItem;
  int quantity;
  final String? specialInstructions;
  final DateTime addedAt;
  
  CartItem({
    required this.foodItem,
    this.quantity = 1,
    this.specialInstructions,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
  


  double get totalPrice => foodItem.price * quantity;
  
 

  int get totalCalories => foodItem.calories * quantity;
  


  void increaseQuantity() {
    quantity++;
  }
  
 

  void decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }
  
 

  bool get canDecrease => quantity > 1;
  
  

  Map<String, dynamic> toMap() {
    return {
      'foodItem': foodItem.toMap(),
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'addedAt': addedAt.toIso8601String(),
    };
  }
  


  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      foodItem: FoodItem.fromMap(map['foodItem']),
      quantity: map['quantity'] ?? 1,
      specialInstructions: map['specialInstructions'],
      addedAt: map['addedAt'] != null 
          ? DateTime.parse(map['addedAt']) 
          : DateTime.now(),
    );
  }
  
 
 
  CartItem copyWith({
    FoodItem? foodItem,
    int? quantity,
    String? specialInstructions,
    DateTime? addedAt,
  }) {
    return CartItem(
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      addedAt: addedAt ?? this.addedAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.foodItem.id == foodItem.id;
  }
  
  @override
  int get hashCode => foodItem.id.hashCode;
}