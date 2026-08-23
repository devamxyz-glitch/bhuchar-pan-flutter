// REPLACE THIS FILE
// lib/screens/product_details_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/cart_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productName;
  final String category;
  final int price;
  final int? oldPrice;
  final IconData icon;
  final String? tag;
  final String subtitle;
  final String? productId;
  final String? imageUrl;

  const ProductDetailsScreen({
    super.key,
    required this.productName,
    required this.category,
    required this.price,
    this.oldPrice,
    required this.icon,
    this.tag,
    required this.subtitle,
    this.productId,
    this.imageUrl,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _glowController;
  late final AnimationController _buttonController;

  int _quantity = 1;
  bool _isAdding = false;
  bool _isFavorite = false;

  final Color _gold = const Color(0xFFD4AF37);

  String get _resolvedProductId {
    return widget.productId ??
        '${widget.category}_${widget.productName}'
            .toLowerCase()
            .replaceAll(' ', '_');
  }

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _glowController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _increaseQuantity() {
    if (_quantity >= 20) return;

    setState(() {
      _quantity++;
    });
  }

  void _decreaseQuantity() {
    if (_quantity <= 1) return;

    setState(() {
      _quantity--;
    });
  }

  Future<void> _addToCart() async {
    if (_isAdding) return;

    setState(() {
      _isAdding = true;
    });

    CartService.instance.addItem(
      id: _resolvedProductId,
      name: widget.productName,
      category: widget.category,
      subtitle: widget.subtitle,
      price: widget.price.toDouble(),
      oldPrice: widget.oldPrice?.toDouble(),
      imageUrl: widget.imageUrl,
      quantity: _quantity,
    );

    await _buttonController.forward();

    if (!mounted) return;

    _showFlyToCartAnimation();

    await Future.delayed(
      const Duration(milliseconds: 650),
    );

    if (!mounted) return;

    _buttonController.reset();

    setState(() {
      _isAdding = false;
    });

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
          duration: const Duration(milliseconds: 1800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: _gold.withValues(alpha: 0.20),
            ),
          ),
          content: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: _gold,
                size: 23,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$_quantity × ${widget.productName} added to cart',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _showFlyToCartAnimation() {
    final OverlayState overlay = Overlay.of(context);

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return _FlyingProductOverlay(
          icon: widget.icon,
          imageUrl: widget.imageUrl,
          onFinished: () {
            if (entry.mounted) {
              entry.remove();
            }
          },
        );
      },
    );

    overlay.insert(entry);
  }

  void _openCart() {
    Navigator.of(context).pushNamed('/cart');
  }

  double get _totalPrice {
    return widget.price.toDouble() * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          const _DetailsBackground(),

          SafeArea(
            bottom: false,
            child: AnimatedBuilder(
              animation: _entryController,
              builder: (context, child) {
                final double progress = CurvedAnimation(
                  parent: _entryController,
                  curve: Curves.easeOutCubic,
                ).value;

                return Opacity(
                  opacity: progress,
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      35 * (1 - progress),
                    ),
                    child: child,
                  ),
                );
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  18,
                  92,
                  18,
                  155,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductVisual(),
                    const SizedBox(height: 25),
                    _buildProductInfo(),
                    const SizedBox(height: 25),
                    _buildQuantitySection(),
                    const SizedBox(height: 25),
                    _buildDescription(),
                    const SizedBox(height: 25),
                    _buildFeatureRow(),
                    const SizedBox(height: 28),
                    _buildRelatedSection(),
                  ],
                ),
              ),
            ),
          ),

          _buildBottomPurchaseBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: _CircleButton(
          icon: Icons.arrow_back_rounded,
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      actions: [
        AnimatedBuilder(
          animation: CartService.instance,
          builder: (context, child) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                _CircleButton(
                  icon: Icons.shopping_bag_outlined,
                  iconColor: Colors.white,
                  onTap: _openCart,
                ),
                if (CartService.instance.itemCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: _CartBadge(
                      count: CartService.instance.itemCount,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
        _CircleButton(
          icon: _isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          iconColor: _isFavorite ? _gold : Colors.white,
          onTap: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildProductVisual() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final double glow =
            0.10 + (_glowController.value * 0.07);

        return Container(
          height: 330,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: _gold.withValues(alpha: 0.18),
            ),
            gradient: const RadialGradient(
              center: Alignment.center,
              radius: 0.9,
              colors: [
                Color(0xFF34270D),
                Color(0xFF171207),
                Color(0xFF0A0A0A),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: glow),
                blurRadius: 45,
                spreadRadius: -10,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -90,
                right: -75,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _gold.withValues(alpha: 0.08),
                      width: 35,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _gold.withValues(alpha: 0.035),
                  ),
                ),
              ),
              Center(
                child: Hero(
                  tag: 'product-${_resolvedProductId}',
                  child: _ProductImage(
                    imageUrl: widget.imageUrl,
                    icon: widget.icon,
                    size: 125,
                  ),
                ),
              ),
              if (widget.tag != null)
                Positioned(
                  top: 18,
                  left: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.58),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: _gold.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Text(
                      widget.tag!,
                      style: TextStyle(
                        color: _gold,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 18,
                right: 18,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 12,
                      sigmaY: 12,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: _gold,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'BH UCHAR QUALITY',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.category.toUpperCase(),
          style: TextStyle(
            color: _gold,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.productName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            height: 1.1,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.42),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '₹${widget.price}',
              style: TextStyle(
                color: _gold,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (widget.oldPrice != null) ...[
              const SizedBox(width: 9),
              Text(
                '₹${widget.oldPrice}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                  fontSize: 13,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
            const Spacer(),
            _ratingBadge(),
          ],
        ),
      ],
    );
  }

  Widget _ratingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star_rounded,
            color: _gold,
            size: 15,
          ),
          const SizedBox(width: 4),
          const Text(
            '4.8',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection() {
    return _GlassPanel(
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose how many you want',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          _QuantityButton(
            icon: Icons.remove_rounded,
            onTap: _decreaseQuantity,
          ),
          SizedBox(
            width: 42,
            child: Center(
              child: Text(
                '$_quantity',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.add_rounded,
            onTap: _increaseQuantity,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About this product',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Selected for Bhuchar Pan customers with '
          'convenient pricing and doorstep delivery. '
          'Product availability and pricing are controlled '
          'from the store inventory.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 12,
            height: 1.65,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow() {
    return const Row(
      children: [
        Expanded(
          child: _FeatureItem(
            icon: Icons.local_shipping_outlined,
            title: 'Quick delivery',
            subtitle: 'At your doorstep',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _FeatureItem(
            icon: Icons.verified_outlined,
            title: 'Quality checked',
            subtitle: 'Trusted products',
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular products',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _relatedProducts.length,
            separatorBuilder: (_, index) =>
                const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = _relatedProducts[index];

              return _RelatedProductCard(
                product: product,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(
                        productId: product.id,
                        productName: product.name,
                        category: product.category,
                        price: product.price,
                        oldPrice: product.oldPrice,
                        icon: product.icon,
                        tag: product.tag,
                        subtitle: product.subtitle,
                        imageUrl: product.imageUrl,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPurchaseBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 25,
            sigmaY: 25,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              18,
              15,
              18,
              18,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF090909)
                  .withValues(alpha: 0.93),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Container(
                    width: 82,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.045),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                    child: Text(
                      '₹${_totalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: _gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _buttonController,
                      builder: (context, child) {
                        final double scale =
                            1 - (_buttonController.value * 0.025);

                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: _addToCart,
                        child: Container(
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _gold,
                            borderRadius: BorderRadius.circular(17),
                            boxShadow: [
                              BoxShadow(
                                color: _gold.withValues(alpha: 0.18),
                                blurRadius: 20,
                                spreadRadius: -4,
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 220,
                            ),
                            child: _isAdding
                                ? const SizedBox(
                                    key: ValueKey('loading'),
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        Colors.black,
                                      ),
                                    ),
                                  )
                                : const Row(
                                    key: ValueKey('add'),
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_bag_outlined,
                                        color: Colors.black,
                                        size: 19,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Add to cart',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlyingProductOverlay extends StatefulWidget {
  final IconData icon;
  final String? imageUrl;
  final VoidCallback onFinished;

  const _FlyingProductOverlay({
    required this.icon,
    required this.imageUrl,
    required this.onFinished,
  });

  @override
  State<_FlyingProductOverlay> createState() =>
      _FlyingProductOverlayState();
}

class _FlyingProductOverlayState
    extends State<_FlyingProductOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.forward().whenComplete(() {
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, child) {
          final double t = _progress.value;

          final double startX = size.width / 2 - 62;
          final double startY = size.height * 0.36 - 62;

          final double endX = size.width - 70;
          final double endY = 28;

          final double x =
              startX + ((endX - startX) * t);

          final double y =
              startY + ((endY - startY) * t);

          final double scale =
              1 - (0.68 * t);

          final double opacity = t > 0.78
              ? 1 - ((t - 0.78) / 0.22)
              : 1;

          return Positioned(
            left: x,
            top: y,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF111111),
                    border: Border.all(
                      color: const Color(0xFFD4AF37)
                          .withValues(alpha: 0.8),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37)
                            .withValues(alpha: 0.45),
                        blurRadius: 35,
                      ),
                    ],
                  ),
                  child: _ProductImage(
                    imageUrl: widget.imageUrl,
                    icon: widget.icon,
                    size: 65,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  final IconData icon;
  final double size;

  const _ProductImage({
    required this.imageUrl,
    required this.icon,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null &&
        imageUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              icon,
              color: const Color(0xFFD4AF37),
              size: size * 0.72,
            );
          },
        ),
      );
    }

    return Icon(
      icon,
      color: const Color(0xFFD4AF37),
      size: size * 0.72,
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
        borderRadius: BorderRadius.circular(99),
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

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37)
              .withValues(alpha: 0.10),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFD4AF37)
                .withValues(alpha: 0.18),
          ),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFD4AF37),
          size: 18,
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;

  const _GlassPanel({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.065),
        ),
      ),
      child: child,
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.055),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37)
                  .withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFFD4AF37),
              size: 17,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedProductCard extends StatelessWidget {
  final _RelatedProduct product;
  final VoidCallback onTap;

  const _RelatedProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 235,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF30250E),
                    Color(0xFF0B0B0B),
                  ],
                ),
              ),
              child: _ProductImage(
                imageUrl: product.imageUrl,
                icon: product.icon,
                size: 50,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 8,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '₹${product.price}',
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
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
}

class _DetailsBackground extends StatelessWidget {
  const _DetailsBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -170,
          right: -120,
          child: Container(
            width: 430,
            height: 430,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFD4AF37)
                      .withValues(alpha: 0.075),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 150,
          left: -180,
          child: Container(
            width: 420,
            height: 420,
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

class _RelatedProduct {
  final String id;
  final String name;
  final String category;
  final String subtitle;
  final int price;
  final int? oldPrice;
  final IconData icon;
  final String? tag;
  final String? imageUrl;

  const _RelatedProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.subtitle,
    required this.price,
    this.oldPrice,
    required this.icon,
    this.tag,
    this.imageUrl,
  });
}

const List<_RelatedProduct> _relatedProducts = [
  _RelatedProduct(
    id: 'premium_mava',
    name: 'Premium Mava',
    category: 'Mava',
    subtitle: 'Fresh premium blend',
    price: 25,
    oldPrice: 30,
    icon: Icons.eco_rounded,
    tag: 'POPULAR',
  ),
  _RelatedProduct(
    id: 'balaji_wafers',
    name: 'Balaji Wafers',
    category: 'Snacks',
    subtitle: 'Crispy & tasty',
    price: 20,
    icon: Icons.fastfood_rounded,
    tag: 'POPULAR',
  ),
  _RelatedProduct(
    id: 'gopal_snacks',
    name: 'Gopal Snacks',
    category: 'Snacks',
    subtitle: 'Classic Indian snacks',
    price: 20,
    icon: Icons.restaurant_rounded,
    tag: 'POPULAR',
  ),
  _RelatedProduct(
    id: 'sugar',
    name: 'Sugar',
    category: 'Kirana',
    subtitle: 'Everyday essential',
    price: 50,
    icon: Icons.grain_rounded,
  ),
];