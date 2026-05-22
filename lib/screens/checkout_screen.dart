import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/loyalty_provider.dart';
import '../providers/promo_provider.dart';
import '../providers/locale_provider.dart';
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
  final _promoController = TextEditingController();

  String _paymentMethod = 'Espèces';
  bool _isSubmitting = false;

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
          (userData['addresses'] as List)
              .map((a) => Map<String, String>.from(a)),
        );
      });
    }
  }

  Future<void> _saveCurrentAddress() async {
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();

    if (address.isEmpty || city.isEmpty) return;

    final newAddress = {'address': address, 'city': city};

    final exists = _savedAddresses.any(
      (a) => a['address'] == address && a['city'] == city,
    );

    if (!exists) {
      _savedAddresses.add(newAddress);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.saveAddresses(_savedAddresses);
    }
  }

  void _applyPromoCode() {
    final promoProvider = Provider.of<PromoProvider>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final code = _promoController.text.trim().toUpperCase();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localeProvider.translate('enter_promo_error')),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                child: Text(
                    'Code "$code" ${localeProvider.translate('promo_applied_success')} -${discount.toStringAsFixed(0)} ${AppConstants.currency}'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      if (_isSubmitting) return;

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final promoProvider = Provider.of<PromoProvider>(context, listen: false);
      final subtotal = cartProvider.totalPrice;
      final promoDiscount = promoProvider.calculateDiscount(subtotal);
      final appliedPromoCode = promoProvider.appliedCode;

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

        await Future.delayed(const Duration(milliseconds: 1000));

        if (!mounted) return;

        final orderProvider =
            Provider.of<OrderProvider>(context, listen: false);

        final deliveryFee = AppConstants.deliveryFee;
        final totalAmount =
            (subtotal + deliveryFee - promoDiscount).clamp(0, double.infinity);

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
          notes: appliedPromoCode != null
              ? 'Promo: $appliedPromoCode (-${promoDiscount.toStringAsFixed(0)} ${AppConstants.currency})'
              : null,
        );

        orderProvider.addOrder(order);

        final loyaltyProvider =
            Provider.of<LoyaltyProvider>(context, listen: false);
        loyaltyProvider.addPoints(totalAmount.toDouble());

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
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deliveryFee = AppConstants.deliveryFee;
    final subtotal = cartProvider.totalPrice;

    final appliedPromoCode = promoProvider.appliedCode;
    final promoDiscount = promoProvider.calculateDiscount(subtotal);
    final total =
        (subtotal + deliveryFee - promoDiscount).clamp(0.0, double.infinity);

    return Scaffold(
      appBar: AppBar(
        title: Text(localeProvider.translate('checkout_title')),
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
                localeProvider.translate('your_info'),
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
                  labelText: localeProvider.translate('name_field'),
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return localeProvider.translate('enter_name_error');
                  if (value.length < 3)
                    return localeProvider.translate('name_too_short');
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: localeProvider.translate('phone_field'),
                  hintText: '0612345678',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return localeProvider.translate('enter_phone_error');
                  final phoneRegex = RegExp(r'^0[5-7]\d{8}$');
                  if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
                    return localeProvider.translate('phone_format_error');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_savedAddresses.isNotEmpty) ...[
                Text(
                  localeProvider.translate('saved_addresses'),
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
                  labelText: localeProvider.translate('address_field'),
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return localeProvider.translate('enter_address_error');
                  if (value.length < 10)
                    return localeProvider.translate('address_too_short');
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: localeProvider.translate('city_field'),
                  prefixIcon: const Icon(Icons.location_city),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return localeProvider.translate('enter_city_error');
                  if (value.length < 3)
                    return localeProvider.translate('city_too_short');
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Text(
                localeProvider.translate('promo_code'),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
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
                      color: isDark
                          ? Colors.brown.withValues(alpha: 0.3)
                          : Colors.brown.shade100,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_offer,
                              size: 18, color: Colors.brown[700]),
                          const SizedBox(width: 6),
                          Text(
                            localeProvider.translate('available_promos'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.brown[200]
                                  : Colors.brown[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: promoProvider.availablePromoCodes.entries
                            .map((entry) {
                          return InkWell(
                            onTap: () {
                              _promoController.text = entry.key;
                              _applyPromoCode();
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
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
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Code "$appliedPromoCode" ${localeProvider.translate('promo_applied_label')} : -${promoDiscount.toStringAsFixed(0)} ${AppConstants.currency} (-${(promoProvider.discountPercent * 100).toStringAsFixed(0)}%)',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.red, size: 20),
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
                          hintText:
                              localeProvider.translate('promo_placeholder'),
                          prefixIcon: const Icon(Icons.local_offer),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorText: promoProvider.errorMessage != null
                              ? localeProvider.translate('promo_code_invalid')
                              : null,
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
                        child: Text(
                            localeProvider.translate('promo_code_apply'),
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 30),
              Text(
                localeProvider.translate('payment_method'),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              RadioListTile<String>(
                title: Text(localeProvider.translate('cash_on_delivery')),
                value: 'Espèces',
                groupValue: _paymentMethod,
                onChanged: (value) => setState(() => _paymentMethod = value!),
                activeColor: Colors.brown[700],
              ),
              RadioListTile<String>(
                title: Text(localeProvider.translate('credit_card')),
                value: 'Carte bancaire',
                groupValue: _paymentMethod,
                onChanged: (value) => setState(() => _paymentMethod = value!),
                activeColor: Colors.brown[700],
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.brown[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF3E3E3E)
                        : Colors.brown.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    _buildPriceRow(localeProvider.translate('items'),
                        '${cartProvider.totalItemCount}', isDark),
                    const SizedBox(height: 8),
                    _buildPriceRow(
                        localeProvider.translate('subtotal'),
                        '${subtotal.toStringAsFixed(2)} ${AppConstants.currency}',
                        isDark),
                    const SizedBox(height: 8),
                    _buildPriceRow(
                        localeProvider.translate('delivery'),
                        '${deliveryFee.toStringAsFixed(2)} ${AppConstants.currency}',
                        isDark),
                    if (promoDiscount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.local_offer,
                                    size: 16, color: Colors.green),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                      '${localeProvider.translate('promo_label')} ($appliedPromoCode)',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.green),
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
                        Text(localeProvider.translate('total_label'),
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
              _buildDeliveryEstimate(
                  context, cartProvider, isDark, localeProvider),
              const SizedBox(height: 16),
              Consumer<LoyaltyProvider>(
                builder: (context, loyalty, _) {
                  final pointsToEarn = total.floor();
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isDark ? const Color(0xFF2A2A2A) : Colors.amber[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF3E3E3E)
                            : Colors.amber[200]!,
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
                                '${localeProvider.translate('loyalty_win_points')} $pointsToEarn ${localeProvider.translate('loyalty_points_label')}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                '${localeProvider.translate('loyalty_current_level')} ${loyalty.levelEmoji} ${loyalty.level} (${loyalty.points} pts)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
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
                      : Text(
                          localeProvider.translate('confirm_order_btn'),
                          style: const TextStyle(
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
        Text(label,
            style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[300] : Colors.black87)),
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
      ],
    );
  }

  Widget _buildDeliveryEstimate(BuildContext context, CartProvider cartProvider,
      bool isDark, LocaleProvider localeProvider) {
    int maxPrepTime = 0;
    for (var item in cartProvider.items) {
      if (item.foodItem.preparationTime > maxPrepTime) {
        maxPrepTime = item.foodItem.preparationTime;
      }
    }
    final deliveryTime = 15;
    final totalMinutes = maxPrepTime + deliveryTime;
    final estimatedArrival =
        DateTime.now().add(Duration(minutes: totalMinutes));
    final arrivalStr =
        '${estimatedArrival.hour.toString().padLeft(2, '0')}:${estimatedArrival.minute.toString().padLeft(2, '0')}';

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
            child: const Icon(Icons.delivery_dining,
                color: Colors.green, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${localeProvider.translate('estimated_delivery_at')} $arrivalStr',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${localeProvider.translate('prep_time_label')} ~${maxPrepTime}min + ${localeProvider.translate('delivery_time_label')} ~${deliveryTime}min',
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
