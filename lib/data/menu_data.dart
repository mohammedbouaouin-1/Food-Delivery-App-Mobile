import '../models/food_item.dart';

class MenuData {
  static final List<FoodItem> pizzas = [
    const FoodItem(
      id: '1',
      name: 'Pizza Pepperoni',
      price: 45.0,
      image: 'images/peperoni.jpeg',
      description:
          'Une pizza généreuse avec sauce tomate parfumée, mozzarella fondante et tranches de pepperoni grillées à la perfection. Chaque bouchée est un mélange de saveurs relevées et gourmandes, idéale pour les amateurs de goût intense.',
      category: 'Pizza',
      preparationTime: 15,
      rating: 4.7,
      reviewCount: 128,
      calories: 285,
      isSpicy: true,
      ingredients: ['Sauce tomate', 'Mozzarella', 'Pepperoni', 'Origan'],
    ),
    const FoodItem(
      id: '2',
      name: 'Pizza 4 Fromages',
      price: 55.0,
      image: 'images/pizza-Quatre-fromages.webp',
      description:
          'Une combinaison crémeuse de mozzarella, emmental, parmesan et bleu, fondue sur une pâte croustillante. Une expérience fromagère riche et onctueuse qui ravira les palais des amateurs de fromage.',
      category: 'Pizza',
      preparationTime: 18,
      rating: 4.8,
      reviewCount: 95,
      calories: 320,
      isVegetarian: true,
      ingredients: ['Mozzarella', 'Emmental', 'Parmesan', 'Bleu'],
    ),
    const FoodItem(
      id: '3',
      name: 'Pizza Margherita',
      price: 40.0,
      image: 'images/pizza-Margarita.webp',
      description:
          'La classique Margherita avec sa sauce tomate délicate, mozzarella fondante et basilic frais. Une pizza simple mais élégante qui capture l\'essence de l\'Italie à chaque bouchée.',
      category: 'Pizza',
      preparationTime: 12,
      rating: 4.6,
      reviewCount: 156,
      calories: 250,
      isVegetarian: true,
      ingredients: [
        'Sauce tomate',
        'Mozzarella',
        'Basilic frais',
        'Huile d\'olive'
      ],
    ),
    const FoodItem(
      id: '4',
      name: 'Pizza 4 Saisons',
      price: 60.0,
      image: 'images/pizza-quatre-saisons.jpg',
      description:
          'Une pizza riche et équilibrée avec jambon, champignons, olives et artichauts, chaque portion apportant une combinaison parfaite de textures et de saveurs qui change à chaque bouchée.',
      category: 'Pizza',
      preparationTime: 20,
      rating: 4.5,
      reviewCount: 87,
      calories: 295,
      ingredients: ['Jambon', 'Champignons', 'Olives', 'Artichauts'],
    ),
    const FoodItem(
      id: '5',
      name: 'Pizza Fruits de Mer',
      price: 65.0,
      image: 'images/pizza-aux-fruits-de-mer.jpg',
      description:
          'Une explosion de saveurs marines avec crevettes, calamars et poisson frais sur une base parfaitement cuite. Idéale pour les amoureux de fruits de mer à la recherche d\'un goût authentique et savoureux.',
      category: 'Pizza',
      preparationTime: 22,
      rating: 4.9,
      reviewCount: 73,
      calories: 270,
      ingredients: ['Crevettes', 'Calamars', 'Poisson frais', 'Ail', 'Persil'],
    ),
  ];

