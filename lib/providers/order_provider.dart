import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order.dart';


class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  Timer? _timer;
  String? _currentUserId;
  StreamSubscription<User?>? _authSubscription; // Fix #6: Store subscription
  
  OrderProvider() {
    _initializeOrders();
    _startTimer();
  }
  
  void _initializeOrders() {
    // Fix #6: Store the subscription for proper cleanup
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      final newUserId = user?.uid;
      
      // Si l'utilisateur change, recharger les commandes
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        _orders.clear();
        if (_currentUserId != null) {
          _loadOrders();
        } else {
          notifyListeners();
        }
      }
    });
    
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (_currentUserId != null) {
      _loadOrders();
    }
  }
  
  // Obtenir la clé de stockage unique par utilisateur
  String get _ordersKey {
    if (_currentUserId == null) {
      return 'orders_history_guest'; 
    }
    return 'orders_history_$_currentUserId';
  }
  
  List<Order> get orders => [..._orders];
  
  int get orderCount => _orders.length;
  
  List<Order> get activeOrders {
    return _orders.where((order) => !order.isCompleted).toList();
  }
  
  // Commandes terminées
  List<Order> get completedOrders {
    return _orders.where((order) => order.isCompleted).toList();
  }
  
  int get activeOrderCount => activeOrders.length;
  
  /// Recharger les commandes depuis le stockage local
  Future<void> loadOrders() async {
    await _loadOrders();
  }
  
  // Montant total dépensé
  double get totalSpent {
    return _orders.fold(0.0, (sum, order) => sum + order.totalAmount);
  }
  
  // Démarrer le timer pour la progression
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool hasChanges = false;
      
      for (var order in _orders) {
        if (!order.isCompleted) {
          if (order.remainingSeconds > 0) {
            order.remainingSeconds--;
            hasChanges = true;
          } else if (order.remainingMinutes > 0) {
            order.remainingMinutes--;
            order.remainingSeconds = 59;
            hasChanges = true;
            
            // Changer le statut à 20 minutes
            if (order.remainingMinutes == 20 && 
                order.status == OrderStatus.preparing) {
              order.status = OrderStatus.delivering;
            }
          } else {
            // Temps écoulé, marquer comme livrée
            if (order.status != OrderStatus.delivered) {
              order.status = OrderStatus.delivered;
              order.deliveredAt = DateTime.now();
              hasChanges = true;
            }
          }
        }
      }
      
      if (hasChanges) {
        _saveOrders();
        notifyListeners();
      }
    });
  }
  
  // Ajouter une commande
  Future<void> addOrder(Order order) async {
    _orders.insert(0, order);
    await _saveOrders();
    notifyListeners();
  }
  
  // Obtenir une commande par ID
  Order? getOrderById(String id) {
    final index = _orders.indexWhere((order) => order.id == id);
    if (index != -1) {
      return _orders[index];
    }
    return null;
  }
  
  // Annuler une commande
  Future<bool> cancelOrder(String orderId) async {
    try {
      final order = getOrderById(orderId);
      if (order != null && order.canCancel) {
        order.status = OrderStatus.cancelled;
        await _saveOrders();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      return false;
    }
  }
  
  // Supprimer une commande de l'historique
  Future<void> deleteOrder(String orderId) async {
    _orders.removeWhere((order) => order.id == orderId);
    await _saveOrders();
    notifyListeners();
  }
  
  // Effacer tout l'historique
  Future<void> clearHistory() async {
    _orders.clear();
    await _saveOrders();
    notifyListeners();
  }
  
  // Effacer les commandes terminées
  Future<void> clearCompletedOrders() async {
    _orders.removeWhere((order) => order.isCompleted);
    await _saveOrders();
    notifyListeners();
  }
  
  Future<void> reorder(Order order) async {
    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: order.items,
      totalAmount: order.totalAmount,
      dateTime: DateTime.now(),
      customerName: order.customerName,
      phone: order.phone,
      address: order.address,
      city: order.city,
      paymentMethod: order.paymentMethod,
      userId: _currentUserId,
      deliveryFee: order.deliveryFee,
      notes: order.notes,
    );
    
    await addOrder(newOrder);
  }
  
  // Statistiques
  Map<String, dynamic> getStatistics() {
    return {
      'totalOrders': orderCount,
      'activeOrders': activeOrderCount,
      'completedOrders': completedOrders.length,
      'totalSpent': totalSpent,
      'averageOrderValue': orderCount > 0 ? totalSpent / orderCount : 0,
    };
  }
  
  // Sauvegarder localement (avec clé unique par utilisateur)
  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersData = _orders.map((order) => order.toMap()).toList();
      await prefs.setString(_ordersKey, json.encode(ordersData));
    } catch (e) {
      debugPrint('Error saving orders: $e');
    }
  }
  
  // Charger depuis le stockage local (avec clé unique par utilisateur)
  Future<void> _loadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersString = prefs.getString(_ordersKey);
      
      if (ordersString != null) {
        final List<dynamic> ordersData = json.decode(ordersString);
        _orders = ordersData.map((order) => Order.fromMap(order)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
      _orders = [];
    }
  }
  
  // Fix #6: Properly dispose both timer and auth subscription
  @override
  void dispose() {
    _timer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}