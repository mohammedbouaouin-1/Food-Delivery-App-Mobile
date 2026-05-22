import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/food_item.dart';
import '../models/cart_item.dart';
import '../data/app_constants.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  String? _currentUserId;
  StreamSubscription<User?>? _authSubscription;

  CartProvider() {
    _initializeCart();
  }

  void _initializeCart() {
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      final newUserId = user?.uid;

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

  bool isInCart(String foodId) {
    return _items.any((item) => item.foodItem.id == foodId);
  }

  int getItemQuantity(String foodId) {
    final index = _items.indexWhere((item) => item.foodItem.id == foodId);
    if (index != -1) {
      return _items[index].quantity;
    }
    return 0;
  }

  Future<void> addItem(FoodItem foodItem, {String? specialInstructions}) async {
    final index = _items.indexWhere((item) => item.foodItem.id == foodItem.id);
    if (index != -1) {
      _items[index].increaseQuantity();
    } else {
      _items.add(CartItem(
        foodItem: foodItem,
        specialInstructions: specialInstructions,
      ));
    }
    await _saveCart();
    notifyListeners();
  }

  Future<void> restoreCartItem(CartItem item) async {
    _items.add(item);
    await _saveCart();
    notifyListeners();
  }

  Future<void> addItemsBatch(List<CartItem> itemsToCopy) async {
    for (var item in itemsToCopy) {
      final index = _items.indexWhere(
          (itemInCart) => itemInCart.foodItem.id == item.foodItem.id);
      if (index != -1) {
        final currentQty = _items[index].quantity;
        final newQty =
            (currentQty + item.quantity).clamp(1, CartItem.maxQuantity);
        _items[index].quantity = newQty;
      } else {
        _items.add(CartItem(
          foodItem: item.foodItem,
          quantity: item.quantity.clamp(1, CartItem.maxQuantity),
          specialInstructions: item.specialInstructions,
        ));
      }
    }
    await _saveCart();
    notifyListeners();
  }

  Future<bool> increaseQuantity(String foodId) async {
    final index = _items.indexWhere((item) => item.foodItem.id == foodId);
    if (index != -1) {
      final success = _items[index].increaseQuantity();
      if (success) {
        await _saveCart();
        notifyListeners();
      }
      return success;
    } else {
      debugPrint('Item not found: $foodId');
      return false;
    }
  }

  Future<void> decreaseQuantity(String foodId) async {
    final index = _items.indexWhere((item) => item.foodItem.id == foodId);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].decreaseQuantity();
      } else {
        _items.removeAt(index);
      }
      await _saveCart();
      notifyListeners();
    } else {
      debugPrint('Item not found: $foodId');
    }
  }

  Future<void> removeItem(String foodId) async {
    _items.removeWhere((item) => item.foodItem.id == foodId);
    await _saveCart();
    notifyListeners();
  }

  Future<void> updateSpecialInstructions(
      String foodId, String instructions) async {
    final index = _items.indexWhere((item) => item.foodItem.id == foodId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(specialInstructions: instructions);
      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    await _saveCart();
    notifyListeners();
  }

  double getSubtotal() => totalPrice;

  double getDeliveryFee() => AppConstants.deliveryFee;

  double getTotalWithDelivery() => totalPrice + getDeliveryFee();

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = _items.map((item) => item.toMap()).toList();
      await prefs.setString(_cartKey, json.encode(cartData));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

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

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
