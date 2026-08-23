// REPLACE THIS FILE
// lib/screens/home_screen.dart

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/cart_service.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _background = Color(0xFF050505);

  final TextEditingController _searchController =
      TextEditingController();

  late final AnimationController _entryController;

  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isSearchOpen = false;

  CartService get _cart => CartService.instance;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _searchController.addListener(_onSearchChanged);
    _cart.addListener(_cartChanged);
  }

  @override
  void dispose() {
    _cart.removeListener(_cartChanged);
    _entryController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _cartChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onSearchChanged() {
    if (!mounted) return;

    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  CollectionReference<Map<String, dynamic>>
      get _productsCollection {
    return FirebaseFirestore.instance.collection('products');
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

  List<_HomeProduct> _parseSnapshot(
    QuerySnapshot<Map<String, dynamic>>? snapshot,
  ) {
    if (snapshot == null) {
      return [];
    }

    final List<_HomeProduct> products = [];

    for (final QueryDocumentSnapshot<Map<String, dynamic>>
        document in snapshot.docs) {
      final Map<String, dynamic> data = document.data();

      if (data['active'] == false) {
        continue;
      }

      final double price = _toDouble(data['price']);

      final double mrp = _toDouble(
        data['mrp'],
        fallback: price,
      );

      products.add(
        _HomeProduct(
          id: (data['id'] ?? document.id).toString(),
          name: (data['name'] ?? 'Product').toString(),
          category: (
            data['category'] ??
                data['brand'] ??
                'General'
          ).toString(),
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
      (a, b) => a.name.compareTo(b.name),
    );

    return products;
  }

  List<String> _categories(
    List<_HomeProduct> products,
  ) {
    final Set<String> values = {};

    for (final _HomeProduct product in products) {
      if (product.category.trim().isNotEmpty) {
        values.add(product.category);
      }
    }

    return [
      'All',
      ...values.take(12),
    ];
  }

  List<_HomeProduct> _filteredProducts(
    List<_HomeProduct> products,
  ) {
    return products.where(
      (_HomeProduct product) {
        final bool categoryMatch =
            _selectedCategory == 'All' ||
                product.category.toLowerCase() ==
                    _selectedCategory.toLowerCase();

        final String searchable =
            '${product.name} '
            '${product.category} '
            '${product.brand} '
            '${product.pack}'
                .toLowerCase();

        final bool searchMatch =
            _searchQuery.isEmpty ||
                searchable.contains(
                  _searchQuery.toLowerCase(),
                );

        return categoryMatch && searchMatch;
      },
    ).toList();
  }

  IconData _iconForCategory(
    String category,
  ) {
    final String value = category.toLowerCase();

    if (value.contains('mava') ||
        value.contains('pan')) {
      return Icons.eco_rounded;
    }

    if (value.contains('snack') ||
        value.contains('namkeen')) {
      return Icons.fastfood_rounded;
    }

    if (value.contains('drink') ||
        value.contains('beverage')) {
      return Icons.local_drink_rounded;
    }

    if (value.contains('dairy')) {
      return Icons.water_drop_rounded;
    }

    if (value.contains('home')) {
      return Icons.home_work_outlined;
    }

    if (value.contains('pooja')) {
      return Icons.local_fire_department_outlined;
    }

    return Icons.shopping_bag_outlined;
  }

  void _openProduct(
    _HomeProduct product,
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
          imageUrl: product.imageUrl.isEmpty
              ? null
              : product.imageUrl,
        ),
      ),
    );
  }

  void _addProduct(
    _HomeProduct product,
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
      imageUrl: product.imageUrl.isEmpty
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

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

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
          backgroundColor: const Color(0xFF111111),
          duration: const Duration(
            milliseconds: 1400,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: (
                error
                    ? Colors.redAccent
                    : _gold
              ).withValues(alpha: 0.20),
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

  void _openSearch() {
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
          const _HomeBackground(),

          SafeArea(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: _productsCollection.snapshots(),
              builder: (context, snapshot) {
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

                final List<_HomeProduct> products =
                    _parseSnapshot(snapshot.data);

                final List<String> categories =
                    _categories(products);

                final List<_HomeProduct> filtered =
                    _filteredProducts(products);

                return RefreshIndicator(
                  color: _gold,
                  backgroundColor:
                      const Color(0xFF111111),
                  onRefresh: () async {
                    await _productsCollection.get();

                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: CustomScrollView(
                    physics:
                        const BouncingScrollPhysics(
                      parent:
                          AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildHeader(),
                      ),
                      if (_isSearchOpen)
                        SliverToBoxAdapter(
                          child: _buildSearchField(),
                        ),
                      SliverToBoxAdapter(
                        child: _buildHero(),
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
                              (context, index) {
                                final _HomeProduct product =
                                    filtered[index];

                                return _ProductCard(
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
                              childCount: filtered.length,
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
                  ),
                );
              },
            ),
          ),

          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15,
            sigmaY: 15,
          ),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.035,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.07,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: Colors.white38,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    cursorColor: _gold,
                    decoration:
                        const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search products...',
                      hintStyle: TextStyle(
                        color: Colors.white30,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        12,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE7C75A),
                  Color(0xFF9A7415),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(
                    alpha: 0.25,
                  ),
                  blurRadius: 18,
                ),
              ],
            ),
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Container(
                    color: Colors.black,
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: _gold,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'BHUCHAR PAN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.4,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Everything you need, delivered.',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          _GlassIconButton(
            icon: Icons.search_rounded,
            onTap: _openSearch,
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _cart,
            builder: (context, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  _GlassIconButton(
                    icon:
                        Icons.shopping_bag_outlined,
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

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),
      child: Container(
        height: 190,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF30250E),
              Color(0xFF161207),
              Color(0xFF0B0B0B),
            ],
          ),
          border: Border.all(
            color: _gold.withValues(alpha: 0.16),
          ),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.10),
              blurRadius: 35,
              spreadRadius: -8,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -65,
              top: -90,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _gold.withValues(
                      alpha: 0.09,
                    ),
                    width: 34,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -80,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _gold.withValues(
                    alpha: 0.045,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                22,
                22,
                22,
                20,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _gold.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(100),
                      border: Border.all(
                        color: _gold.withValues(
                          alpha: 0.18,
                        ),
                      ),
                    ),
                    child: const Text(
                      'BHUCHAR • EXPRESS',
                      style: TextStyle(
                        color: _gold,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Daily essentials.\nDone properly.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      height: 1.04,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Fresh products • Easy ordering • Fast delivery',
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: 0.42,
                      ),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(
    List<String> categories,
  ) {
    return SizedBox(
      height: 68,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          18,
          18,
          18,
          10,
        ),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (
          context,
          index,
        ) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (context, index) {
          final String category = categories[index];

          final bool selected =
              category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 220,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? _gold
                    : Colors.white.withValues(
                        alpha: 0.035,
                      ),
                borderRadius:
                    BorderRadius.circular(100),
                border: Border.all(
                  color: selected
                      ? _gold
                      : Colors.white.withValues(
                          alpha: 0.07,
                        ),
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: selected
                      ? Colors.black
                      : Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
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
      padding: const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        15,
      ),
      child: Row(
        children: [
          const Text(
            'Shop now',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count products',
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 10,
            ),
          ),
          const Spacer(),
          if (_selectedCategory != 'All')
            Text(
              _selectedCategory,
              style: const TextStyle(
                color: _gold,
                fontSize: 10,
                fontWeight: FontWeight.w600,
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

  Widget _buildError(
    String error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: _gold,
              size: 45,
            ),
            const SizedBox(height: 18),
            const Text(
              'Could not load products',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: _gold.withValues(alpha: 0.7),
              size: 50,
            ),
            const SizedBox(height: 15),
            const Text(
              'No products found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Try another category or search term.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Positioned(
      left: 14,
      right: 14,
      bottom: 14,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 25,
            sigmaY: 25,
          ),
          child: Container(
            height: 65,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C0C)
                  .withValues(alpha: 0.92),
              borderRadius:
                  BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.07,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.45,
                  ),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                _BottomNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  active: true,
                  gold: _gold,
                ),
                _BottomNavItem(
                  icon: Icons.category_outlined,
                  label: 'Categories',
                  gold: _gold,
                  onTap: () {
                    _showMessage(
                      'Categories are above.',
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _cart,
                  builder: (
                    context,
                    child,
                  ) {
                    return _BottomNavItem(
                      icon: Icons
                          .shopping_bag_outlined,
                      label: 'Cart',
                      gold: _gold,
                      badge: _cart.itemCount,
                      onTap: _openCart,
                    );
                  },
                ),
                _BottomNavItem(
                  icon:
                      Icons.person_outline_rounded,
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

class _ProductCard extends StatefulWidget {
  final _HomeProduct product;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _ProductCard({
    required this.product,
    required this.icon,
    required this.onTap,
    required this.onAdd,
  });

  @override
  State<_ProductCard> createState() =>
      _ProductCardState();
}

class _ProductCardState
    extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  static const Color _gold = Color(0xFFD4AF37);

  late final AnimationController _pressController;

  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 120,
      ),
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
        widget.product.mrp > widget.product.price;

    final int discount = hasDiscount &&
            widget.product.mrp > 0
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
        builder: (context, child) {
          return Transform.scale(
            scale: 1 - _pressController.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: _pressed ? 0.12 : 0.055,
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
                  margin: const EdgeInsets.all(7),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(17),
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
                              'product-${widget.product.id}',
                          child:
                              _CardProductImage(
                            imageUrl:
                                widget.product.imageUrl,
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
                        const Positioned(
                          bottom: 9,
                          left: 9,
                          child: _SmallPill(
                            text: 'OUT OF STOCK',
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
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 7,
                          fontWeight:
                              FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
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
                            style: const TextStyle(
                              color: _gold,
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 5),
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
                                    ? Colors.white10
                                    : _gold,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  11,
                                ),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                color: outOfStock
                                    ? Colors.white24
                                    : Colors.black,
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

class _CardProductImage
    extends StatelessWidget {
  final String imageUrl;
  final IconData icon;

  const _CardProductImage({
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
          context,
          error,
          stackTrace,
        ) {
          return Icon(
            icon,
            color: const Color(0xFFD4AF37),
            size: 60,
          );
        },
      );
    }

    return Icon(
      icon,
      color: const Color(0xFFD4AF37),
      size: 60,
    );
  }
}

class _SmallPill extends StatelessWidget {
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
        : const Color(0xFFD4AF37);

    return Container(
      padding: const EdgeInsets.symmetric(
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
          color: color.withValues(alpha: 0.30),
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

class _GlassIconButton
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({
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

class _CartBadge extends StatelessWidget {
  final int count;

  const _CartBadge({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 18,
      ),
      height: 18,
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
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

class _BottomNavItem
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color gold;
  final int badge;
  final VoidCallback? onTap;

  const _BottomNavItem({
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
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: 62,
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
                const SizedBox(height: 4),
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
              right: 4,
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

class _HomeBackground
    extends StatelessWidget {
  const _HomeBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -190,
          right: -140,
          child: Container(
            width: 470,
            height: 470,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFD4AF37)
                      .withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -190,
          child: Container(
            width: 430,
            height: 430,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFD4AF37)
                      .withValues(alpha: 0.035),
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

class _HomeProduct {
  final String id;
  final String name;
  final String category;
  final String brand;
  final String pack;
  final double price;
  final double mrp;
  final int stock;
  final String imageUrl;

  const _HomeProduct({
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