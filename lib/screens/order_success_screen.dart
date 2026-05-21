import 'package:flutter/material.dart';
import 'main_navigation_screen.dart';

/// Écran de succès après commande (Amélioration #10)
class OrderSuccessScreen extends StatefulWidget {
  final String orderNumber;
  final double totalAmount;
  final String paymentMethod;

  const OrderSuccessScreen({
    super.key,
    required this.orderNumber,
    required this.totalAmount,
    required this.paymentMethod,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _contentController;
  late Animation<double> _checkScale;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    // Démarrer les animations
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _checkController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                
                // Icône de succès animée
                ScaleTransition(
                  scale: _checkScale,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[400]!, Colors.green[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Contenu avec slide animation
                SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                    opacity: _contentOpacity,
                    child: Column(
                      children: [
                        Text(
                          'Commande confirmée !',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Merci pour votre commande. Votre repas est en cours de préparation.',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Détails de la commande
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF3E3E3E)
                                  : Colors.grey[200]!,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                'N° Commande',
                                '#${widget.orderNumber}',
                                isDark,
                                isBold: true,
                              ),
                              const Divider(height: 24),
                              _buildDetailRow(
                                'Paiement',
                                widget.paymentMethod,
                                isDark,
                              ),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                'Temps estimé',
                                '~30 min',
                                isDark,
                              ),
                              const Divider(height: 24),
                              _buildDetailRow(
                                'Total',
                                '${widget.totalAmount.toStringAsFixed(2)} MAD',
                                isDark,
                                isBold: true,
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Bouton suivre commande
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Naviguer vers l'onglet Commandes (index 3)
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const MainNavigationScreen(initialIndex: 3),
                                ),
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.receipt_long),
                            label: const Text(
                              'SUIVRE MA COMMANDE',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Bouton retour au menu
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Naviguer vers l'onglet Menu (index 0)
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const MainNavigationScreen(initialIndex: 0),
                                ),
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.restaurant_menu),
                            label: const Text(
                              'RETOUR AU MENU',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.brown[700],
                              side: BorderSide(color: Colors.brown[700]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 22 : (isBold ? 16 : 14),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isTotal
                ? Colors.red[600]
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }
}
