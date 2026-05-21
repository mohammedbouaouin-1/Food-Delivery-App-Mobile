// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/loyalty_provider.dart';
import '../providers/promo_provider.dart';
import '../models/order.dart';
import '../data/app_constants.dart';
import 'card_payment_screen.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _promoController = TextEditingController(); // #17

  String _paymentMethod = 'Espèces';
  bool _isSubmitting = false;

  // #18 — Adresses sauvegardées
  List<Map<String, String>> _savedAddresses = [];

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
    _prefillUserData();
  }

  Future<void> _prefillUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = await authProvider.getUserData();
    
    if (userData != null && mounted) {
      setState(() {
        if (userData['name'] != null && userData['name'].isNotEmpty) {
          _nameController.text = userData['name'];
        }
        if (userData['phone'] != null && userData['phone'].isNotEmpty) {
          _phoneController.text = userData['phone'];
        }
      });
    }
  }

  Future<void> _loadSavedAddresses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = await authProvider.getUserData();
    
    if (userData != null && userData['addresses'] != null && mounted) {
      setState(() {
        _savedAddresses = List<Map<String, String>>.from(
          (userData['addresses'] as List).map((a) => Map<String, String>.from(a)),
        );
      });
    }
  }

  // #18 — Sauvegarder l'adresse
  Future<void> _saveCurrentAddress() async {
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();
    
    if (address.isEmpty || city.isEmpty) return;

    final newAddress = {'address': address, 'city': city};
    
    // Vérifier si l'adresse existe déjà
    final exists = _savedAddresses.any(
      (a) => a['address'] == address && a['city'] == city,
    );
    
    if (!exists) {
      _savedAddresses.add(newAddress);
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.saveAddresses(_savedAddresses);
    }
  }

  // #17 — Appliquer le code promo
  void _applyPromoCode() {
    final promoProvider = Provider.of<PromoProvider>(context, listen: false);
    final code = _promoController.text.trim().toUpperCase();
    
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Entrez un code promo'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    final success = promoProvider.applyPromoCode(code);
    if (success) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final discount = promoProvider.calculateDiscount(cartProvider.totalPrice);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Code "$code" appliqué ! -${discount.toStringAsFixed(0)} ${AppConstants.currency}'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _removePromoCode() {
    final promoProvider = Provider.of<PromoProvider>(context, listen: false);
    promoProvider.removePromoCode();
    _promoController.clear();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _promoController.dispose();
    try {
      Provider.of<PromoProvider>(context, listen: false).clearError();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      if (_isSubmitting) return; // Prevent duplicate taps

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final promoProvider = Provider.of<PromoProvider>(context, listen: false);
      final subtotal = cartProvider.totalPrice;
      final promoDiscount = promoProvider.calculateDiscount(subtotal);
      final appliedPromoCode = promoProvider.appliedCode;

      // #18 — Sauvegarder l'adresse pour réutilisation
      await _saveCurrentAddress();
      
      if (!mounted) return;
      
      if (_paymentMethod == 'Carte bancaire') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardPaymentScreen(
              name: _nameController.text,
              phone: _phoneController.text,
              address: _addressController.text,
              city: _cityController.text,
              discount: promoDiscount,
              appliedPromoCode: appliedPromoCode,
            ),
          ),
        );
      } else {
        setState(() => _isSubmitting = true);

        // Simuler un court délai de transaction réseau pour l'UX
        await Future.delayed(const Duration(milliseconds: 1000));

        if (!mounted) return;

        final orderProvider = Provider.of<OrderProvider>(context, listen: false);

        final deliveryFee = AppConstants.deliveryFee;
        final totalAmount = (subtotal + deliveryFee - promoDiscount).clamp(0, double.infinity);

        final order = Order(
          id: const Uuid().v4(),
          items: List.from(cartProvider.items),
          totalAmount: totalAmount.toDouble(),
          dateTime: DateTime.now(),
          customerName: _nameController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          city: _cityController.text,
          paymentMethod: _paymentMethod,
          deliveryFee: deliveryFee,
          notes: appliedPromoCode != null ? 'Promo: $appliedPromoCode (-${promoDiscount.toStringAsFixed(0)} ${AppConstants.currency})' : null,
        );

        orderProvider.addOrder(order);

        // #3 — Ajouter des points de fidélité
        final loyaltyProvider = Provider.of<LoyaltyProvider>(context, listen: false);
        loyaltyProvider.addPoints(totalAmount.toDouble());

        // Clear local shopping resources
        promoProvider.removePromoCode();
        cartProvider.clearCart();

        setState(() => _isSubmitting = false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSuccessScreen(
              orderNumber: order.id,
              totalAmount: totalAmount.toDouble(),
              paymentMethod: _paymentMethod,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final promoProvider = Provider.of<PromoProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deliveryFee = AppConstants.deliveryFee;
    final subtotal = cartProvider.totalPrice;

    final appliedPromoCode = promoProvider.appliedCode;
    final promoDiscount = promoProvider.calculateDiscount(subtotal);
    final total = (subtotal + deliveryFee - promoDiscount).clamp(0.0, double.infinity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations de livraison'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vos informations',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez entrer votre nom';
                  if (value.length < 3) return 'Le nom doit contenir au moins 3 caractères';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  hintText: '0612345678',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez entrer votre numéro';
                  final phoneRegex = RegExp(r'^0[5-7]\d{8}$');
                  if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
                    return 'Format invalide (ex: 0612345678)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // #18 — Adresses sauvegardées
              if (_savedAddresses.isNotEmpty) ...[
                Text(
                  'Adresses enregistrées',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _savedAddresses.length,
                    itemBuilder: (context, index) {
                      final addr = _savedAddresses[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: const Icon(Icons.location_on, size: 18),
                          label: Text(
                            '${addr['address']!.substring(0, math.min(addr['address']!.length, 20))}${addr['address']!.length > 20 ? "..." : ""}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            setState(() {
                              _addressController.text = addr['address']!;
                              _cityController.text = addr['city']!;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Adresse de livraison',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez entrer votre adresse';
                  if (value.length < 10) return 'Adresse trop courte';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Ville',
                  prefixIcon: const Icon(Icons.location_city),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez entrer votre ville';
                  if (value.length < 3) return 'Nom de ville trop court';
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // #17 — Code promo
              Text(
                'Code promo',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // Codes promo disponibles
              if (appliedPromoCode == null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF2C1810), const Color(0xFF1E1E1E)]
                          : [Colors.brown[50]!, Colors.orange.shade50],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.brown.withValues(alpha: 0.3) : Colors.brown.shade100,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_offer, size: 18, color: Colors.brown[700]),
                          const SizedBox(width: 6),
                          Text(
                            'Codes disponibles',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.brown[200] : Colors.brown[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: promoProvider.availablePromoCodes.entries.map((entry) {
                          return InkWell(
                            onTap: () {
                              _promoController.text = entry.key;
                              _applyPromoCode();
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.brown.withValues(alpha: 0.2)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.brown.withValues(alpha: 0.4)
                                      : Colors.brown.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown[700],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '-${(entry.value * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

              if (appliedPromoCode != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Code "$appliedPromoCode" appliqué : -${promoDiscount.toStringAsFixed(0)} ${AppConstants.currency} (-${(promoProvider.discountPercent * 100).toStringAsFixed(0)}%)',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 20),
                        onPressed: _removePromoCode,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoController,
                        decoration: InputDecoration(
                          hintText: 'Entrez votre code promo',
                          prefixIcon: const Icon(Icons.local_offer),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorText: promoProvider.errorMessage,
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _applyPromoCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Appliquer',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 30),

              Text(
                'Mode de paiement',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              RadioListTile<String>(
                title: const Text('Espèces à la livraison'),
                value: 'Espèces',
                groupValue: _paymentMethod,
                onChanged: (value) => setState(() => _paymentMethod = value!),
                activeColor: Colors.brown[700],
              ),

              RadioListTile<String>(
                title: const Text('Carte bancaire'),
                value: 'Carte bancaire',
                groupValue: _paymentMethod,
                onChanged: (value) => setState(() => _paymentMethod = value!),
                activeColor: Colors.brown[700],
              ),

              const SizedBox(height: 30),

              // Récapitulatif
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.brown[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF3E3E3E) : Colors.brown.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    _buildPriceRow('Articles', '${cartProvider.totalItemCount}', isDark),
                    const SizedBox(height: 8),
                    _buildPriceRow('Sous-total',
                        '${subtotal.toStringAsFixed(2)} ${AppConstants.currency}', isDark),
                    const SizedBox(height: 8),
                    _buildPriceRow('Livraison',
                        '${deliveryFee.toStringAsFixed(2)} ${AppConstants.currency}', isDark),
                    if (promoDiscount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.local_offer, size: 16, color: Colors.green),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text('Promo ($appliedPromoCode)',
                                      style: const TextStyle(fontSize: 14, color: Colors.green),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '-${promoDiscount.toStringAsFixed(2)} ${AppConstants.currency}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total :',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            )),
                        Text(
                          '${total.toStringAsFixed(2)} ${AppConstants.currency}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // #10 — Estimation de livraison dynamique
              _buildDeliveryEstimate(context, cartProvider, isDark),

              const SizedBox(height: 16),

              // #3 — Points de fidélité à gagner
              Consumer<LoyaltyProvider>(
                builder: (context, loyalty, _) {
                  final pointsToEarn = total.floor();
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : Colors.amber[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF3E3E3E) : Colors.amber[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vous gagnerez $pointsToEarn points',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                'Niveau actuel : ${loyalty.levelEmoji} ${loyalty.level} (${loyalty.points} pts)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'CONFIRMER LA COMMANDE',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontSize: 16, color: isDark ? Colors.grey[300] : Colors.black87)),
        Text(value, style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87)),
      ],
    );
  }

  // #10 — Estimation de livraison dynamique
  Widget _buildDeliveryEstimate(BuildContext context, CartProvider cartProvider, bool isDark) {
    // Calculer le temps max de préparation
    int maxPrepTime = 0;
    for (var item in cartProvider.items) {
      if (item.foodItem.preparationTime > maxPrepTime) {
        maxPrepTime = item.foodItem.preparationTime;
      }
    }
    final deliveryTime = 15; // temps de livraison fixe
    final totalMinutes = maxPrepTime + deliveryTime;
    final estimatedArrival = DateTime.now().add(Duration(minutes: totalMinutes));
    final arrivalStr = '${estimatedArrival.hour.toString().padLeft(2, '0')}:${estimatedArrival.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3E3E3E) : Colors.green[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delivery_dining, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Livraison estimée à $arrivalStr',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Préparation ~${maxPrepTime}min + Livraison ~${deliveryTime}min',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
