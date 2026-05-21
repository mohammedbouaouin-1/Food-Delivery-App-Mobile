import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../models/food_item.dart';
import '../data/menu_data.dart';
import '../data/app_constants.dart';
import 'food_detail_screen.dart';
import 'food_search_delegate.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'Pizza';
  late AnimationController _fabAnimationController;
  late PageController _promoPageController;
  bool _showFab = false;

  final Map<String, GlobalKey> _categoryKeys = {
    'Pizza': GlobalKey(),
    'Tacos': GlobalKey(),
    'Salades': GlobalKey(),
    'Boissons': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _promoPageController = PageController(viewportFraction: 0.9);
    
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showFab) {
        setState(() => _showFab = true);
        _fabAnimationController.forward();
      } else if (_scrollController.offset <= 200 && _showFab) {
        setState(() => _showFab = false);
        _fabAnimationController.reverse();
      }
    });
  }

  void _scrollToCategory(String category) {
    setState(() => _selectedCategory = category);
    final keyContext = _categoryKeys[category]?.currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _promoPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: (isDark ? const Color(0xFF1E1E1E) : Colors.brown[700]!).withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: const Text('Menu', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: FoodSearchDelegate(MenuData.allItems, cartProvider),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: MenuData.categories.map((cat) {
                final isLast = cat == MenuData.categories.last;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 6),
                    child: _buildCategoryTab(cat['label']!, cat['key']!, isDark),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 60), // Add padding for the AppBar
                  
                  // Search Bar Explicite
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: GestureDetector(
                      onTap: () {
                        showSearch(
                          context: context,
                          delegate: FoodSearchDelegate(MenuData.allItems, cartProvider),
                        );
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: isDark ? const Color(0xFF3E3E3E) : Colors.grey[200]!,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey[500]),
                            const SizedBox(width: 12),
                            Text(
                              'Que voulez-vous manger ?',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                  ),
                  
                  // #7 — Note globale du restaurant
                  _buildGlobalRating(isDark),

                  // #25 — Bannières promotionnelles
                  _buildPromoBanners(isDark),
                  _buildCategorySection('Nos Pizzas', MenuData.pizzas, 'Pizza', isDark),
                  _buildCategorySection('Nos Tacos', MenuData.tacos, 'Tacos', isDark),
                  _buildCategorySection('Nos Salades', MenuData.salades, 'Salades', isDark),
                  _buildCategorySection('Nos Boissons', MenuData.boissons, 'Boissons', isDark),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimationController,
        child: FloatingActionButton(
          onPressed: () => _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          ),
          backgroundColor: Colors.brown[700],
          child: const Icon(Icons.arrow_upward, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCategoryTab(String label, String category, bool isDark) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => _scrollToCategory(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.brown[800] : Colors.brown[600]),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.brown[700] : Colors.white,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, List<FoodItem> items, String category, bool isDark) {
    return Container(
      key: _categoryKeys[category],
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.brown[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildFoodCard(context, item, isDark)
                .animate()
                .fadeIn(
                  duration: 400.ms,
                  delay: (100 * index).ms,
                )
                .slideX(
                  begin: 0.05,
                  end: 0,
                  duration: 400.ms,
                  delay: (100 * index).ms,
                  curve: Curves.easeOut,
                );
          }),
        ],
      ),
    );
  }

  Widget _buildFoodCard(BuildContext context, FoodItem foodItem, bool isDark) {
    return GestureDetector(
      onTap: () {
        // #8 — Transition slide-up
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                FoodDetailScreen(foodItem: foodItem),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                // Image avec Hero + Shimmer loading (#22)
                Hero(
                  tag: 'food_image_${foodItem.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.asset(
                      foodItem.image,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) return child;
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: frame != null
                              ? child
                              : Shimmer.fromColors(
                                  baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                                  highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                                  child: Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: Colors.white,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ),

                // Temps de préparation
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${foodItem.preparationTime} min',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bouton favori
                Positioned(
                  top: 12,
                  right: 12,
                  child: Consumer<FavoritesProvider>(
                    builder: (context, favoritesProvider, child) {
                      final isFavorite = favoritesProvider.isFavorite(foodItem.id);
                      return GestureDetector(
                        onTap: () {
                          favoritesProvider.toggleFavorite(foodItem.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Badges
                if (foodItem.badges.isNotEmpty)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Row(
                      children: foodItem.badges.map((badge) {
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          foodItem.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            foodItem.rating.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            ' (${foodItem.reviewCount})',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Text(
                    foodItem.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Icon(Icons.local_fire_department, 
                           color: Colors.orange[700], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${foodItem.calories} cal',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        foodItem.formattedPrice,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[600],
                        ),
                      ),
                      
                      Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          final isInCart = cartProvider.isInCart(foodItem.id);
                          final quantity = cartProvider.getItemQuantity(foodItem.id);
                          return isInCart
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.brown[700],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          cartProvider.decreaseQuantity(foodItem.id);
                                        },
                                        icon: const Icon(Icons.remove, color: Colors.white),
                                        iconSize: 20,
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                      ),
                                      
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          quantity.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      
                                      IconButton(
                                        onPressed: () {
                                          cartProvider.increaseQuantity(foodItem.id);
                                        },
                                        icon: const Icon(Icons.add, color: Colors.white),
                                        iconSize: 20,
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: () {
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
                                                '${foodItem.name} ajouté au panier',
                                              ),
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
                                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                                  label: const Text(
                                    'Ajouter',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown[700],
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // #7 — Note globale du restaurant
  Widget _buildGlobalRating(bool isDark) {
    // Calculer la note moyenne globale
    final allItems = MenuData.allItems;
    final avgRating = allItems.fold(0.0, (sum, item) => sum + item.rating) / allItems.length;
    final totalReviews = allItems.fold(0, (sum, item) => sum + item.reviewCount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF3E3E3E) : Colors.amber.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, color: Colors.amber, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      ...List.generate(5, (index) {
                        if (index < avgRating.floor()) {
                          return const Icon(Icons.star, color: Colors.amber, size: 16);
                        } else if (index < avgRating.ceil() && avgRating % 1 > 0.3) {
                          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
                        }
                        return Icon(Icons.star_border, color: Colors.grey[400], size: 16);
                      }),
                    ],
                  ),
                  Text(
                    '$totalReviews avis clients',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppConstants.ratingLabel(avgRating),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  // #25 — Bannières promotionnelles
  Widget _buildPromoBanners(bool isDark) {
    final banners = [
      {
        'title': '🔥 -20% sur les Pizzas',
        'subtitle': 'Offre limitée ce week-end',
        'gradient': [const Color(0xFFE53935), const Color(0xFFFF7043)],
        'icon': Icons.local_pizza,
      },
      {
        'title': '🆕 Nouveau : Tacos Mixte',
        'subtitle': 'Découvrez notre best-seller',
        'gradient': [const Color(0xFF6D4C41), const Color(0xFFA1887F)],
        'icon': Icons.restaurant,
      },
      {
        'title': '🚀 Livraison gratuite',
        'subtitle': 'Dès 80 MAD de commande',
        'gradient': [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
        'icon': Icons.delivery_dining,
      },
    ];

    return SizedBox(
      height: 140,
      child: PageView.builder(
        itemCount: banners.length,
        controller: _promoPageController,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: banner['gradient'] as List<Color>,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (banner['gradient'] as List<Color>)[0].withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          banner['title'] as String,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          banner['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      banner['icon'] as IconData,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: (200 * index).ms)
              .slideX(begin: 0.1, end: 0, duration: 400.ms);
        },
      ),
    );
  }
}
