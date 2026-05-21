import 'cart_item.dart';
import '../data/app_constants.dart';

enum OrderStatus {
  pending('En attente', '⏳'),
  preparing('En préparation', '👨‍🍳'),
  delivering('En livraison', '🚗'),
  delivered('Livrée', '✅'),
  cancelled('Annulée', '❌');
  
  final String label;
  final String emoji;
  const OrderStatus(this.label, this.emoji);
}

class Order {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime dateTime;
  final String customerName;
  final String phone;
  final String address;
  final String city;
  final String paymentMethod;
  OrderStatus status;
  int remainingMinutes;
  int remainingSeconds;
  final String? userId;
  final double deliveryFee;
  final String? notes;
  DateTime? deliveredAt;
  
  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.dateTime,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.city,
    required this.paymentMethod,
    this.status = OrderStatus.preparing,
    this.remainingMinutes = 30,
    this.remainingSeconds = 0,
    this.userId,
    this.deliveryFee = AppConstants.deliveryFee,
    this.notes,
    this.deliveredAt,
  });
  
  
  int get totalEstimatedSeconds => remainingMinutes * 60;
  
  
  int get elapsedSeconds {
    int remaining = (remainingMinutes * 60) + remainingSeconds;
    return totalEstimatedSeconds - remaining;
  }
  
 
  double getProgress() {
    if (status == OrderStatus.delivered || status == OrderStatus.cancelled) {
      return 1.0;
    }
    int totalSeconds = (remainingMinutes * 60) + remainingSeconds;
    return 1 - (totalSeconds / totalEstimatedSeconds);
  }
  
  

  String getStatusIcon() => status.emoji;
  
 

  String getStatusMessage() {
    switch (status) {
      case OrderStatus.pending:
        return 'Votre commande a été reçue et est en attente de confirmation';
      case OrderStatus.preparing:
        return 'Votre commande est en cours de préparation par nos chefs';
      case OrderStatus.delivering:
        return 'Le livreur est en route vers vous avec votre commande';
      case OrderStatus.delivered:
        return 'Votre commande a été livrée avec succès. Bon appétit !';
      case OrderStatus.cancelled:
        return 'Cette commande a été annulée';
    }
  }
  

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
  
 
  double get subtotal => totalAmount - deliveryFee;
  


  bool get canCancel {
    return status == OrderStatus.pending || status == OrderStatus.preparing;
  }


  bool get isCompleted {
    return status == OrderStatus.delivered || status == OrderStatus.cancelled;
  }
  
  
  String get formattedRemainingTime {
    if (isCompleted) return '00:00';
    return '${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'dateTime': dateTime.toIso8601String(),
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'city': city,
      'paymentMethod': paymentMethod,
      'status': status.name,
      'remainingMinutes': remainingMinutes,
      'remainingSeconds': remainingSeconds,
      'userId': userId,
      'deliveryFee': deliveryFee,
      'notes': notes,
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }
  
  
  factory Order.fromMap(Map<String, dynamic> map) {
    DateTime parsedDateTime;
    try {
      parsedDateTime = map['dateTime'] != null ? DateTime.parse(map['dateTime']) : DateTime.now();
    } catch (_) {
      parsedDateTime = DateTime.now();
    }

    DateTime? parsedDeliveredAt;
    if (map['deliveredAt'] != null) {
      try {
        parsedDeliveredAt = DateTime.parse(map['deliveredAt']);
      } catch (_) {
        parsedDeliveredAt = null;
      }
    }

    return Order(
      id: map['id'] ?? '',
      items: (map['items'] as List?)
          ?.map((item) => CartItem.fromMap(item))
          .toList() ?? [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      dateTime: parsedDateTime,
      customerName: map['customerName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.preparing,
      ),
      remainingMinutes: map['remainingMinutes'] ?? 30,
      remainingSeconds: map['remainingSeconds'] ?? 0,
      userId: map['userId'],
      deliveryFee: (map['deliveryFee'] ?? AppConstants.deliveryFee).toDouble(),
      notes: map['notes'],
      deliveredAt: parsedDeliveredAt,
    );
  }
  
 
  Order copyWith({
    String? id,
    List<CartItem>? items,
    double? totalAmount,
    DateTime? dateTime,
    String? customerName,
    String? phone,
    String? address,
    String? city,
    String? paymentMethod,
    OrderStatus? status,
    int? remainingMinutes,
    int? remainingSeconds,
    String? userId,
    double? deliveryFee,
    String? notes,
    DateTime? deliveredAt,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      dateTime: dateTime ?? this.dateTime,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      userId: userId ?? this.userId,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      notes: notes ?? this.notes,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}