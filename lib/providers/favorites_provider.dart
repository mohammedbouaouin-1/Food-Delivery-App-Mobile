import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/food_item.dart';

class FavoritesProvider extends ChangeNotifier {
  Set<String> _favoriteIds = {};
  String? _currentUserId;
  StreamSubscription<User?>? _authSubscription;

  FavoritesProvider() {
    _initializeFavorites();
  }

  void _initializeFavorites() {
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      final newUserId = user?.uid;

      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        _favoriteIds.clear();
        if (_currentUserId != null) {
          _loadFavorites();
        } else {
          notifyListeners();
        }
      }
    });

    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (_currentUserId != null) {
      _loadFavorites();
    }
  }

  String get _favoritesKey {
    if (_currentUserId == null) {
      return 'favorites_guest';
    }
    return 'favorites_$_currentUserId';
  }

  bool isFavorite(String foodId) => _favoriteIds.contains(foodId);

  int get favoriteCount => _favoriteIds.length;

  Set<String> get favoriteIds => {..._favoriteIds};

  List<FoodItem> getFavoriteItems(List<FoodItem> allItems) {
    return allItems.where((item) => _favoriteIds.contains(item.id)).toList();
  }

  Future<void> toggleFavorite(String foodId) async {
    if (_favoriteIds.contains(foodId)) {
      _favoriteIds.remove(foodId);
    } else {
      _favoriteIds.add(foodId);
    }
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> removeFavorite(String foodId) async {
    _favoriteIds.remove(foodId);
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> clearFavorites() async {
    _favoriteIds.clear();
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_favoritesKey, json.encode(_favoriteIds.toList()));
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesString = prefs.getString(_favoritesKey);

      if (favoritesString != null) {
        final List<dynamic> favoritesData = json.decode(favoritesString);
        _favoriteIds = favoritesData.map((id) => id.toString()).toSet();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      _favoriteIds = {};
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
