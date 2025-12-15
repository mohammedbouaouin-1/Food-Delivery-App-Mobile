import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/food_item.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'Pizza';
  final String _searchQuery = '';
  late AnimationController _fabAnimationController;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    final List<FoodItem> pizzas = [
      FoodItem(
        id: '1',
        name: 'Pizza Pepperoni',
        price: 45.0,
        image: 'images/peperoni.jpeg',
        description: 'Une pizza généreuse avec sauce tomate parfumée, mozzarella fondante et tranches de pepperoni grillées à la perfection. Chaque bouchée est un mélange de saveurs relevées et gourmandes, idéale pour les amateurs de goût intense.',
        category: 'Pizza',
        preparationTime: 15,
        rating: 4.7,
        reviewCount: 128,
        calories: 285,
        isSpicy: true,
      ),
      FoodItem(
        id: '2',
        name: 'Pizza 4 Fromages',
        price: 55.0,
        image: 'images/pizza-Quatre-fromages.webp',
        description: 'Une combinaison crémeuse de mozzarella, emmental, parmesan et bleu, fondue sur une pâte croustillante. Une expérience fromagère riche et onctueuse qui ravira les palais des amateurs de fromage.',
        category: 'Pizza',
        preparationTime: 18,
        rating: 4.8,
        reviewCount: 95,
        calories: 320,
        isVegetarian: true,
      ),
      FoodItem(
        id: '3',
        name: 'Pizza Margherita',
        price: 40.0,
        image: 'images/pizza-Margarita.webp',
        description: 'La classique Margherita avec sa sauce tomate délicate, mozzarella fondante et basilic frais. Une pizza simple mais élégante qui capture l’essence de l’Italie à chaque bouchée.',
        category: 'Pizza',
        preparationTime: 12,
        rating: 4.6,
        reviewCount: 156,
        calories: 250,
        isVegetarian: true,
      ),
      FoodItem(
        id: '4',
        name: 'Pizza 4 Saisons',
        price: 60.0,
        image: 'images/pizza-quatre-saisons.jpg',
        description: 'Une pizza riche et équilibrée avec jambon, champignons, olives et artichauts, chaque portion apportant une combinaison parfaite de textures et de saveurs qui change à chaque bouchée.',
        category: 'Pizza',
        preparationTime: 20,
        rating: 4.5,
        reviewCount: 87,
        calories: 295,
      ),
      FoodItem(
        id: '5',
        name: 'Pizza Fruits de Mer',
        price: 65.0,
        image: 'images/pizza-aux-fruits-de-mer.jpg',
        description: 'Une explosion de saveurs marines avec crevettes, calamars et poisson frais sur une base parfaitement cuite. Idéale pour les amoureux de fruits de mer à la recherche d’un goût authentique et savoureux.',
        category: 'Pizza',
        preparationTime: 22,
        rating: 4.9,
        reviewCount: 73,
        calories: 270,
      ),
    ];

    final List<FoodItem> tacos = [
      FoodItem(
        id: '6',
        name: 'Tacos Poulet',
        price: 30.0,
        image: 'images/tacos-de-poulet.jpeg',
        description: 'Tacos généreux avec poulet tendre, frites croustillantes et fromage fondant, accompagnés de sauces au choix. Un en-cas gourmand et réconfortant qui séduira tous les appétits.',
        category: 'Tacos',
        preparationTime: 10,
        rating: 4.6,
        reviewCount: 142,
        calories: 450,
      ),
      FoodItem(
        id: '7',
        name: 'Tacos Viande Hachée',
        price: 30.0,
        image: 'images/tacos-viande-hachee.webp',
        description: 'Viande hachée épicée, frites et fromage fondant, enveloppés dans une galette chaude. Une expérience riche et savoureuse pour les amateurs de plats relevés.',
        category: 'Tacos',
        preparationTime: 10,
        rating: 4.5,
        reviewCount: 98,
        calories: 480,
        isSpicy: true,
      ),
      FoodItem(
        id: '8',
        name: 'Tacos Mixte',
        price: 35.0,
        image: 'images/tacos-mixte.webp',
        description: 'Le meilleur des deux mondes : poulet et viande hachée, frites et fromage fondant dans une galette parfaitement chaude. Une bouchée équilibrée et savoureuse qui combine textures et goûts.',
        category: 'Tacos',
        preparationTime: 12,
        rating: 4.8,
        reviewCount: 165,
        calories: 520,
        isSpicy: true,
      ),
    ];

    final List<FoodItem> salades = [
      FoodItem(
        id: '9',
        name: 'Salade Marocaine aux Aubergines',
        price: 15.0,
        image: 'images/salade aubergine.jpeg',
        description: 'Aubergines fondantes mélangées à des épices douces et un filet d’huile d’olive. Une salade légère, savoureuse et authentique qui évoque les saveurs traditionnelles marocaines.',
        category: 'Salades',
        preparationTime: 8,
        rating: 4.4,
        reviewCount: 56,
        calories: 120,
        isVegetarian: true,
      ),
      FoodItem(
        id: '10',
        name: 'Salade Concombre et Tomates',
        price: 15.0,
        image: 'images/concombre tomate.jpeg',
        description: 'Salade fraîche et croquante avec concombre et tomates, assaisonnée d’un filet de citron. Idéale pour accompagner vos plats principaux ou pour un déjeuner léger et rafraîchissant.',
        category: 'Salades',
        preparationTime: 5,
        rating: 4.3,
        reviewCount: 78,
        calories: 80,
        isVegetarian: true,
      ),
      FoodItem(
        id: '11',
        name: 'Salade Marocaine aux Carottes',
        price: 15.0,
        image: 'images/carrote.jpg',
        description: 'Carottes fondantes avec une touche de coriandre fraîche et d’épices douces. Une salade simple mais savoureuse, pleine de couleur et de fraîcheur.',
        category: 'Salades',
        preparationTime: 7,
        rating: 4.5,
        reviewCount: 92,
        calories: 100,
        isVegetarian: true,
      ),
      FoodItem(
        id: '12',
        name: 'Salade de Pommes de Terre',
        price: 15.0,
        image: 'images/pomme de terre.jpeg',
        description: 'Pommes de terre onctueuses accompagnées d’oignons et d’herbes fraîches. Une salade douce et réconfortante, parfaite pour compléter un repas copieux.',
        category: 'Salades',
        preparationTime: 10,
        rating: 4.2,
        reviewCount: 64,
        calories: 180,
        isVegetarian: true,
      ),
    ];

    final List<FoodItem> boissons = [
      FoodItem(
        id: '13',
        name: 'Coca-Cola',
        price: 6.0,
        image: 'images/coca-cola.jpg',
        description: 'La boisson iconique aux bulles pétillantes et au goût inimitable. Servie bien fraîche avec des glaçons, elle accompagne parfaitement votre repas pour une sensation de pure rafraîchissement à chaque gorgée.',
        category: 'Boissons',
        preparationTime: 1,
        rating: 4.6,
        reviewCount: 245,
        calories: 139,
      ),
      FoodItem(
        id: '14',
        name: 'Coca-Cola Zéro',
        price: 6.0,
        image: 'images/coca-zero.jpg',
        description: 'Savourez le goût classique du Coca-Cola sans aucune calorie. Une alternative légère et rafraîchissante, idéale pour profiter pleinement de votre repas sans compromis sur le goût.',
        category: 'Boissons',
        preparationTime: 1,
        rating: 4.5,
        reviewCount: 198,
        calories: 0,
      ),
      FoodItem(
        id: '15',
        name: 'Fanta Orange',
        price: 5.0,
        image: 'images/fanta.jpg',
        description: 'Explosion de saveur fruitée ! Cette boisson pétillante à l’orange apporte une touche de douceur et de fraîcheur à votre repas. Les bulles légères et le goût fruité séduiront petits et grands.',
        category: 'Boissons',
        preparationTime: 1,
        rating: 4.4,
        reviewCount: 167,
        calories: 145,
      ),
      FoodItem(
        id: '16',
        name: 'Sprite',
        price: 6.0,
        image: 'images/sprite.jpg',
        description: 'Fraîcheur ultime avec cette boisson citron-lime pétillante. Désaltère instantanément et nettoie le palais entre chaque bouchée savoureuse, parfaite pour vos repas gourmands.',
        category: 'Boissons',
        preparationTime: 1,
        rating: 4.5,
        reviewCount: 189,
        calories: 142,
      ),
      FoodItem(
        id: '17',
        name: 'Eau Minirale ( Sidi Ali )',
        price: 4.0,
        image: 'images/eau-minerale.jpg',
        description: 'Pure et naturelle, cette eau minérale provient de sources protégées et hydrate parfaitement vos plats sans en altérer les saveurs. Riche en minéraux essentiels, c’est le choix santé par excellence.',
        category: 'Boissons',
        preparationTime: 1,
        rating: 4.7,
        reviewCount: 312,
        calories: 0,
      ),
      FoodItem(
        id: '18',
        name: 'Jus d\'Orange Frais',
        price: 8.0,
        image: 'images/jus-orange.webp',
        description: 'Oranges pressées à la minute pour conserver toute la fraîcheur et les vitamines. 100% pur jus, sans sucre ajouté, un goût naturellement sucré et acidulé pour une boisson vitaminée et revitalisante.',
        category: 'Boissons',
        preparationTime: 3,
        rating: 4.9,
        reviewCount: 276,
        calories: 110,
      ),
      FoodItem(
        id: '20',
        name: 'Thé Glacé Pêche',
        price: 9.0,
        image: 'images/ice-tea.webp',
        description: 'Thé infusé délicat associé à la douceur veloutée de la pêche. Servi glacé avec une pointe de citron, il désaltère tout en ajoutant une touche fruitée à votre repas.',
        category: 'Boissons',
        preparationTime: 1,
        rating: 4.3,
        reviewCount: 156,
        calories: 120,
      ),
    ];

    final allItems = [...pizzas, ...tacos, ...salades, ...boissons];
    final filteredItems = _searchQuery.isEmpty
        ? allItems
        : allItems.where((item) =>
            item.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Menu', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: FoodSearchDelegate(allItems, cartProvider),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.brown[700],
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(child: _buildCategoryTab('🍕 Pizza', 'Pizza')),
                const SizedBox(width: 6),
                Expanded(child: _buildCategoryTab('🌮 Tacos', 'Tacos')),
                const SizedBox(width: 6),
                Expanded(child: _buildCategoryTab('🥗 Salades', 'Salades')),
                const SizedBox(width: 6),
                Expanded(child: _buildCategoryTab('🥤 Boissons', 'Boissons')),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildCategorySection('Nos Pizzas', pizzas, 'Pizza'),
                  _buildCategorySection('Nos Tacos', tacos, 'Tacos'),
                  _buildCategorySection('Nos Salades', salades, 'Salades'),
                  _buildCategorySection('Nos Boissons', boissons, 'Boissons'),
                  const SizedBox(height: 80),
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

  Widget _buildCategoryTab(String label, String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => _scrollToCategory(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.brown[600],
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
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

  Widget _buildCategorySection(String title, List<FoodItem> items, String category) {
    return Container(
      key: _categoryKeys[category],
      color: Colors.white,
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
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => _buildFoodCard(context, item)),
        ],
      ),
    );
  }

  Widget _buildFoodCard(BuildContext context, FoodItem foodItem) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isInCart = cartProvider.isInCart(foodItem.id);
    final quantity = cartProvider.getItemQuantity(foodItem.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [

              //  clic sur image
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: InteractiveViewer(
                        child: Image.asset(
                          foodItem.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
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
                  ),
                ),
              ),

              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
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

              if (foodItem.badges.isNotEmpty)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Column(
                    children: foodItem.badges.map((badge) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          foodItem.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                  maxLines: 6,
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
                    
                    isInCart
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
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//  recherche
class FoodSearchDelegate extends SearchDelegate<FoodItem?> {
  final List<FoodItem> items;
  final CartProvider cartProvider;

  FoodSearchDelegate(this.items, this.cartProvider);

  @override
  String get searchFieldLabel => 'Rechercher un plat...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
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
    final results = items
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildResultsList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? items
        : items
            .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return _buildResultsList(suggestions);
  }

  Widget _buildResultsList(List<FoodItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun résultat trouvé',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(item.name),
          subtitle: Text(item.formattedPrice),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            close(context, item);
          },
        );
      },
    );
  }
}
