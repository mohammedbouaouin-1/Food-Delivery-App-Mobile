import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_constants.dart';

/// Système de fidélité par utilisateur
class LoyaltyProvider extends ChangeNotifier {
  int _points = 0;
  String _level = 'Bronze';
  String? _currentUserId;
  StreamSubscription<User?>? _authSubscription;

  int get points => _points;
  String get level => _level;

  /// Icône du niveau
  String get levelEmoji {
    switch (_level) {
      case 'Gold':
        return '👑';
      case 'Silver':
        return '🥈';
      default:
        return '🥉';
    }
  }

  /// Points nécessaires pour le prochain niveau
  int get pointsToNextLevel {
    switch (_level) {
      case 'Bronze':
        return AppConstants.loyaltySilverThreshold - _points;
      case 'Silver':
        return AppConstants.loyaltyGoldThreshold - _points;
      default:
        return 0;
    }
  }

  /// Progression en pourcentage (0.0 à 1.0)
  double get progressToNextLevel {
    switch (_level) {
      case 'Bronze':
        return (_points / AppConstants.loyaltySilverThreshold).clamp(0.0, 1.0);
      case 'Silver':
        final range = AppConstants.loyaltyGoldThreshold - AppConstants.loyaltySilverThreshold;
        final currentRangePoints = _points - AppConstants.loyaltySilverThreshold;
        return (currentRangePoints / range).clamp(0.0, 1.0);
      default:
        return 1.0;
    }
  }

  /// Réductions disponibles selon les points
  List<Map<String, dynamic>> get availableRewards {
    return [
      {'points': 100, 'label': 'Livraison gratuite', 'icon': '🚚', 'discount': 10.0},
      {'points': 200, 'label': '-20 MAD', 'icon': '💰', 'discount': 20.0},
      {'points': 500, 'label': '-50 MAD', 'icon': '🎁', 'discount': 50.0},
    ];
  }

  LoyaltyProvider() {
    _initializeLoyalty();
  }

  void _initializeLoyalty() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      final newUserId = user?.uid;
      
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        if (_currentUserId != null) {
          _loadPoints();
        } else {
          _points = 0;
          _level = 'Bronze';
          notifyListeners();
        }
      }
    });

    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (_currentUserId != null) {
      _loadPoints();
    }
  }

  String get _pointsKey => _currentUserId != null ? 'loyalty_points_$_currentUserId' : 'loyalty_points_guest';
  String get _levelKey => _currentUserId != null ? 'loyalty_level_$_currentUserId' : 'loyalty_level_guest';

  /// Charger les points
  Future<void> _loadPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _points = prefs.getInt(_pointsKey) ?? 0;
      _level = prefs.getString(_levelKey) ?? 'Bronze';
      _updateLevel();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading loyalty points: $e');
    }
  }

  /// Sauvegarder les points
  Future<void> _savePoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_pointsKey, _points);
      await prefs.setString(_levelKey, _level);
    } catch (e) {
      debugPrint('Error saving loyalty points: $e');
    }
  }

  /// Mettre à jour le niveau
  void _updateLevel() {
    if (_points >= AppConstants.loyaltyGoldThreshold) {
      _level = 'Gold';
    } else if (_points >= AppConstants.loyaltySilverThreshold) {
      _level = 'Silver';
    } else {
      _level = 'Bronze';
    }
  }

  /// Ajouter des points (1 MAD = 1 point)
  Future<void> addPoints(double orderAmount) async {
    _points += orderAmount.floor();
    _updateLevel();
    await _savePoints();
    notifyListeners();
  }

  /// Utiliser des points pour une réduction
  Future<bool> redeemReward(int pointsCost) async {
    if (_points >= pointsCost) {
      _points -= pointsCost;
      _updateLevel();
      await _savePoints();
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
