// REPLACE THIS FILE
// lib/screens/catalogue_screen.dart

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/cart_service.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';
import 'profile_screen.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({
    super.key,
    this.initialCategory = 'All',
  });

  final String initialCategory;

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen>
    with SingleTickerProviderStateMixin {
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _background = Color(0xFF050505);

  final TextEditingController _searchController =
      TextEditingController();

  late final AnimationController _entryController;

  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isSearchOpen = false;

  CollectionReference<Map<String, dynamic>> get _productsCollection {
    return FirebaseFirestore.instance.collection('products');
  }

  CartService get _cart => CartService.instance;

  @override
  void initState() {
    super.initState();

    _selectedCategory = widget.initialCategory.trim().isEmpty
        ? 'All'
        : widget.initialCategory;

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _searchController.addListener(_onSearchChanged);
    _cart.addListener(_cartChanged);
  }

  void _cartChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _onSearchChanged() {
    if (!mounted) {
      return;
    }

    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  @override
  void dispose() {
    _cart.removeListener(_cartChanged);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  double _toDouble(
    dynamic value, {
    double fallback = 0,
  }) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        fallback;
  }

  int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  List<_CatalogueProduct> _parseProducts(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final List<_CatalogueProduct> products = [];

    for (final QueryDocumentSnapshot<Map<String, dynamic>> document
        in snapshot.docs) {
      final Map<String, dynamic> data = document.data();

      if (data['active'] == false) {
        continue;
      }

      final double price = _toDouble(data['price']);

      final double mrp = _toDouble(
        data['mrp'],
        fallback: price,
      );

      final String category = (
        data['category'] ??
        data['brand'] ??
        'General'
      ).toString().trim();

      products.add(
        _CatalogueProduct(
          id: (data['id'] ?? document.id).toString(),
          name: (data['name'] ?? 'Product').toString(),
          category: category.isEmpty ? 'General' : category,
          brand: (data['brand'] ?? '').toString(),
          pack: (data['pack'] ?? '').toString(),
          price: price,
          mrp: mrp,
          stock: _toInt(data['stock']),
          imageUrl: (
            data['image'] ??
            data['imageUrl'] ??
            ''
          ).toString(),
        ),
      );
    }

    products.sort(
      (_CatalogueProduct a, _CatalogueProduct b) =>
          a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
    );

    return products;
  }

  List<String> _getCategoryNames(
    List<_CatalogueProduct> products,
  ) {
    final Map<String, String> normalizedCategories =
        <String, String>{};

    for (final _CatalogueProduct product in products) {
      final String category = product.category.trim();

      if (category.isEmpty) {
        continue;
      }

      final String key = category.toLowerCase();

      normalizedCategories.putIfAbsent(
        key,
        () => category,
      );
    }

    final List<String> categories = <String>[
      'All',
      ...normalizedCategories.values,
    ];

    categories.sort(
      (String a, String b) {
        if (a == 'All') {
          return -1;
        }

        if (b == 'All') {
          return 1;
        }

        return a.toLowerCase().compareTo(
              b.toLowerCase(),
            );
      },
    );

    return categories;
  }

  List<_CatalogueProduct> _filterProducts(
    List<_CatalogueProduct> products,
  ) {
    final String query = _searchQuery.toLowerCase();

    return products.where(
      (_CatalogueProduct product) {
        final bool categoryMatches =
            _selectedCategory == 'All' ||
                product.category.toLowerCase() ==
                    _selectedCategory.toLowerCase();

        final String searchable = [
          product.name,
          product.category,
          product.brand,
          product.pack,
        ].join(' ').toLowerCase();

        final bool searchMatches =
            query.isEmpty ||
                searchable.contains(query);

        return categoryMatches && searchMatches;
      },
    ).toList();
  }

  IconData _iconForCategory(String category) {
    final String value = category.toLowerCase();

    if (value.contains('mava') ||
        value.contains('pan')) {
      return Icons.eco_rounded;
    }

    if (value.contains('tobacco')) {
      return Icons.smoking_rooms_outlined;
    }

    if (value.contains('drink') ||
        value.contains('beverage') ||
        value.contains('cold')) {
      return Icons.local_drink_rounded;
    }

    if (value.contains('snack') ||
        value.contains('namkeen')) {
      return Icons.fastfood_rounded;
    }

    if (value.contains('biscuit')) {
      return Icons.cookie_outlined;
    }

    if (value.contains('bakery') ||
        value.contains('bread')) {
      return Icons.bakery_dining_outlined;
    }

    if (value.contains('dairy')) {
      return Icons.water_drop_rounded;
    }

    if (value.contains('pooja')) {
      return Icons.local_fire_department_outlined;
    }

    return Icons.shopping_bag_outlined;
  }

  void _openProduct(
    _CatalogueProduct product,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsScreen(
          productId: product.id,
          productName: product.name,
          category: product.category,
          price: product.price.round(),
          oldPrice: product.mrp > product.price
              ? product.mrp.round()
              : null,
          icon: _iconForCategory(product.category),
          tag: product.stock <= 5
              ? 'LOW STOCK'
              : product.mrp > product.price
                  ? 'OFFER'
                  : null,
          subtitle:
              '${product.pack.isEmpty ? 'Everyday essential' : product.pack}'
              '${product.brand.isEmpty ? '' : ' • ${product.brand}'}',
          imageUrl: product.imageUrl.trim().isEmpty
              ? null
              : product.imageUrl,
        ),
      ),
    );
  }

  void _addProduct(
    _CatalogueProduct product,
  ) {
    if (product.stock <= 0) {
      _showMessage(
        'This product is currently out of stock.',
        error: true,
      );
      return;
    }

    _cart.addItem(
      id: product.id,
      name: product.name,
      category: product.category,
      subtitle: product.pack.isEmpty
          ? 'Bhuchar Pan'
          : product.pack,
      price: product.price,
      oldPrice: product.mrp > product.price
          ? product.mrp
          : null,
      imageUrl: product.imageUrl.trim().isEmpty
          ? null
          : product.imageUrl,
    );

    _showMessage(
      '${product.name} added to cart',
    );
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CartScreen(),
      ),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  void _openHome() {
    Navigator.of(context).popUntil(
      (Route<dynamic> route) => route.isFirst,
    );
  }

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(
            18,
            0,
            18,
            92,
          ),
          duration: const Duration(
            milliseconds: 1400,
          ),
          backgroundColor: const Color(0xFF111111),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: (
                error ? Colors.redAccent : _gold
              ).withValues(
                alpha: 0.20,
              ),
            ),
          ),
          content: Row(
            children: [
              Icon(
                error
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_rounded,
                color: error
                    ? Colors.redAccent
                    : _gold,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;

      if (!_isSearchOpen) {
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          const _CatalogueBackground(),

          SafeArea(
            child: AnimatedBuilder(
              animation: _entryController,
              builder: (
                BuildContext context,
                Widget? child,
              ) {
                final double progress = CurvedAnimation(
                  parent: _entryController,
                  curve: Curves.easeOutCubic,
                ).value;

                return Opacity(
                  opacity: progress,
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      25 * (1 - progress),
                    ),
                    child: child,
                  ),
                );
              },
              child: StreamBuilder<
                  QuerySnapshot<Map<String, dynamic>>>(
                stream: _productsCollection.snapshots(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<
                          QuerySnapshot<
                              Map<String, dynamic>>>
                      snapshot,
                ) {
                  if (snapshot.hasError) {
                    return _buildError(
                      snapshot.error.toString(),
                    );
                  }

                  if (snapshot.connectionState ==
                          ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return _buildLoading();
                  }

                  final List<_CatalogueProduct> products =
                      snapshot.hasData
                          ? _parseProducts(
                              snapshot.data!,
                            )
                          : <_CatalogueProduct>[];

                  final List<String> categories =
                      _getCategoryNames(products);

                  if (!categories.contains(
                    _selectedCategory,
                  )) {
                    _selectedCategory = 'All';
                  }

                  final List<_CatalogueProduct> filtered =
                      _filterProducts(products);

                  return CustomScrollView(
                    physics:
                        const BouncingScrollPhysics(
                      parent:
                          AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildHeader(
                          products.length,
                        ),
                      ),

                      if (_isSearchOpen)
                        SliverToBoxAdapter(
                          child: _buildSearchBar(),
                        ),

                      SliverToBoxAdapter(
                        child: _buildCategories(
                          categories,
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: _buildSectionHeader(
                          filtered.length,
                        ),
                      ),

                      if (filtered.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(),
                        )
                      else
                        SliverPadding(
                          padding:
                              const EdgeInsets.fromLTRB(
                            18,
                            0,
                            18,
                            125,
                          ),
                          sliver: SliverGrid(
                            delegate:
                                SliverChildBuilderDelegate(
                              (
                                BuildContext context,
                                int index,
                              ) {
                                final _CatalogueProduct
                                    product =
                                    filtered[index];

                                return _CatalogueProductCard(
                                  product: product,
                                  icon:
                                      _iconForCategory(
                                    product.category,
                                  ),
                                  onTap: () {
                                    _openProduct(
                                      product,
                                    );
                                  },
                                  onAdd: () {
                                    _addProduct(
                                      product,
                                    );
                                  },
                                );
                              },
                              childCount:
                                  filtered.length,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.68,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),

          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader(int totalProducts) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        8,
      ),
      child: Row(
        children: [
          _RoundBackButton(
            onTap: () {
              Navigator.of(context).pop();
            },
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'CATALOGUE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$totalProducts products available',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          _GlassButton(
            icon: _isSearchOpen
                ? Icons.close_rounded
                : Icons.search_rounded,
            onTap: _toggleSearch,
          ),

          const SizedBox(width: 8),

          AnimatedBuilder(
            animation: _cart,
            builder: (
              BuildContext context,
              Widget? child,
            ) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  _GlassButton(
                    icon: Icons.shopping_bag_outlined,
                    onTap: _openCart,
                  ),
                  if (_cart.itemCount > 0)
                    Positioned(
                      right: -2,
                      top: -3,
                      child: _CartBadge(
                        count: _cart.itemCount,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        6,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 18,
            sigmaY: 18,
          ),
          child: Container(
            height: 52,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.045,
              ),
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: _gold.withValues(
                  alpha: 0.16,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: _gold.withValues(
                    alpha: 0.85,
                  ),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller:
                        _searchController,
                    autofocus: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    cursorColor: _gold,
                    decoration:
                        const InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          'Search products, brands, packs...',
                      hintStyle: TextStyle(
                        color: Colors.white30,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white38,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(
    List<String> categories,
  ) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        padding:
            const EdgeInsets.fromLTRB(
          18,
          14,
          18,
          8,
        ),
        scrollDirection: Axis.horizontal,
        physics:
            const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (
          BuildContext context,
          int index,
        ) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          final String category =
              categories[index];

          final bool selected =
              category.toLowerCase() ==
                  _selectedCategory
                      .toLowerCase();

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory =
                    category;
              });
            },
            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 220,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              decoration:
                  BoxDecoration(
                color: selected
                    ? _gold
                    : Colors.white.withValues(
                        alpha: 0.035,
                      ),
                borderRadius:
                    BorderRadius.circular(
                  100,
                ),
                border: Border.all(
                  color: selected
                      ? _gold
                      : Colors.white
                          .withValues(
                          alpha: 0.07,
                        ),
                ),
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    _iconForCategory(
                      category,
                    ),
                    color: selected
                        ? Colors.black
                        : _gold,
                    size: 15,
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    category,
                    style: TextStyle(
                      color: selected
                          ? Colors.black
                          : Colors.white70,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    int count,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        15,
      ),
      child: Row(
        children: [
          const Text(
            'Products',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 10,
            ),
          ),
          const Spacer(),
          if (_searchQuery.isNotEmpty)
            Flexible(
              child: Text(
                '"$_searchQuery"',
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _gold,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            )
          else if (_selectedCategory !=
              'All')
            Flexible(
              child: Text(
                _selectedCategory,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _gold,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: _gold,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: _gold,
              size: 48,
            ),
            const SizedBox(height: 18),
            const Text(
              'Could not load catalogue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool searching =
        _searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              searching
                  ? Icons.search_off_rounded
                  : Icons.inventory_2_outlined,
              color: _gold.withValues(
                alpha: 0.7,
              ),
              size: 52,
            ),
            const SizedBox(height: 16),
            Text(
              searching
                  ? 'No products found'
                  : 'Catalogue is empty',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              searching
                  ? 'Try a different product name, brand or category.'
                  : 'Products added to Firebase will appear here automatically.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      left: 14,
      right: 14,
      bottom: 14,
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 25,
            sigmaY: 25,
          ),
          child: Container(
            height: 65,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            decoration:
                BoxDecoration(
              color: const Color(
                0xFF0C0C0C,
              ).withValues(
                alpha: 0.94,
              ),
              borderRadius:
                  BorderRadius.circular(
                26,
              ),
              border: Border.all(
                color: Colors.white
                    .withValues(
                  alpha: 0.07,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(
                    alpha: 0.45,
                  ),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceAround,
              children: [
                _CatalogueNavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  gold: _gold,
                  onTap: _openHome,
                ),

                _CatalogueNavItem(
                  icon: Icons.category_rounded,
                  label: 'Catalogue',
                  gold: _gold,
                  active: true,
                ),

                AnimatedBuilder(
                  animation: _cart,
                  builder: (
                    BuildContext context,
                    Widget? child,
                  ) {
                    return _CatalogueNavItem(
                      icon: Icons
                          .shopping_bag_outlined,
                      label: 'Cart',
                      gold: _gold,
                      badge: _cart.itemCount,
                      onTap: _openCart,
                    );
                  },
                ),

                _CatalogueNavItem(
                  icon: Icons
                      .person_outline_rounded,
                  label: 'Profile',
                  gold: _gold,
                  onTap: _openProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CatalogueProductCard
    extends StatefulWidget {
  final _CatalogueProduct product;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _CatalogueProductCard({
    required this.product,
    required this.icon,
    required this.onTap,
    required this.onAdd,
  });

  @override
  State<_CatalogueProductCard> createState() =>
      _CatalogueProductCardState();
}

class _CatalogueProductCardState
    extends State<_CatalogueProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController
      _pressController;

  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    _pressController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 120),
      lowerBound: 0,
      upperBound: 0.025,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount =
        widget.product.mrp >
            widget.product.price;

    final int discount = hasDiscount
        ? (((widget.product.mrp -
                        widget.product.price) /
                    widget.product.mrp) *
                100)
            .round()
        : 0;

    final bool outOfStock =
        widget.product.stock <= 0;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });

        _pressController.forward();
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });

        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });

        _pressController.reverse();
      },
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (
          BuildContext context,
          Widget? child,
        ) {
          return Transform.scale(
            scale:
                1 - _pressController.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color:
                const Color(0xFF0D0D0D),
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white
                  .withValues(
                alpha:
                    _pressed ? 0.12 : 0.055,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.all(7),
                  clipBehavior:
                      Clip.antiAlias,
                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      17,
                    ),
                    gradient:
                        const RadialGradient(
                      colors: [
                        Color(0xFF33270D),
                        Color(0xFF0B0B0B),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Hero(
                          tag:
                              'catalogue-product-${widget.product.id}',
                          child: _ProductImage(
                            imageUrl: widget
                                .product
                                .imageUrl,
                            icon: widget.icon,
                          ),
                        ),
                      ),
                      if (hasDiscount)
                        Positioned(
                          top: 9,
                          left: 9,
                          child: _SmallPill(
                            text:
                                '$discount% OFF',
                          ),
                        ),
                      if (outOfStock)
                        Positioned(
                          bottom: 9,
                          left: 9,
                          child: _SmallPill(
                            text:
                                'OUT OF STOCK',
                            danger: true,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    13,
                    3,
                    10,
                    11,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.category
                            .toUpperCase(),
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          color: _gold,
                          fontSize: 7,
                          fontWeight:
                              FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.1,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            '₹${widget.product.price.toStringAsFixed(0)}',
                            style:
                                const TextStyle(
                              color: _gold,
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              '₹${widget.product.mrp.toStringAsFixed(0)}',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white24,
                                fontSize: 9,
                                decoration:
                                    TextDecoration
                                        .lineThrough,
                              ),
                            ),
                          ],
                          const Spacer(),
                          GestureDetector(
                            onTap: outOfStock
                                ? null
                                : widget.onAdd,
                            child: Container(
                              width: 31,
                              height: 31,
                              decoration:
                                  BoxDecoration(
                                color: outOfStock
                                    ? Colors
                                        .white10
                                    : _gold,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  11,
                                ),
                              ),
                              child: Icon(
                                Icons
                                    .add_rounded,
                                color: outOfStock
                                    ? Colors
                                        .white24
                                    : Colors
                                        .black,
                                size: 20,
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
      ),
    );
  }
}

class _ProductImage
    extends StatelessWidget {
  final String imageUrl;
  final IconData icon;

  const _ProductImage({
    required this.imageUrl,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 115,
        height: 115,
        fit: BoxFit.contain,
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) {
          return Icon(
            icon,
            color: _CatalogueScreenState._gold,
            size: 60,
          );
        },
        loadingBuilder: (
          BuildContext context,
          Widget child,
          ImageChunkEvent? progress,
        ) {
          if (progress == null) {
            return child;
          }

          return const SizedBox(
            width: 32,
            height: 32,
            child:
                CircularProgressIndicator(
              color: _gold,
              strokeWidth: 1.5,
            ),
          );
        },
      );
    }

    return Icon(
      icon,
      color: _gold,
      size: 60,
    );
  }
}

class _SmallPill
    extends StatelessWidget {
  final String text;
  final bool danger;

  const _SmallPill({
    required this.text,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = danger
        ? Colors.redAccent
        : _gold;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.62,
        ),
        borderRadius:
            BorderRadius.circular(100),
        border: Border.all(
          color: color.withValues(
            alpha: 0.30,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 7,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _RoundBackButton
    extends StatelessWidget {
  final VoidCallback onTap;

  const _RoundBackButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.035,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(
              alpha: 0.07,
            ),
          ),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white70,
          size: 19,
        ),
      ),
    );
  }
}

class _GlassButton
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),
          child: Container(
            width: 43,
            height: 43,
            alignment: Alignment.center,
            decoration:
                BoxDecoration(
              color: Colors.white
                  .withValues(
                alpha: 0.035,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white
                    .withValues(
                  alpha: 0.07,
                ),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white70,
              size: 19,
            ),
          ),
        ),
      ),
    );
  }
}

class _CartBadge
    extends StatelessWidget {
  final int count;

  const _CartBadge({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          const BoxConstraints(
        minWidth: 18,
      ),
      height: 18,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _gold,
        borderRadius:
            BorderRadius.circular(99),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CatalogueNavItem
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color gold;
  final int badge;
  final VoidCallback? onTap;

  const _CatalogueNavItem({
    required this.icon,
    required this.label,
    required this.gold,
    this.active = false,
    this.badge = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior:
          HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: 70,
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: active
                      ? gold
                      : Colors.white38,
                  size: 21,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: active
                        ? gold
                        : Colors.white38,
                    fontSize: 8,
                    fontWeight: active
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (badge > 0)
            Positioned(
              right: 8,
              top: 1,
              child: _CartBadge(
                count: badge,
              ),
            ),
        ],
      ),
    );
  }
}

class _CatalogueBackground
    extends StatelessWidget {
  const _CatalogueBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -180,
          right: -150,
          child: Container(
            width: 470,
            height: 470,
            decoration:
                BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  RadialGradient(
                colors: [
                  _gold.withValues(
                    alpha: 0.075,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -170,
          left: -190,
          child: Container(
            width: 430,
            height: 430,
            decoration:
                BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  RadialGradient(
                colors: [
                  _gold.withValues(
                    alpha: 0.03,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CatalogueProduct {
  final String id;
  final String name;
  final String category;
  final String brand;
  final String pack;
  final double price;
  final double mrp;
  final int stock;
  final String imageUrl;

  const _CatalogueProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.pack,
    required this.price,
    required this.mrp,
    required this.stock,
    required this.imageUrl,
  });
}

const Color _gold = Color(0xFFD4AF37);