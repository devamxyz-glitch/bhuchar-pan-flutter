// REPLACE THIS FILE
// lib/screens/cart_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/cart_service.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _background = Color(0xFF050505);

  late final AnimationController _entryController;

  CartService get _cart => CartService.instance;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _cart.addListener(_cartChanged);
  }

  @override
  void dispose() {
    _cart.removeListener(_cartChanged);
    _entryController.dispose();
    super.dispose();
  }

  void _cartChanged() {
    if (!mounted) return;

    setState(() {});
  }

  void _increase(CartItem item) {
    _cart.increment(item.id);
  }

  void _decrease(CartItem item) {
    _cart.decrement(item.id);
  }

  void _remove(CartItem item) {
    _cart.removeItem(item.id);
  }

  void _goToCheckout() {
    if (_cart.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CheckoutScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<CartItem> items = _cart.items;

    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          const _CartBackground(),

          SafeArea(
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
                      30 * (1 - progress),
                    ),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: items.isEmpty
                        ? _buildEmptyCart()
                        : _buildCartContent(items),
                  ),
                ],
              ),
            ),
          ),
        ],
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
          _CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Your Cart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.5,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _cart,
            builder: (context, child) {
              final int count = _cart.itemCount;

              if (count <= 0) {
                return const SizedBox.shrink();
              }

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: _gold.withValues(alpha: 0.20),
                  ),
                ),
                child: Text(
                  '$count ${count == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.07),
                border: Border.all(
                  color: _gold.withValues(alpha: 0.15),
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: _gold,
                size: 43,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'Add something delicious from Bhuchar Pan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.40),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Explore Products',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(List<CartItem> items) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              18,
              8,
              18,
              20,
            ),
            itemCount: items.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              return _buildCartItem(items[index]);
            },
          ),
        ),
        _buildBottomSummary(),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    final double itemTotal = item.total;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.065),
            ),
          ),
          child: Row(
            children: [
              _buildProductImage(item),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.category.trim().isNotEmpty)
                      Text(
                        item.category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    const SizedBox(height: 5),
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (item.subtitle.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                        ),
                      ),
                    ],
                    const SizedBox(height: 9),
                    Text(
                      '₹${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _remove(item);
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white38,
                        size: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _smallQuantityButton(
                        icon: Icons.remove_rounded,
                        onTap: () {
                          _decrease(item);
                        },
                      ),
                      SizedBox(
                        width: 28,
                        child: Center(
                          child: Text(
                            item.quantity.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      _smallQuantityButton(
                        icon: Icons.add_rounded,
                        onTap: () {
                          _increase(item);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '₹${itemTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(CartItem item) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        gradient: const RadialGradient(
          colors: [
            Color(0xFF30250E),
            Color(0xFF0B0B0B),
          ],
        ),
        border: Border.all(
          color: _gold.withValues(alpha: 0.10),
        ),
      ),
      child: item.imageUrl != null &&
              item.imageUrl!.trim().isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item.imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.shopping_bag_outlined,
                    color: _gold,
                    size: 34,
                  );
                },
              ),
            )
          : const Icon(
              Icons.shopping_bag_outlined,
              color: _gold,
              size: 34,
            ),
    );
  }

  Widget _smallQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: _gold.withValues(alpha: 0.10),
          shape: BoxShape.circle,
          border: Border.all(
            color: _gold.withValues(alpha: 0.16),
          ),
        ),
        child: Icon(
          icon,
          color: _gold,
          size: 14,
        ),
      ),
    );
  }

  Widget _buildBottomSummary() {
    final double subtotal = _cart.subtotal;
    final double deliveryFee = _cart.deliveryFee;
    final double total = _cart.grandTotal;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        17,
        18,
        18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF090909).withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.07),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _summaryRow(
              'Subtotal',
              '₹${subtotal.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 8),
            _summaryRow(
              'Delivery',
              deliveryFee == 0
                  ? 'FREE'
                  : '₹${deliveryFee.toStringAsFixed(0)}',
              valueColor:
                  deliveryFee == 0 ? _gold : Colors.white,
            ),
            const SizedBox(height: 13),
            Divider(
              color: Colors.white.withValues(alpha: 0.07),
              height: 1,
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _goToCheckout,
              child: Container(
                width: double.infinity,
                height: 53,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.16),
                      blurRadius: 22,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.black,
                      size: 17,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 7),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
                      size: 18,
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

  Widget _summaryRow(
    String title,
    String value, {
    Color valueColor = Colors.white,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
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
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _CartBackground extends StatelessWidget {
  const _CartBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -160,
          right: -130,
          child: Container(
            width: 430,
            height: 430,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFD4AF37)
                      .withValues(alpha: 0.07),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -180,
          left: -170,
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