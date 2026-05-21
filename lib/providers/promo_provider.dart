import 'package:flutter/material.dart';

class PromoProvider extends ChangeNotifier {
  // Promo codes (in a real app, these would come from a backend)
  static const Map<String, double> _promoCodes = {
    'WELCOME10': 0.10,
    'FOOD20': 0.20,
    'SPECIAL30': 0.30,
    'FREE50': 0.50,
  };

  String? _appliedCode;
  double _discountPercent = 0.0;
  String? _errorMessage;

  Map<String, double> get availablePromoCodes => _promoCodes;
  String? get appliedCode => _appliedCode;
  double get discountPercent => _discountPercent;
  String? get errorMessage => _errorMessage;
  bool get hasDiscount => _appliedCode != null;

  bool applyPromoCode(String code) {
    final upperCode = code.trim().toUpperCase();
    if (_promoCodes.containsKey(upperCode)) {
      _appliedCode = upperCode;
      _discountPercent = _promoCodes[upperCode]!;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Code promo invalide';
      notifyListeners();
      return false;
    }
  }

  void removePromoCode() {
    _appliedCode = null;
    _discountPercent = 0.0;
    _errorMessage = null;
    notifyListeners();
  }

  double calculateDiscount(double subtotal) {
    return subtotal * _discountPercent;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
