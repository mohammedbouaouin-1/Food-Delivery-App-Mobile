import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Panier (${cartProvider.totalItemCount})'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          if (cartProvider.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
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
                        child: const Text('Vider'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cartProvider.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartProvider.items[index];
                      return _buildCartItemCard(context, cartItem, cartProvider);
                    },
                  ),
                ),
                
                
                _buildBottomBar(context, cartProvider),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text('Votre panier est vide', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text('Ajoutez des articles', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, cartItem, CartProvider cartProvider) {
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
                child: const Text('Oui'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        cartProvider.removeItem(cartItem.foodItem.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${cartItem.foodItem.name} retiré'),
            action: SnackBarAction(
              label: 'Annuler',
              onPressed: () => cartProvider.addItem(cartItem.foodItem),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Image
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
              
              // Détails
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.foodItem.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${cartItem.foodItem.price.toStringAsFixed(2)} MAD',
                      style: TextStyle(fontSize: 13, color: Colors.red[600], fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${cartItem.totalPrice.toStringAsFixed(2)} MAD',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.brown[700]),
                    ),
                  ],
                ),
              ),
              
              // Contrôles quantité 
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => cartProvider.increaseQuantity(cartItem.foodItem.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.add, size: 18, color: Colors.green[700]),
                      ),
                    ),
                    Container(
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
                    InkWell(
                      onTap: () => cartProvider.decreaseQuantity(cartItem.foodItem.id),
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
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sous-total 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sous-total :', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                Text('${cartProvider.totalPrice.toStringAsFixed(2)} MAD', 
                     style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 6),
            
            // Livraison 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.delivery_dining, color: Colors.grey[700], size: 18),
                    const SizedBox(width: 4),
                    Text('Livraison :', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  ],
                ),
                Text('${cartProvider.getDeliveryFee().toStringAsFixed(2)} MAD',
                     style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            
            const Divider(height: 20, thickness: 1),
            
            // Total 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  '${cartProvider.getTotalWithDelivery().toStringAsFixed(2)} MAD',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[600]),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Bouton commander 
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
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
        ),),);}
}
