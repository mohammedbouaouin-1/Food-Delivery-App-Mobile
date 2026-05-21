import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../models/food_item.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/review_provider.dart';

/// Page de détails d'un plat avec Hero animation (Amélioration #8)
class FoodDetailScreen extends StatefulWidget {
  final FoodItem foodItem;

  const FoodDetailScreen({super.key, required this.foodItem});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final foodItem = widget.foodItem;
    final cartProvider = Provider.of<CartProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isInCart = cartProvider.isInCart(foodItem.id);
    final quantity = cartProvider.getItemQuantity(foodItem.id);
    final isFavorite = favoritesProvider.isFavorite(foodItem.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar avec image Hero
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.brown[700],
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'food_image_${foodItem.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      foodItem.image,
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                    // Badges en haut
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 60,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: foodItem.badges.map((badge) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(badge,
                                style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                      ),
                    ),
                    // Nom et prix en bas
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            foodItem.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red[600],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  foodItem.formattedPrice,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${foodItem.rating} (${foodItem.reviewCount} avis)',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              // Bouton partager (#9)
              IconButton(
                onPressed: () {
                  Share.share(
                    '🍽️ ${foodItem.name}\n'
                    '💰 ${foodItem.formattedPrice}\n'
                    '⭐ ${foodItem.rating}/5\n'
                    '📝 ${foodItem.description}\n\n'
                    'Commandez sur BOUAOUIN ! 🚀',
                  );
                },
                icon: const Icon(Icons.share, color: Colors.white),
              ),
              // Bouton favori
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  favoritesProvider.toggleFavorite(foodItem.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite
                            ? '${foodItem.name} retiré des favoris'
                            : '${foodItem.name} ajouté aux favoris ❤️',
                      ),
                      duration: const Duration(milliseconds: 1200),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
              ),
            ],
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Infos rapides
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.access_time,
                        '${foodItem.preparationTime} min',
                        Colors.blue,
                        isDark,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.local_fire_department,
                        '${foodItem.calories} cal',
                        Colors.orange,
                        isDark,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.category,
                        foodItem.category,
                        Colors.green,
                        isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    foodItem.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 24),

                  // Ingrédients
                  if (foodItem.ingredients.isNotEmpty) ...[
                    Text(
                      'Ingrédients',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: foodItem.ingredients.map((ingredient) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.brown[800]
                                : Colors.brown[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? Colors.brown[600]!
                                  : Colors.brown[200]!,
                            ),
                          ),
                          child: Text(
                            ingredient,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.brown[200]
                                  : Colors.brown[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Section avis clients
                  Consumer<ReviewProvider>(
                    builder: (context, reviewProvider, _) {
                      final reviews = reviewProvider.getReviews(foodItem.id);
                      final avgRating = reviewProvider.getAverageRating(foodItem.id);
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Avis clients',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (reviews.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star, color: Colors.amber, size: 14),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${avgRating.toStringAsFixed(1)} (${reviews.length})',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.amber : Colors.amber[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                onPressed: () => _showAddReviewDialog(context, foodItem.id, isDark),
                                icon: Icon(Icons.rate_review, size: 22, color: Colors.brown[700]),
                                tooltip: 'Donner un avis',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (reviews.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF3E3E3E) : Colors.grey[200]!,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.rate_review_outlined, size: 40, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Aucun avis pour le moment',
                                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Soyez le premier à donner votre avis !',
                                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...reviews.map((review) => _buildReviewCard(
                              review.userName,
                              review.rating,
                              review.comment,
                              review.formattedDate,
                              isDark,
                            )),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 100), // Espace pour le bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Bar - Ajouter au panier (amélioré)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.grey.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Prix avec badge
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prix unitaire',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            foodItem.formattedPrice,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.brown[800],
                            ),
                          ),
                          if (isInCart) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                '×$quantity',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Bouton
              isInCart
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.brown[700]!, Colors.brown[600]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                cartProvider.decreaseQuantity(foodItem.id),
                            icon:
                                const Icon(Icons.remove, color: Colors.white),
                            iconSize: 22,
                          ),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              quantity.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                cartProvider.increaseQuantity(foodItem.id),
                            icon: const Icon(Icons.add, color: Colors.white),
                            iconSize: 22,
                          ),
                        ],
                      ),
                    )
                  : Flexible(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            cartProvider.addItem(foodItem);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.white),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                          '${foodItem.name} ajouté au panier'),
                                    ),
                                  ],
                                ),
                                duration: const Duration(milliseconds: 1500),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart, size: 20),
                          label: const Text(
                            'Ajouter',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: Colors.brown.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ).animate().slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildInfoChip(
      IconData icon, String label, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(
    String name,
    double rating,
    String comment,
    String date,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3E3E3E) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.brown[100],
                child: Text(
                  name[0],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[700],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.floor()
                        ? Icons.star
                        : (index < rating ? Icons.star_half : Icons.star_border),
                    color: Colors.amber,
                    size: 14,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context, String foodItemId, bool isDark) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Connectez-vous pour laisser un avis'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final userId = user.uid;
    final userName = authProvider.userProfile.name.isNotEmpty 
        ? authProvider.userProfile.name 
        : (user.displayName ?? 'Utilisateur');
    
    if (reviewProvider.hasUserReviewed(foodItemId, userId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Vous avez déjà donné votre avis'),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _AddReviewBottomSheet(
          foodItemId: foodItemId,
          userId: userId,
          userName: userName,
          isDark: isDark,
          reviewProvider: reviewProvider,
        );
      },
    );
  }
}

class _AddReviewBottomSheet extends StatefulWidget {
  final String foodItemId;
  final String userId;
  final String userName;
  final bool isDark;
  final ReviewProvider reviewProvider;

  const _AddReviewBottomSheet({
    required this.foodItemId,
    required this.userId,
    required this.userName,
    required this.isDark,
    required this.reviewProvider,
  });

  @override
  State<_AddReviewBottomSheet> createState() => _AddReviewBottomSheetState();
}

class _AddReviewBottomSheetState extends State<_AddReviewBottomSheet> {
  double _selectedRating = 4.0;
  late final TextEditingController _commentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Donner votre avis',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Partagez votre expérience avec ce plat',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),

            // Étoiles
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final starValue = index + 1.0;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedRating = starValue),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        index < _selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _selectedRating >= 5 ? 'Excellent !' 
                    : _selectedRating >= 4 ? 'Très bien !'
                    : _selectedRating >= 3 ? 'Bien'
                    : _selectedRating >= 2 ? 'Moyen'
                    : 'Pas terrible',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber[700],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Commentaire
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Écrivez votre commentaire...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.brown[700]!, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bouton envoyer
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : () async {
                  if (_commentController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez écrire un commentaire'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  setState(() => _isSubmitting = true);

                  // Simuler une petite latence réseau pour l'UX (Amélioration #145: loader de soumission)
                  await Future.delayed(const Duration(milliseconds: 800));

                  await widget.reviewProvider.addReview(
                    foodItemId: widget.foodItemId,
                    userId: widget.userId,
                    userName: widget.userName,
                    rating: _selectedRating,
                    comment: _commentController.text.trim(),
                  );
                  
                  if (!context.mounted) return;
                  setState(() => _isSubmitting = false);
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Merci pour votre avis !'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                icon: _isSubmitting 
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send, size: 18),
                label: Text(
                  _isSubmitting ? 'Publication...' : 'Publier l\'avis',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