  static final List<FoodItem> tacos = [
    const FoodItem(
      id: '6',
      name: 'Tacos Poulet',
      price: 30.0,
      image: 'images/tacos-de-poulet.jpeg',
      description:
          'Tacos généreux avec poulet tendre, frites croustillantes et fromage fondant, accompagnés de sauces au choix. Un en-cas gourmand et réconfortant qui séduira tous les appétits.',
      category: 'Tacos',
      preparationTime: 10,
      rating: 4.6,
      reviewCount: 142,
      calories: 450,
      ingredients: ['Poulet grillé', 'Frites', 'Fromage', 'Sauce au choix'],
    ),
    const FoodItem(
      id: '7',
      name: 'Tacos Viande Hachée',
      price: 30.0,
      image: 'images/tacos-viande-hachee.webp',
      description:
          'Viande hachée épicée, frites et fromage fondant, enveloppés dans une galette chaude. Une expérience riche et savoureuse pour les amateurs de plats relevés.',
      category: 'Tacos',
      preparationTime: 10,
      rating: 4.5,
      reviewCount: 98,
      calories: 480,
      isSpicy: true,
      ingredients: [
        'Viande hachée épicée',
        'Frites',
        'Fromage',
        'Sauce piquante'
      ],
    ),
    const FoodItem(
      id: '8',
      name: 'Tacos Mixte',
      price: 35.0,
      image: 'images/tacos-mixte.webp',
      description:
          'Le meilleur des deux mondes : poulet et viande hachée, frites et fromage fondant dans une galette parfaitement chaude. Une bouchée équilibrée et savoureuse qui combine textures et goûts.',
      category: 'Tacos',
      preparationTime: 12,
      rating: 4.8,
      reviewCount: 165,
      calories: 520,
      isSpicy: true,
      ingredients: [
        'Poulet',
        'Viande hachée',
        'Frites',
        'Fromage',
        'Sauce mixte'
      ],
    ),
  ];

  static final List<FoodItem> salades = [
    const FoodItem(
      id: '9',
      name: 'Salade Marocaine aux Aubergines',
      price: 15.0,
      image: 'images/salade aubergine.jpeg',
      description:
          'Aubergines fondantes mélangées à des épices douces et un filet d\'huile d\'olive. Une salade légère, savoureuse et authentique qui évoque les saveurs traditionnelles marocaines.',
      category: 'Salades',
      preparationTime: 8,
      rating: 4.4,
      reviewCount: 56,
      calories: 120,
      isVegetarian: true,
      ingredients: ['Aubergines', 'Tomates', 'Ail', 'Cumin', 'Huile d\'olive'],
    ),
    const FoodItem(
      id: '10',
      name: 'Salade Concombre et Tomates',
      price: 15.0,
      image: 'images/concombre tomate.jpeg',
      description:
          'Salade fraîche et croquante avec concombre et tomates, assaisonnée d\'un filet de citron. Idéale pour accompagner vos plats principaux ou pour un déjeuner léger et rafraîchissant.',
      category: 'Salades',
      preparationTime: 5,
      rating: 4.3,
      reviewCount: 78,
      calories: 80,
      isVegetarian: true,
      ingredients: ['Concombre', 'Tomates', 'Oignon', 'Citron', 'Menthe'],
    ),
    const FoodItem(
      id: '11',
      name: 'Salade Marocaine aux Carottes',
      price: 15.0,
      image: 'images/carrote.jpg',
      description:
          'Carottes fondantes avec une touche de coriandre fraîche et d\'épices douces. Une salade simple mais savoureuse, pleine de couleur et de fraîcheur.',
      category: 'Salades',
      preparationTime: 7,
      rating: 4.5,
      reviewCount: 92,
      calories: 100,
      isVegetarian: true,
      ingredients: ['Carottes', 'Coriandre', 'Ail', 'Cumin', 'Jus de citron'],
    ),
    const FoodItem(
      id: '12',
      name: 'Salade de Pommes de Terre',
      price: 15.0,
      image: 'images/pomme de terre.jpeg',
      description:
          'Pommes de terre onctueuses accompagnées d\'oignons et d\'herbes fraîches. Une salade douce et réconfortante, parfaite pour compléter un repas copieux.',
      category: 'Salades',
      preparationTime: 10,
      rating: 4.2,
      reviewCount: 64,
      calories: 180,
      isVegetarian: true,
      ingredients: ['Pommes de terre', 'Oignons', 'Persil', 'Huile d\'olive'],
    ),
  ];

