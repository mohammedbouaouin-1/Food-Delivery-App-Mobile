import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';
import '../providers/cart_provider.dart';
import 'food_detail_screen.dart';

/// Recherche redesignée avec grille
class FoodSearchDelegate extends SearchDelegate<FoodItem?> {
  final List<FoodItem> items;
  final CartProvider cartProvider;
  List<String> _searchHistory = [];

  FoodSearchDelegate(this.items, this.cartProvider) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory = prefs.getStringList('search_history') ?? [];
  }

  Future<void> _saveSearch(String term) async {
    if (term.trim().isEmpty) return;
    _searchHistory.remove(term);
    _searchHistory.insert(0, term);
    if (_searchHistory.length > 8) _searchHistory = _searchHistory.sublist(0, 8);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', _searchHistory);
  }

  Future<void> _clearHistory() async {
    _searchHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
  }

  @override
  String get searchFieldLabel => 'Rechercher un plat...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _saveSearch(query);
    final results = items
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildResultsGrid(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (query.isEmpty) {
      // Afficher historique + populaires
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recherches récentes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _clearHistory();
                    query = query; // force rebuild
                  },
                  child: Text('Effacer', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory.map((term) {
                return ActionChip(
                  avatar: Icon(Icons.history, size: 16, color: Colors.grey[500]),
                  label: Text(term, style: const TextStyle(fontSize: 13)),
                  onPressed: () => query = term,
                  backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            '🔥 Les plus populaires',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...items.take(5).map((item) => ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(item.image, width: 50, height: 50, fit: BoxFit.cover),
                ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  item.formattedPrice,
                  style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  close(context, null);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FoodDetailScreen(foodItem: item)),
                  );
                },
              )),
        ],
      );
    }

    final suggestions = items
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildResultsGrid(context, suggestions);
  }

  Widget _buildResultsGrid(BuildContext context, List<FoodItem> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80,
                color: isDark ? Colors.grey[600] : Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat pour "$query"',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.grey[400] : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez un autre terme',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[600] : Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isInCart = cartProvider.isInCart(item.id);

        return GestureDetector(
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDetailScreen(foodItem: item),
              ),
            );
          },
          child: Card(
            elevation: 3,
            color: isDark ? const Color(0xFF1E1E1E) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'food_image_${item.id}',
                          child: Image.asset(
                            item.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 14),
                                const SizedBox(width: 2),
                                Text(
                                  '${item.rating}',
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
                      ],
                    ),
                  ),
                ),
                // Infos
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.formattedPrice,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[600],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (!isInCart) {
                                    cartProvider.addItem(item);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${item.name} ajouté ✓'),
                                        backgroundColor: Colors.green,
                                        duration: const Duration(milliseconds: 1000),
                                      ),
                                    );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isInCart
                                      ? Colors.green
                                      : Colors.brown[700],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isInCart ? Icons.check : Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
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
      },
    );
  }
}
