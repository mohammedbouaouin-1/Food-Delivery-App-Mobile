import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/favorites_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/locale_provider.dart';
import '../data/menu_data.dart';
import '../models/food_item.dart';
import 'food_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final favoriteItems = favoritesProvider.getFavoriteItems(MenuData.allItems);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${localeProvider.translate('favorites_title')} (${favoriteItems.length})'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          if (favoriteItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.orange, size: 22),
                        const SizedBox(width: 8),
                        Text(localeProvider.translate('clear_favorites_title'),
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    content: Text(
                        localeProvider.translate('clear_favorites_confirm')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(localeProvider.translate('no')),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          favoritesProvider.clearFavorites();
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: Text(localeProvider.translate('clear'),
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: favoriteItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                          size: 100,
                          color: isDark ? Colors.grey[700] : Colors.grey[300])
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                          duration: 1500.ms)
                      .then()
                      .shake(hz: 2, duration: 500.ms),
                  const SizedBox(height: 24),
                  Text(
                    localeProvider.translate('empty_favorites_title'),
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
                    localeProvider.translate('empty_favorites_subtitle'),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[600] : Colors.grey[500],
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: favoriteItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (context, index) {
                final item = favoriteItems[index];
                return _buildFavoriteGridCard(
                  context,
                  item,
                  favoritesProvider,
                  cartProvider,
                  isDark,
                );
              },
            ),
    );
  }

  Widget _buildFavoriteGridCard(
    BuildContext context,
    FoodItem item,
    FavoritesProvider favoritesProvider,
    CartProvider cartProvider,
    bool isDark,
  ) {
    final isInCart = cartProvider.isInCart(item.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(foodItem: item),
          ),
        );
      },
      child: Card(
        elevation: 3,
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'food_image_${item.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.asset(
                      item.image,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black54
                          : Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      onPressed: () {
                        final localeProv =
                            Provider.of<LocaleProvider>(context, listen: false);
                        favoritesProvider.removeFavorite(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${item.name} ${localeProv.translate('item_removed_favorites')}'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            action: SnackBarAction(
                              label: localeProv.translate('undo'),
                              onPressed: () =>
                                  favoritesProvider.toggleFavorite(item.id),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      iconSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              '${item.rating}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.access_time,
                                size: 12, color: Colors.grey[550]),
                            const SizedBox(width: 2),
                            Text(
                              '${item.preparationTime} min',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            item.formattedPrice,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          onPressed: () {
                            if (!isInCart) {
                              final localeProv = Provider.of<LocaleProvider>(
                                  context,
                                  listen: false);
                              cartProvider.addItem(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${item.name} ${localeProv.translate('added_to_cart')}'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  duration: const Duration(milliseconds: 1200),
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            isInCart
                                ? Icons.check_circle
                                : Icons.add_shopping_cart,
                            color: isInCart ? Colors.green : Colors.brown[700],
                          ),
                          iconSize: 20,
                        ),
                      ],
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
