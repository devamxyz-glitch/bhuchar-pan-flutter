import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  final Color _gold = const Color(0xFFD4AF37);
  final Color _background = const Color(0xFF050505);

  late final AnimationController _entryController;

  CollectionReference<Map<String, dynamic>> get _ordersCollection {
    return FirebaseFirestore.instance.collection('orders');
  }

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  String? get _userId {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _ordersStream() {
    final String? uid = _userId;

    if (uid == null) {
      return const Stream.empty();
    }

    return _ordersCollection
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  List<_OrderData> _parseOrders(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final List<_OrderData> orders = [];

    for (final QueryDocumentSnapshot<Map<String, dynamic>> document
        in snapshot.docs) {
      final Map<String, dynamic> data = document.data();

      final dynamic rawItems = data['items'];

      final List<Map<String, dynamic>> items = [];

      if (rawItems is List) {
        for (final dynamic item in rawItems) {
          if (item is Map) {
            items.add(
              Map<String, dynamic>.from(item),
            );
          }
        }
      }

      final double total = _toDouble(
        data['grandTotal'] ??
            data['total'] ??
            data['amount'] ??
            data['totalAmount'],
      );

      final double subtotal = _toDouble(
        data['subtotal'],
        fallback: total,
      );

      final double deliveryFee = _toDouble(
        data['deliveryFee'] ??
            data['deliveryCharge'],
      );

      final String status = (
        data['status'] ??
            data['orderStatus'] ??
            'Pending'
      ).toString();

      final String orderNumber = (
        data['orderNumber'] ??
            data['orderId'] ??
            document.id
      ).toString();

      final DateTime? createdAt =
          _parseDate(data['createdAt'] ?? data['timestamp']);

      orders.add(
        _OrderData(
          id: document.id,
          orderNumber: orderNumber,
          status: status,
          total: total,
          subtotal: subtotal,
          deliveryFee: deliveryFee,
          createdAt: createdAt,
          items: items,
          address: _parseAddress(data),
          paymentMethod: (
            data['paymentMethod'] ??
                data['payment'] ??
                'Not specified'
          ).toString(),
        ),
      );
    }

    orders.sort(
      (_OrderData a, _OrderData b) {
        final DateTime aDate =
            a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        final DateTime bDate =
            b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        return bDate.compareTo(aDate);
      },
    );

    return orders;
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

  DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  String _parseAddress(
    Map<String, dynamic> data,
  ) {
    final dynamic address = data['address'];

    if (address is String) {
      return address;
    }

    if (address is Map) {
      final Map<String, dynamic> map =
          Map<String, dynamic>.from(address);

      final List<String> parts = [
        map['name']?.toString() ?? '',
        map['address']?.toString() ?? '',
        map['area']?.toString() ?? '',
        map['city']?.toString() ?? '',
        map['pincode']?.toString() ?? '',
      ].where(
        (String value) => value.trim().isNotEmpty,
      ).toList();

      return parts.join(', ');
    }

    final List<String> parts = [
      data['customerName']?.toString() ?? '',
      data['addressLine']?.toString() ?? '',
      data['city']?.toString() ?? '',
      data['pincode']?.toString() ?? '',
    ].where(
      (String value) => value.trim().isNotEmpty,
    ).toList();

    return parts.join(', ');
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Date unavailable';
    }

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

    final String day =
        date.day.toString().padLeft(2, '0');

    return '$day ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime? date) {
    if (date == null) {
      return '';
    }

    final int hour = date.hour;
    final int minute = date.minute;

    final String suffix =
        hour >= 12 ? 'PM' : 'AM';

    final int displayHour =
        hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = _userId;

    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          const _OrdersBackground(),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),

                Expanded(
                  child: uid == null
                      ? _buildLoginRequired()
                      : StreamBuilder<
                          QuerySnapshot<
                              Map<String, dynamic>>>(
                          stream: _ordersStream(),
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

                            if (!snapshot.hasData) {
                              return _buildEmpty();
                            }

                            final List<_OrderData> orders =
                                _parseOrders(
                              snapshot.data!,
                            );

                            if (orders.isEmpty) {
                              return _buildEmpty();
                            }

                            return AnimatedBuilder(
                              animation: _entryController,
                              builder: (
                                BuildContext context,
                                Widget? child,
                              ) {
                                final double progress =
                                    CurvedAnimation(
                                  parent:
                                      _entryController,
                                  curve:
                                      Curves.easeOutCubic,
                                ).value;

                                return Opacity(
                                  opacity: progress,
                                  child:
                                      Transform.translate(
                                    offset: Offset(
                                      0,
                                      24 *
                                          (1 - progress),
                                    ),
                                    child: child,
                                  ),
                                );
                              },
                              child: ListView.builder(
                                physics:
                                    const BouncingScrollPhysics(),
                                padding:
                                    const EdgeInsets.fromLTRB(
                                  18,
                                  5,
                                  18,
                                  35,
                                ),
                                itemCount: orders.length,
                                itemBuilder: (
                                  BuildContext context,
                                  int index,
                                ) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(
                                      bottom: 13,
                                    ),
                                    child:
                                        _OrderCard(
                                      order:
                                          orders[index],
                                      gold: _gold,
                                      formatDate:
                                          _formatDate,
                                      formatTime:
                                          _formatTime,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
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
      padding: const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        17,
      ),
      child: Row(
        children: [
          _GlassCircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Orders',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Track and manage your purchases',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: _gold.withValues(
                alpha: 0.07,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: _gold.withValues(
                  alpha: 0.12,
                ),
              ),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: _gold,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: _gold,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
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

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          30,
          10,
          30,
          70,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(
                  alpha: 0.055,
                ),
                border: Border.all(
                  color: _gold.withValues(
                    alpha: 0.12,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withValues(
                      alpha: 0.07,
                    ),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: _gold,
                size: 42,
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'No orders yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Your completed and active orders will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.black,
                      size: 17,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Start shopping',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
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

  Widget _buildLoginRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: _gold,
              size: 45,
            ),
            const SizedBox(height: 18),
            const Text(
              'Sign in to view your orders',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your order history is securely linked to your account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              color: _gold,
              size: 48,
            ),
            const SizedBox(height: 18),
            const Text(
              'Could not load orders',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white30,
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  final _OrderData order;
  final Color gold;
  final String Function(DateTime?) formatDate;
  final String Function(DateTime?) formatTime;

  const _OrderCard({
    required this.order,
    required this.gold,
    required this.formatDate,
    required this.formatTime,
  });

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _expanded = false;

  Color get _statusColor {
    final String status =
        widget.order.status.toLowerCase();

    if (status.contains('cancel')) {
      return Colors.redAccent;
    }

    if (status.contains('deliver') ||
        status.contains('complete') ||
        status.contains('success')) {
      return Colors.greenAccent;
    }

    if (status.contains('out') ||
        status.contains('ship') ||
        status.contains('dispatch')) {
      return Colors.blueAccent;
    }

    return widget.gold;
  }

  IconData get _statusIcon {
    final String status =
        widget.order.status.toLowerCase();

    if (status.contains('cancel')) {
      return Icons.cancel_outlined;
    }

    if (status.contains('deliver') ||
        status.contains('complete') ||
        status.contains('success')) {
      return Icons.check_circle_outline_rounded;
    }

    if (status.contains('ship') ||
        status.contains('dispatch')) {
      return Icons.local_shipping_outlined;
    }

    if (status.contains('out')) {
      return Icons.inventory_2_outlined;
    }

    return Icons.schedule_rounded;
  }

  int get _itemCount {
    int count = 0;

    for (final Map<String, dynamic> item
        in widget.order.items) {
      final dynamic quantity =
          item['quantity'] ?? item['qty'] ?? 1;

      if (quantity is num) {
        count += quantity.toInt();
      } else {
        count +=
            int.tryParse(quantity.toString()) ?? 1;
      }
    }

    return count;
  }

  String _itemName(
    Map<String, dynamic> item,
  ) {
    return (
      item['name'] ??
          item['productName'] ??
          'Product'
    ).toString();
  }

  double _itemPrice(
    Map<String, dynamic> item,
  ) {
    final dynamic value =
        item['price'] ?? item['unitPrice'] ?? 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  int _itemQuantity(
    Map<String, dynamic> item,
  ) {
    final dynamic value =
        item['quantity'] ?? item['qty'] ?? 1;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.065,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(
                          alpha: 0.08,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              _statusColor.withValues(
                            alpha: 0.14,
                          ),
                        ),
                      ),
                      child: Icon(
                        _statusIcon,
                        color: _statusColor,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORDER #${widget.order.orderNumber.toUpperCase()}',
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.formatDate(widget.order.createdAt)}'
                            '${widget.formatTime(widget.order.createdAt).isEmpty ? '' : ' • ${widget.formatTime(widget.order.createdAt)}'}',
                            style: const TextStyle(
                              color: Colors.white30,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(
                          alpha: 0.07,
                        ),
                        borderRadius:
                            BorderRadius.circular(100),
                        border: Border.all(
                          color:
                              _statusColor.withValues(
                            alpha: 0.16,
                          ),
                        ),
                      ),
                      child: Text(
                        widget.order.status
                            .toUpperCase(),
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 7,
                          fontWeight:
                              FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    _InfoItem(
                      icon:
                          Icons.shopping_bag_outlined,
                      title: 'Items',
                      value: '$_itemCount',
                    ),
                    const SizedBox(width: 9),
                    _InfoItem(
                      icon:
                          Icons.account_balance_wallet_outlined,
                      title: 'Total',
                      value:
                          '₹${widget.order.total.toStringAsFixed(0)}',
                      highlight: true,
                      gold: widget.gold,
                    ),
                  ],
                ),

                if (widget.order.items.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _expanded = !_expanded;
                      });
                    },
                    child: Row(
                      children: [
                        const Text(
                          'View order details',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 9,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration:
                              const Duration(
                            milliseconds: 220,
                          ),
                          child: const Icon(
                            Icons
                                .keyboard_arrow_down_rounded,
                            color: Colors.white38,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          AnimatedCrossFade(
            firstChild:
                const SizedBox.shrink(),
            secondChild: _buildDetails(),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration:
                const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        15,
        0,
        15,
        15,
      ),
      child: Column(
        children: [
          Divider(
            color: Colors.white.withValues(
              alpha: 0.06,
            ),
            height: 1,
          ),
          const SizedBox(height: 13),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ITEMS',
              style: TextStyle(
                color: widget.gold,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 10),

          ...widget.order.items.map(
            (Map<String, dynamic> item) {
              final int quantity =
                  _itemQuantity(item);

              final double price =
                  _itemPrice(item);

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 9,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 31,
                      height: 31,
                      decoration: BoxDecoration(
                        color: widget.gold
                            .withValues(
                          alpha: 0.055,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          9,
                        ),
                      ),
                      child: Icon(
                        Icons
                            .shopping_bag_outlined,
                        color: widget.gold,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        '${_itemName(item)} × $quantity',
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '₹${(price * quantity).toStringAsFixed(0)}',
                      style: TextStyle(
                        color: widget.gold,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 5),

          Container(
            padding:
                const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.025,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _DetailRow(
                  title: 'Subtotal',
                  value:
                      '₹${widget.order.subtotal.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  title: 'Delivery',
                  value:
                      widget.order.deliveryFee == 0
                          ? 'FREE'
                          : '₹${widget.order.deliveryFee.toStringAsFixed(0)}',
                  valueColor:
                      widget.order.deliveryFee == 0
                          ? widget.gold
                          : Colors.white70,
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  title: 'Payment',
                  value: widget
                      .order.paymentMethod,
                ),
                if (widget
                    .order.address
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _DetailRow(
                    title: 'Address',
                    value:
                        widget.order.address,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool highlight;
  final Color? gold;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
    this.highlight = false,
    this.gold,
  });

  @override
  Widget build(BuildContext context) {
    final Color valueColor = highlight
        ? (gold ?? const Color(0xFFD4AF37))
        : Colors.white;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.025,
          ),
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: 0.045,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white30,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white30,
                      fontSize: 8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
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

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 9,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color:
                  valueColor ?? Colors.white60,
              fontSize: 9,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassCircleButton
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassCircleButton({
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
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withValues(
                alpha: 0.45,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.08,
                ),
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

class _OrdersBackground
    extends StatelessWidget {
  const _OrdersBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -170,
          right: -140,
          child: Container(
            width: 450,
            height: 450,
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
          bottom: -180,
          left: -190,
          child: Container(
            width: 440,
            height: 440,
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

class _OrderData {
  final String id;
  final String orderNumber;
  final String status;
  final double total;
  final double subtotal;
  final double deliveryFee;
  final DateTime? createdAt;
  final List<Map<String, dynamic>> items;
  final String address;
  final String paymentMethod;

  const _OrderData({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    required this.subtotal,
    required this.deliveryFee,
    required this.createdAt,
    required this.items,
    required this.address,
    required this.paymentMethod,
  });
}