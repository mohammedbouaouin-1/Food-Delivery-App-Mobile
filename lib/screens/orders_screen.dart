import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/order_provider.dart';
import '../providers/cart_provider.dart';
import '../models/order.dart';
import '../data/app_constants.dart';
import 'main_navigation_screen.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {

  // couleurs selon le statut
  List<Color> _getStatusColors(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return [Colors.orange.shade400, Colors.orange.shade600];
      case OrderStatus.preparing:
        return [Colors.blue.shade400, Colors.blue.shade600];
      case OrderStatus.delivering:
        return [Colors.purple.shade400, Colors.purple.shade600];
      case OrderStatus.delivered:
        return [Colors.green.shade400, Colors.green.shade600];
      case OrderStatus.cancelled:
        return [Colors.red.shade400, Colors.red.shade600];
    }
  }

  //  confirmation pour annuler une commande
  Future<void> _showCancelDialog(BuildContext context, Order order) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Annuler ?',
                style: TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text(
          'Voulez-vous annuler cette commande ?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await orderProvider.cancelOrder(order.id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Commande annulée' : 'Impossible d\'annuler',
                    ),
                    backgroundColor: success ? Colors.orange : Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Annuler', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // confirmation pour supprimer une commande
  Future<void> _showDeleteDialog(BuildContext context, Order order) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_forever, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Supprimer ?',
                style: TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text(
          'Supprimer cette commande de l\'historique ?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await orderProvider.deleteOrder(order.id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Commande supprimée'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child:
                const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Dialogue pour vider tout l'historique
  Future<void> _showClearHistoryDialog(BuildContext context) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_sweep, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Vider l\'historique ?',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text(
          'Supprimer TOUTES vos commandes ?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await orderProvider.clearHistory();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Historique vidé'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Tout supprimer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // #23 — Re-commander
  Future<void> _handleReorder(BuildContext context, Order order) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Batch add all items at once
    await cartProvider.addItemsBatch(order.items);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Articles ajoutés au panier !')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'VOIR PANIER',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavigationScreen(initialIndex: 2),
                ),
                (route) => false,
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          if (orderProvider.orders.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'clear_all') {
                  _showClearHistoryDialog(context);
                } else if (value == 'clear_completed') {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Supprimer les commandes terminées ?'),
                      content: const Text(
                        'Voulez-vous supprimer toutes les commandes livrées et annulées ?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Annuler'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await orderProvider.clearCompletedOrders();
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Commandes terminées supprimées'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('Supprimer',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_completed',
                  child: Row(
                    children: [
                      Icon(Icons.cleaning_services, size: 20),
                      SizedBox(width: 8),
                      Text('Supprimer les terminées'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Vider l\'historique',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      // #28 — Empty state animé + #32 — Pull-to-refresh
      body: orderProvider.orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 100,
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.08, 1.08),
                      duration: 1500.ms),
                  const SizedBox(height: 24),
                  Text(
                    'Aucune commande',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Vos commandes apparaîtront ici',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[600] : Colors.grey[500],
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                ],
              ),
            )
          : RefreshIndicator(
              color: Colors.brown[700],
              onRefresh: () async {
                HapticFeedback.mediumImpact(); // #31
                await orderProvider.loadOrders();
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: orderProvider.orders.length,
                itemBuilder: (context, index) {
                  final order = orderProvider.orders[index];
                  final orderNumber = orderProvider.orders.length - index;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 3,
                    color: isDark ? const Color(0xFF1E1E1E) : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _getStatusColors(order.status),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.3),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            order.getStatusIcon(),
                                            style: const TextStyle(fontSize: 24),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Commande $orderNumber',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                DateFormat('dd/MM/yyyy à HH:mm')
                                                    .format(order.dateTime),
                                                style: TextStyle(
                                                  color:
                                                      Colors.white.withValues(alpha: 0.9),
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      '${order.totalAmount.toStringAsFixed(2)} ${AppConstants.currency}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Badge de statut
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  order.status.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              if (order.status != OrderStatus.delivered &&
                                  order.status != OrderStatus.cancelled) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              'Temps restant: ${order.remainingMinutes.toString().padLeft(2, '0')}:${order.remainingSeconds.toString().padLeft(2, '0')}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.5,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (order.status == OrderStatus.cancelled)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 16),
                                          child: Center(
                                            child: Text('Commande annulée', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                                          ),
                                        )
                                      else ...[
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildTimelineStep(Icons.receipt_long, 'Reçue', order.status.index >= OrderStatus.pending.index),
                                            _buildTimelineLine(order.status.index >= OrderStatus.preparing.index),
                                            _buildTimelineStep(Icons.soup_kitchen, 'Prépa', order.status.index >= OrderStatus.preparing.index),
                                            _buildTimelineLine(order.status.index >= OrderStatus.delivering.index),
                                            _buildTimelineStep(Icons.delivery_dining, 'En route', order.status.index >= OrderStatus.delivering.index),
                                            _buildTimelineLine(order.status.index >= OrderStatus.delivered.index),
                                            _buildTimelineStep(Icons.check_circle, 'Livré', order.status.index >= OrderStatus.delivered.index),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 12),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getStatusActionIcon(order.status),
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        order.getStatusMessage(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // BOUTONS ANNULER / SUPPRIMER / RE-COMMANDER
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  // Bouton ANNULER (pour commandes en cours)
                                  if (order.canCancel)
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () =>
                                            _showCancelDialog(context, order),
                                        icon: const Icon(Icons.cancel_outlined,
                                            size: 18),
                                        label: const Text('Annuler'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),

                                  // Bouton SUPPRIMER (pour commandes terminées)
                                  if (order.isCompleted) ...[
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () =>
                                            _showDeleteDialog(context, order),
                                        icon: const Icon(Icons.delete_outline,
                                            size: 18),
                                        label: const Text('Supprimer'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // #23 — Bouton Re-commander
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _handleReorder(context, order),
                                        icon:
                                            const Icon(Icons.replay, size: 18),
                                        label: const Text('Re-commander'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor:
                                              _getStatusColors(order.status)[1],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          title: Text(
                            'Voir les détails',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          children: [
                            Divider(
                                height: 1,
                                color: isDark ? const Color(0xFF3E3E3E) : null),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Articles commandés :',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ...order.items.map((item) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${item.quantity}x ${item.foodItem.name}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDark
                                                      ? Colors.grey[300]
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${item.totalPrice.toStringAsFixed(2)} ${AppConstants.currency}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  Divider(
                                      color: isDark
                                          ? const Color(0xFF3E3E3E)
                                          : null),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Informations de livraison :',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildInfoRow(
                                      Icons.person, order.customerName, isDark),
                                  _buildInfoRow(
                                      Icons.phone, order.phone, isDark),
                                  _buildInfoRow(
                                      Icons.location_on, order.address, isDark),
                                  _buildInfoRow(
                                      Icons.location_city, order.city, isDark),
                                  _buildInfoRow(Icons.payment,
                                      order.paymentMethod, isDark),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ), // Close RefreshIndicator
    );
  }

  IconData _getStatusActionIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.delivering:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: isDark ? Colors.grey[500] : Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[300] : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isActive ? Colors.brown[700] : Colors.white.withValues(alpha: 0.5), size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
            fontSize: 9,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTimelineLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        alignment: Alignment.topCenter,
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.2),
      ),
    );
  }
}
