import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/loyalty_provider.dart';
import '../models/order.dart';
import '../data/app_constants.dart';
import 'order_success_screen.dart';


class CardPaymentScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String address;
  final String city;
  final double discount;
  final String? appliedPromoCode;

  const CardPaymentScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    this.discount = 0.0,
    this.appliedPromoCode,
  });

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  String _cardType = '';
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _detectCardType(String cardNumber) {
    String cleanNumber = cardNumber.replaceAll(' ', '');

    if (cleanNumber.isEmpty) {
      setState(() => _cardType = '');
      return;
    }

    if (cleanNumber.startsWith('4')) {
      setState(() => _cardType = 'Visa');
    } else if (cleanNumber.startsWith('5')) {
      setState(() => _cardType = 'Mastercard');
    } else if (cleanNumber.startsWith('3')) {
      setState(() => _cardType = 'American Express');
    } else {
      setState(() => _cardType = 'Carte');
    }
  }

  String _formatCardNumber(String value) {
    String cleanValue = value.replaceAll(' ', '');
    String formatted = '';

    for (int i = 0; i < cleanValue.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += cleanValue[i];
    }

    return formatted;
  }

  String _formatExpiryDate(String value) {
    String cleanValue = value.replaceAll('/', '');

    if (cleanValue.length >= 2) {
      return '${cleanValue.substring(0, 2)}/${cleanValue.substring(2)}';
    }

    return cleanValue;
  }

  void _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);

      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isProcessing = false);

      if (!mounted) return;

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      // Fix #1: Utiliser les frais centralisés
      final deliveryFee = AppConstants.deliveryFee;
      final totalAmount = (cartProvider.totalPrice + deliveryFee - widget.discount).clamp(0.0, double.infinity);

      final order = Order(
        id: const Uuid().v4(),
        items: List.from(cartProvider.items),
        totalAmount: totalAmount,
        dateTime: DateTime.now(),
        customerName: widget.name,
        phone: widget.phone,
        address: widget.address,
        city: widget.city,
        paymentMethod: 'Carte bancaire',
        deliveryFee: deliveryFee,
        notes: widget.appliedPromoCode != null ? 'Promo: ${widget.appliedPromoCode} (-${widget.discount.toStringAsFixed(0)} ${AppConstants.currency})' : null,
      );

      orderProvider.addOrder(order);
      final orderNumber = order.id;

      // #3 — Ajouter des points de fidélité
      try {
        final loyaltyProvider = Provider.of<LoyaltyProvider>(context, listen: false);
        loyaltyProvider.addPoints(totalAmount);
      } catch (e) {
        debugPrint('Error adding loyalty points: $e');
      }

      cartProvider.clearCart();

      // Amélioration #10: Écran de succès animé
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(
            orderNumber: orderNumber,
            totalAmount: totalAmount,
            paymentMethod: 'Carte bancaire',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement par carte'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // #29 — Carte bancaire avec glassmorphism
                  Container(
                    height: 210,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1A237E).withValues(alpha: 0.85),
                          const Color(0xFF283593).withValues(alpha: 0.75),
                          const Color(0xFF3949AB).withValues(alpha: 0.65),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A237E).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.05),
                          blurRadius: 1,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Shine effect
                        Positioned(
                          top: -30,
                          right: -30,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -20,
                          left: -20,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Card content
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(
                                    Icons.credit_card,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  Text(
                                    _cardType,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _cardNumberController.text.isEmpty
                                      ? '**** **** **** ****'
                                      : _cardNumberController.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'TITULAIRE',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                          ),
                                        ),
                                        Text(
                                          _cardHolderController.text.isEmpty
                                              ? 'VOTRE NOM'
                                              : _cardHolderController.text.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'EXPIRE',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        _expiryDateController.text.isEmpty
                                            ? 'MM/AA'
                                            : _expiryDateController.text,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    'Informations de la carte',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _cardNumberController,
                    decoration: InputDecoration(
                      labelText: 'Numéro de carte',
                      hintText: '1234 5678 9012 3456',
                      prefixIcon: const Icon(Icons.credit_card),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                      LengthLimitingTextInputFormatter(19),
                    ],
                    onChanged: (value) {
                      final cleanValue = value.replaceAll(' ', '');
                      final formatted = _formatCardNumber(cleanValue);
                      if (formatted != value) {
                        _cardNumberController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                      _detectCardType(cleanValue);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le numéro de carte';
                      }
                      String cleanValue = value.replaceAll(' ', '');
                      if (cleanValue.length < 13 || cleanValue.length > 16) {
                        return 'Numéro de carte invalide';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _cardHolderController,
                    decoration: InputDecoration(
                      labelText: 'Nom du titulaire',
                      hintText: 'VOTRE NOM',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le nom du titulaire';
                      }
                      if (value.length < 3) {
                        return 'Nom trop court';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryDateController,
                          decoration: InputDecoration(
                            labelText: 'Date d\'expiration',
                            hintText: 'MM/AA',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _expiryDateController.text = _formatExpiryDate(
                                value,
                              );
                              _expiryDateController.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(
                                      offset: _expiryDateController.text.length,
                                    ),
                                  );
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Requis';
                            }
                            if (value.length < 5) {
                              return 'Format: MM/AA';
                            }

                            List<String> parts = value.split('/');
                            if (parts.length != 2) {
                              return 'Format invalide';
                            }

                            int? month = int.tryParse(parts[0]);
                            int? year = int.tryParse(parts[1]);
                            if (month == null || month < 1 || month > 12) {
                              return 'Mois invalide';
                            }

                            // Vérifier si la carte est expirée
                            if (year != null) {
                              final now = DateTime.now();
                              final currentYear = now.year % 100;
                              final currentMonth = now.month;
                              if (year < currentYear || (year == currentYear && month < currentMonth)) {
                                return 'Carte expirée';
                              }
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            hintText: '123',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Requis';
                            }
                            if (value.length < 3) {
                              return 'CVV invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? const Color(0xFF3E3E3E) : Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Colors.green.shade700),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Paiement sécurisé SSL. Vos données sont protégées.',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.brown[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? const Color(0xFF3E3E3E) : Colors.brown.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Montant à payer :',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),


                        //  adapter automatiquement la taille du texte
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${(cartProvider.totalPrice + AppConstants.deliveryFee - widget.discount).clamp(0.0, double.infinity).toStringAsFixed(2)} ${AppConstants.currency}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isProcessing
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Traitement en cours...',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'PAYER MAINTENANT',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}