  static final List<FoodItem> boissons = [
    const FoodItem(
      id: '13',
      name: 'Coca-Cola',
      price: 6.0,
      image: 'images/coca-cola.jpg',
      description:
          'La boisson iconique aux bulles pétillantes et au goût inimitable. Servie bien fraîche avec des glaçons, elle accompagne parfaitement votre repas pour une sensation de pure rafraîchissement à chaque gorgée.',
      category: 'Boissons',
      preparationTime: 1,
      rating: 4.6,
      reviewCount: 245,
      calories: 139,
    ),
    const FoodItem(
      id: '14',
      name: 'Coca-Cola Zéro',
      price: 6.0,
      image: 'images/coca-zero.jpg',
      description:
          'Savourez le goût classique du Coca-Cola sans aucune calorie. Une alternative légère et rafraîchissante, idéale pour profiter pleinement de votre repas sans compromis sur le goût.',
      category: 'Boissons',
      preparationTime: 1,
      rating: 4.5,
      reviewCount: 198,
      calories: 0,
    ),
    const FoodItem(
      id: '15',
      name: 'Fanta Orange',
      price: 5.0,
      image: 'images/fanta.jpg',
      description:
          'Explosion de saveur fruitée ! Cette boisson pétillante à l\'orange apporte une touche de douceur et de fraîcheur à votre repas. Les bulles légères et le goût fruité séduiront petits et grands.',
      category: 'Boissons',
      preparationTime: 1,
      rating: 4.4,
      reviewCount: 167,
      calories: 145,
    ),
    const FoodItem(
      id: '16',
      name: 'Sprite',
      price: 6.0,
      image: 'images/sprite.jpg',
      description:
          'Fraîcheur ultime avec cette boisson citron-lime pétillante. Désaltère instantanément et nettoie le palais entre chaque bouchée savoureuse, parfaite pour vos repas gourmands.',
      category: 'Boissons',
      preparationTime: 1,
      rating: 4.5,
      reviewCount: 189,
      calories: 142,
    ),
    const FoodItem(
      id: '17',
      name: 'Eau Minérale (Sidi Ali)',
      price: 4.0,
      image: 'images/eau-minerale.jpg',
      description:
          'Pure et naturelle, cette eau minérale provient de sources protégées et hydrate parfaitement vos plats sans en altérer les saveurs. Riche en minéraux essentiels, c\'est le choix santé par excellence.',
      category: 'Boissons',
      preparationTime: 1,
      rating: 4.7,
      reviewCount: 312,
      calories: 0,
    ),
    const FoodItem(
      id: '18',
      name: 'Jus d\'Orange Frais',
      price: 8.0,
      image: 'images/jus-orange.webp',
      description:
          'Oranges pressées à la minute pour conserver toute la fraîcheur et les vitamines. 100% pur jus, sans sucre ajouté, un goût naturellement sucré et acidulé pour une boisson vitaminée et revitalisante.',
      category: 'Boissons',
      preparationTime: 3,
      rating: 4.9,
      reviewCount: 276,
      calories: 110,
    ),
    const FoodItem(
      id: '19',
      name: 'Thé Glacé Pêche',
      price: 9.0,
      image: 'images/ice-tea.webp',
      description:
          'Thé infusé délicat associé à la douceur veloutée de la pêche. Servi glacé avec une pointe de citron, il désaltère tout en ajoutant une touche fruitée à votre repas.',
      category: 'Boissons',
      preparationTime: 1,
      rating: 4.3,
      reviewCount: 156,
      calories: 120,
    ),
  ];

  static final List<FoodItem> _cachedAllItems = [
    ...pizzas,
    ...tacos,
    ...salades,
    ...boissons,
  ];

  static List<FoodItem> get allItems => _cachedAllItems;

  static const List<Map<String, String>> categories = [
    {'label': '🍕 Pizza', 'key': 'Pizza'},
    {'label': '🌮 Tacos', 'key': 'Tacos'},
    {'label': '🥗 Salades', 'key': 'Salades'},
    {'label': '🥤 Boissons', 'key': 'Boissons'},
  ];

  static List<FoodItem> getItemsByCategory(String category) {
    switch (category) {
      case 'Pizza':
        return pizzas;
      case 'Tacos':
        return tacos;
      case 'Salades':
        return salades;
      case 'Boissons':
        return boissons;
      default:
        return [];
    }
  }
}
