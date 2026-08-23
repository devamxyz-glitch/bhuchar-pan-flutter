// REPLACE THIS FILE
// lib/screens/my_orders_screen.dart

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFF050505);

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  User? get currentUser => FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot<Map<String, dynamic>>> get ordersStream {
    final User? user = currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          const _OrdersBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: currentUser == null
                      ? _buildNotSignedIn()
                      : _buildOrders(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      child: Row(
        children: [
          _GlassButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Orders',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Track your Bhuchar Pan orders',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.07),
              shape: BoxShape.circle,
              border: Border.all(
                color: gold.withValues(alpha: 0.14),
              ),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: gold,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrders() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ordersStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      ) {
        if (snapshot.hasError) {
          return _buildErrorState();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final List<QueryDocumentSnapshot<Map<String, dynamic>>> orders =
            snapshot.data?.docs ?? [];

        orders.sort((a, b) {
          final dynamic first = a.data()['createdAt'];
          final dynamic second = b.data()['createdAt'];

          final int firstTime = first is Timestamp
              ? first.millisecondsSinceEpoch
              : 0;

          final int secondTime = second is Timestamp
              ? second.millisecondsSinceEpoch
              : 0;

          return secondTime.compareTo(firstTime);
        });

        if (orders.isEmpty) {
          return _buildEmptyState();
        }

        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 3, 18, 35),
              itemCount: orders.length,
              itemBuilder: (
                BuildContext context,
                int index,
              ) {
                final QueryDocumentSnapshot<Map<String, dynamic>> order =
                    orders[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OrderCard(
                    document: order,
                    onTap: () => _showOrderDetails(order),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: gold,
              strokeWidth: 2,
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Loading your orders...',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gold.withValues(alpha: 0.06),
                border: Border.all(
                  color: gold.withValues(alpha: 0.13),
                ),
                boxShadow: [
                  BoxShadow(
                    color: gold.withValues(alpha: 0.07),
                    blurRadius: 35,
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: gold,
                size: 42,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No orders yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your placed orders will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 49,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Continue shopping',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
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

  Widget _buildNotSignedIn() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: gold,
              size: 45,
            ),
            const SizedBox(height: 18),
            const Text(
              'Sign in required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please sign in to view your orders.',
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withValues(alpha: 0.07),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.14),
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Could not load orders',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'There was a problem loading your orders.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() {});
              },
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'Try again',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
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

  void _showOrderDetails(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final Map<String, dynamic> data = document.data();

    final String orderId =
        (data['orderId'] ?? document.id).toString();

    final String status =
        (data['orderStatus'] ?? 'placed').toString();

    final String paymentMethod =
        (data['paymentMethod'] ?? 'cod').toString();

    final String paymentStatus =
        (data['paymentStatus'] ?? 'pending').toString();

    final double subtotal = _toDouble(data['subtotal']);
    final double deliveryFee = _toDouble(data['deliveryFee']);
    final double grandTotal = _toDouble(data['grandTotal']);

    final Map<String, dynamic> address =
        data['deliveryAddress'] is Map
            ? Map<String, dynamic>.from(
                data['deliveryAddress'] as Map,
              )
            : <String, dynamic>{};

    final Map<String, dynamic> customer =
        data['customer'] is Map
            ? Map<String, dynamic>.from(
                data['customer'] as Map,
              )
            : <String, dynamic>{};

    final List<dynamic> items =
        data['items'] is List
            ? List<dynamic>.from(data['items'] as List)
            : <dynamic>[];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return _OrderDetailsSheet(
          gold: gold,
          orderId: orderId,
          status: status,
          paymentMethod: paymentMethod,
          paymentStatus: paymentStatus,
          subtotal: subtotal,
          deliveryFee: deliveryFee,
          grandTotal: grandTotal,
          customer: customer,
          address: address,
          items: items,
        );
      },
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> document;
  final VoidCallback onTap;

  const _OrderCard({
    required this.document,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = document.data();

    final String orderId =
        (data['orderId'] ?? document.id).toString();

    final String status =
        (data['orderStatus'] ?? 'placed').toString();

    final String paymentMethod =
        (data['paymentMethod'] ?? 'cod').toString();

    final double total = _toDouble(data['grandTotal']);

    final List<dynamic> items =
        data['items'] is List
            ? List<dynamic>.from(data['items'] as List)
            : <dynamic>[];

    final Timestamp? timestamp =
        data['createdAt'] is Timestamp
            ? data['createdAt'] as Timestamp
            : null;

    final String dateText = timestamp == null
        ? 'Order date unavailable'
        : _formatDate(timestamp.toDate());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.065),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: _MyOrdersScreenState.gold.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _MyOrdersScreenState.gold.withValues(alpha: 0.10),
                    ),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: _MyOrdersScreenState.gold,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 8,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '#${_shortOrderId(orderId)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.018),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _MiniInfo(
                    icon: Icons.calendar_today_outlined,
                    text: dateText,
                  ),
                  const Spacer(),
                  _MiniInfo(
                    icon: Icons.shopping_bag_outlined,
                    text:
                        '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total payable',
                        style: TextStyle(
                          color: Colors.white30,
                          fontSize: 8,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '₹${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: _MyOrdersScreenState.gold,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      paymentMethod == 'cod'
                          ? 'Cash on Delivery'
                          : 'Online payment',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'View details  ›',
                      style: TextStyle(
                        color: _MyOrdersScreenState.gold,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _shortOrderId(String id) {
    if (id.length <= 12) {
      return id;
    }

    return id.substring(0, 12);
  }

  static String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final String hour = date.hour == 0
        ? '12'
        : date.hour > 12
            ? '${date.hour - 12}'
            : '${date.hour}';

    final String minute =
        date.minute.toString().padLeft(2, '0');

    final String period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day} ${months[date.month - 1]} • $hour:$minute $period';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final String normalized = status.trim().toLowerCase();

    Color statusColor;

    if (normalized == 'delivered') {
      statusColor = Colors.greenAccent;
    } else if (normalized == 'cancelled' ||
        normalized == 'canceled') {
      statusColor = Colors.redAccent;
    } else if (normalized == 'out_for_delivery') {
      statusColor = Colors.orangeAccent;
    } else {
      statusColor = _MyOrdersScreenState.gold;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.16),
        ),
      ),
      child: Text(
        _displayStatus(normalized),
        style: TextStyle(
          color: statusColor,
          fontSize: 7,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _displayStatus(String value) {
    switch (value) {
      case 'placed':
        return 'PLACED';
      case 'confirmed':
        return 'CONFIRMED';
      case 'processing':
        return 'PROCESSING';
      case 'packed':
        return 'PACKED';
      case 'out_for_delivery':
        return 'OUT FOR DELIVERY';
      case 'delivered':
        return 'DELIVERED';
      case 'cancelled':
      case 'canceled':
        return 'CANCELLED';
      default:
        return value.isEmpty ? 'PLACED' : value.toUpperCase();
    }
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: _MyOrdersScreenState.gold.withValues(alpha: 0.70),
          size: 13,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final Color gold;
  final String orderId;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double subtotal;
  final double deliveryFee;
  final double grandTotal;
  final Map<String, dynamic> customer;
  final Map<String, dynamic> address;
  final List<dynamic> items;

  const _OrderDetailsSheet({
    required this.gold,
    required this.orderId,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.deliveryFee,
    required this.grandTotal,
    required this.customer,
    required this.address,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 700,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(29),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 13),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white54,
                        size: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                children: [
                  const Text(
                    'Order details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '#${_shortOrderId(orderId)}',
                    style: TextStyle(
                      color: gold,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _StatusTimeline(
                    status: status,
                    gold: gold,
                  ),
                  const SizedBox(height: 20),
                  _DetailSection(
                    title: 'ITEMS',
                    gold: gold,
                    child: items.isEmpty
                        ? const Text(
                            'No item information available.',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                            ),
                          )
                        : Column(
                            children: List.generate(
                              items.length,
                              (int index) {
                                final dynamic rawItem = items[index];

                                final Map<String, dynamic> item =
                                    rawItem is Map
                                        ? Map<String, dynamic>.from(rawItem)
                                        : <String, dynamic>{};

                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        index == items.length - 1 ? 0 : 12,
                                  ),
                                  child: _DetailItem(
                                    item: item,
                                    gold: gold,
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  const SizedBox(height: 15),
                  _DetailSection(
                    title: 'DELIVERY',
                    gold: gold,
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Name',
                          value: customer['name']?.toString() ?? '-',
                        ),
                        const SizedBox(height: 9),
                        _InfoRow(
                          label: 'Phone',
                          value: customer['phone']?.toString() ?? '-',
                        ),
                        const SizedBox(height: 9),
                        _InfoRow(
                          label: 'Address',
                          value: [
                            address['address']?.toString() ?? '',
                            address['city']?.toString() ?? '',
                            address['pincode']?.toString() ?? '',
                          ]
                              .where(
                                (String value) =>
                                    value.trim().isNotEmpty,
                              )
                              .join(', '),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  _DetailSection(
                    title: 'PAYMENT & BILL',
                    gold: gold,
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Payment',
                          value: paymentMethod == 'cod'
                              ? 'Cash on Delivery'
                              : 'Online payment',
                        ),
                        const SizedBox(height: 9),
                        _InfoRow(
                          label: 'Payment status',
                          value: _formatStatus(paymentStatus),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 13),
                          child: Divider(
                            color: Colors.white10,
                            height: 1,
                          ),
                        ),
                        _InfoRow(
                          label: 'Subtotal',
                          value:
                              '₹${subtotal.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 9),
                        _InfoRow(
                          label: 'Delivery',
                          value: deliveryFee == 0
                              ? 'FREE'
                              : '₹${deliveryFee.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 13),
                        Row(
                          children: [
                            const Text(
                              'Total payable',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '₹${grandTotal.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: gold,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
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
          ],
        ),
      ),
    );
  }

  static String _shortOrderId(String id) {
    if (id.length <= 12) {
      return id;
    }

    return id.substring(0, 12);
  }

  static String _formatStatus(String value) {
    if (value.trim().isEmpty) {
      return 'PENDING';
    }

    return value.replaceAll('_', ' ').toUpperCase();
  }
}

class _DetailItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color gold;

  const _DetailItem({
    required this.item,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    final String name = item['name']?.toString() ?? 'Product';
    final String subtitle = item['subtitle']?.toString() ?? '';
    final int quantity = _toInt(item['quantity']);
    final double price = _toDouble(item['price']);

    double total = _toDouble(item['total']);

    if (total == 0 && price > 0 && quantity > 0) {
      total = price * quantity;
    }

    final String extra = subtitle.trim().isEmpty
        ? 'Qty $quantity • ₹${price.toStringAsFixed(0)}'
        : '$subtitle • Qty $quantity • ₹${price.toStringAsFixed(0)}';

    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            color: gold,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
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
                extra,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '₹${total.toStringAsFixed(0)}',
          style: TextStyle(
            color: gold,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Color gold;
  final Widget child;

  const _DetailSection({
    required this.title,
    required this.gold,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.055),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: gold.withValues(alpha: 0.72),
              fontSize: 7,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 9,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.trim().isEmpty ? '-' : value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String status;
  final Color gold;

  const _StatusTimeline({
    required this.status,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    final String normalized = status.toLowerCase().trim();

    final List<String> steps = [
      'placed',
      'confirmed',
      'processing',
      'out_for_delivery',
      'delivered',
    ];

    int currentIndex = steps.indexOf(normalized);

    if (currentIndex < 0) {
      if (normalized == 'packed') {
        currentIndex = 2;
      } else {
        currentIndex = 0;
      }
    }

    if (normalized == 'cancelled' ||
        normalized == 'canceled') {
      return Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.redAccent.withValues(alpha: 0.13),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.cancel_outlined,
              color: Colors.redAccent,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Order cancelled',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.055),
        ),
      ),
      child: Row(
        children: List.generate(
          steps.length,
          (int index) {
            final bool completed = index <= currentIndex;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: completed
                                ? gold
                                : Colors.white.withValues(alpha: 0.05),
                            border: Border.all(
                              color: completed
                                  ? gold
                                  : Colors.white24,
                            ),
                          ),
                          child: completed
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.black,
                                  size: 13,
                                )
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _shortLabel(steps[index]),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: completed
                                ? Colors.white70
                                : Colors.white24,
                            fontSize: 6.5,
                            fontWeight: completed
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 1,
                        color: index < currentIndex
                            ? gold
                            : Colors.white12,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _shortLabel(String value) {
    switch (value) {
      case 'out_for_delivery':
        return 'On the way';
      default:
        return value
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (String word) => word.isEmpty
                  ? ''
                  : '${word[0].toUpperCase()}${word.substring(1)}',
            )
            .join(' ');
    }
  }
}

class _GlassButton extends StatelessWidget {
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
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.035),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.075),
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

class _OrdersBackground extends StatelessWidget {
  const _OrdersBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -190,
          right: -140,
          child: Container(
            width: 460,
            height: 460,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _MyOrdersScreenState.gold.withValues(alpha: 0.065),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -200,
          left: -170,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _MyOrdersScreenState.gold.withValues(alpha: 0.025),
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