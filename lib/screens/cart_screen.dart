import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../data/app_constants.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Panier (${cartProvider.totalItemCount})'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          if (cartProvider.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                HapticFeedback.mediumImpact(); // #31
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
                        SizedBox(width: 8),
                        Text('Vider le panier ?', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    content: const Text('Supprimer tous les articles ?', style: TextStyle(fontSize: 14)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Non'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          cartProvider.clearCart();
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Vider', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cartProvider.isEmpty
          ? _buildEmptyCart(isDark)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartProvider.items[index];
                      return _buildCartItemCard(context, cartItem, cartProvider, isDark, index);
                    },
                  ),
                ),
                _buildBottomBar(context, cartProvider, isDark),
              ],
            ),
    );
  }

  // #28 — Empty state animé
  Widget _buildEmptyCart(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône animée
          Icon(Icons.shopping_cart_outlined, size: 100,
               color: isDark ? Colors.grey[700] : Colors.grey[300])
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1500.ms)
              .then()
              .shake(hz: 2, duration: 500.ms),
          const SizedBox(height: 24),
          Text('Votre panier est vide',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[400] : Colors.grey[700]))
              .animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text('Parcourez le menu pour ajouter des articles',
              style: TextStyle(fontSize: 14,
                  color: isDark ? Colors.grey[600] : Colors.grey[500]))
              .animate().fadeIn(duration: 500.ms, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItem cartItem, CartProvider cartProvider, bool isDark, int index) {
    return Dismissible(
      key: Key(cartItem.foodItem.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact(); // #31
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Supprimer ?', style: TextStyle(fontSize: 16)),
            content: Text('Retirer "${cartItem.foodItem.name}" ?', style: const TextStyle(fontSize: 14)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Non'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Oui', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        final deletedItem = cartItem.copyWith();
        cartProvider.removeItem(cartItem.foodItem.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${cartItem.foodItem.name} retiré'),
            action: SnackBarAction(
              label: 'Annuler',
              onPressed: () => cartProvider.restoreCartItem(deletedItem),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        color: isDark ? const Color(0xFF1E1E1E) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      cartItem.foodItem.image,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cartItem.foodItem.name,
                          style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cartItem.foodItem.price.toStringAsFixed(2)} ${AppConstants.currency}',
                          style: TextStyle(fontSize: 13, color: Colors.red[600], fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        // #35 — Total animé
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            'Total: ${cartItem.totalPrice.toStringAsFixed(2)} ${AppConstants.currency}',
                            key: ValueKey<double>(cartItem.totalPrice),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                                color: isDark ? Colors.brown[300] : Colors.brown[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // #35 — Contrôles quantité avec animation
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick(); // #31
                            cartProvider.increaseQuantity(cartItem.foodItem.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            child: Icon(Icons.add, size: 18, color: Colors.green[700]),
                          ),
                        ),
                        // #35 — Compteur animé
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: Container(
                            key: ValueKey<int>(cartItem.quantity),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.brown[700],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${cartItem.quantity}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick(); // #31
                            cartProvider.decreaseQuantity(cartItem.foodItem.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            child: Icon(Icons.remove, size: 18, color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Instructions spéciales (#21)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InkWell(
                  onTap: () => _showSpecialInstructionsDialog(
                    context, cartItem, cartProvider,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF3E3E3E) : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit_note, size: 18,
                            color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cartItem.specialInstructions?.isNotEmpty == true
                                ? cartItem.specialInstructions!
                                : 'Ajouter une note (allergies, cuisson...)',
                            style: TextStyle(
                              fontSize: 12,
                              color: cartItem.specialInstructions?.isNotEmpty == true
                                  ? (isDark ? Colors.white70 : Colors.black87)
                                  : (isDark ? Colors.grey[600] : Colors.grey[400]),
                              fontStyle: cartItem.specialInstructions?.isNotEmpty == true
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 16,
                            color: isDark ? Colors.grey[600] : Colors.grey[400]),
                      ],
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

  void _showSpecialInstructionsDialog(
    BuildContext context, CartItem cartItem, CartProvider cartProvider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _SpecialInstructionsDialog(
        cartItem: cartItem,
        cartProvider: cartProvider,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CartProvider cartProvider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sous-total :', style: TextStyle(fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[700])),
                // #35 — Total animé
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '${cartProvider.totalPrice.toStringAsFixed(2)} ${AppConstants.currency}',
                    key: ValueKey<double>(cartProvider.totalPrice),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                         color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.delivery_dining,
                        color: isDark ? Colors.grey[400] : Colors.grey[700], size: 18),
                    const SizedBox(width: 4),
                    Text('Livraison :', style: TextStyle(fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[700])),
                  ],
                ),
                Text('${cartProvider.getDeliveryFee().toStringAsFixed(2)} ${AppConstants.currency}',
                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                         color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
            
            const Divider(height: 20, thickness: 1),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87)),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '${cartProvider.getTotalWithDelivery().toStringAsFixed(2)} ${AppConstants.currency}',
                    key: ValueKey<double>(cartProvider.getTotalWithDelivery()),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[600]),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact(); // #31
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'PASSER COMMANDE',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecialInstructionsDialog extends StatefulWidget {
  final CartItem cartItem;
  final CartProvider cartProvider;

  const _SpecialInstructionsDialog({
    required this.cartItem,
    required this.cartProvider,
  });

  @override
  State<_SpecialInstructionsDialog> createState() => _SpecialInstructionsDialogState();
}

class _SpecialInstructionsDialogState extends State<_SpecialInstructionsDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.cartItem.specialInstructions ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.edit_note, color: Colors.brown[700]),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Instructions spéciales', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.cartItem.foodItem.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ex: Sans oignons, bien cuit, allergie aux noix...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.cartProvider.updateSpecialInstructions(
              widget.cartItem.foodItem.id,
              _controller.text,
            );
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[700]),
          child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
