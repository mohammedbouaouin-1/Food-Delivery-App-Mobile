import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/food_item.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  String? _currentUserId;
  
  CartProvider() {
    _initializeCart();
  }
  
  
  void _initializeCart() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      final newUserId = user?.uid;
      
      // Si l'utilisateur change, recharger le panier
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        _items.clear();
        if (_currentUserId != null) {
          _loadCart();
        } else {
          notifyListeners();
        }
      }
    });
    
    
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (_currentUserId != null) {
      _loadCart();
    }
  }
  
  // Obtenir la clé de stockage unique par utilisateur
  String get _cartKey {
    if (_currentUserId == null) {
      return 'cart_items_guest'; 
    }
    return 'cart_items_$_currentUserId';
  }
  
  List<CartItem> get items => [..._items];
  
  int get itemCount => _items.length;
  
  int get totalItemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }
  
  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
  
  int get totalCalories {
    return _items.fold(0, (sum, item) => sum + item.totalCalories);
  }
  
  bool get isEmpty => _items.isEmpty;
  
  bool get isNotEmpty => _items.isNotEmpty;
  
  // Vérifier si un article est dans le panier
  bool isInCart(String foodId) {
    return _items.any((item) => item.foodItem.id == foodId);
  }
  
  
  int getItemQuantity(String foodId) {
    try {
      final item = _items.firstWhere((item) => item.foodItem.id == foodId);
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }
  
  // Ajouter un article
  Future<void> addItem(FoodItem foodItem, {String? specialInstructions}) async {
    try {
      final existingItem = _items.firstWhere(
        (item) => item.foodItem.id == foodItem.id,
      );
      existingItem.increaseQuantity();
    } catch (e) {
      _items.add(CartItem(
        foodItem: foodItem,
        specialInstructions: specialInstructions,
      ));
    }
    await _saveCart();
    notifyListeners();
  }
  
  // Augmenter la quantité
  Future<void> increaseQuantity(String foodId) async {
    try {
      final item = _items.firstWhere((item) => item.foodItem.id == foodId);
      item.increaseQuantity();
      await _saveCart();
      notifyListeners();
    } catch (e) {
      debugPrint('Item not found: $foodId');
    }
  }
  

  Future<void> decreaseQuantity(String foodId) async {
    try {
      final item = _items.firstWhere((item) => item.foodItem.id == foodId);
      
      if (item.quantity > 1) {
        item.decreaseQuantity();
      } else {
        _items.remove(item);
      }
      
      await _saveCart();
      notifyListeners();
    } catch (e) {
      debugPrint('Item not found: $foodId');
    }
  }
  

  Future<void> removeItem(String foodId) async {
    _items.removeWhere((item) => item.foodItem.id == foodId);
    await _saveCart();
    notifyListeners();
  }
  
  
  Future<void> updateSpecialInstructions(String foodId, String instructions) async {
    try {
      final index = _items.indexWhere((item) => item.foodItem.id == foodId);
      if (index != -1) {
        _items[index] = _items[index].copyWith(specialInstructions: instructions);
        await _saveCart();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating instructions: $e');
    }
  }
  
  // Vider le panier
  Future<void> clearCart() async {
    _items.clear();
    await _saveCart();
    notifyListeners();
  }
  
  
  double getSubtotal() => totalPrice;
  
  
  double getDeliveryFee() => 5.0;
  
  
  double getTotalWithDelivery() => totalPrice + getDeliveryFee();
  
  // Sauvegarder le panier localement 
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = _items.map((item) => item.toMap()).toList();
      await prefs.setString(_cartKey, json.encode(cartData));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }
  
  // Charger le panier depuis le stockage local 
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString(_cartKey);
      
      if (cartString != null) {
        final List<dynamic> cartData = json.decode(cartString);
        _items = cartData.map((item) => CartItem.fromMap(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
      _items = [];
    }
  }
  
  // résumé du panier
  Map<String, dynamic> getCartSummary() {
    return {
      'itemCount': itemCount,
      'totalItems': totalItemCount,
      'subtotal': totalPrice,
      'deliveryFee': getDeliveryFee(),
      'total': getTotalWithDelivery(),
      'calories': totalCalories,
    };
  }
}