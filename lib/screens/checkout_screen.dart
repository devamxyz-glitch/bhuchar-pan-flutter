// REPLACE THIS FILE
// lib/screens/checkout_screen.dart

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/cart_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  final Color _gold = const Color(0xFFD4AF37);
  final Color _background = const Color(0xFF050505);

  late final AnimationController _entryController;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  String _selectedPayment = 'cod';
  bool _placingOrder = false;

  CartService get _cart => CartService.instance;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _loadUserData();
  }

  void _loadUserData() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (user.displayName != null &&
        user.displayName!.trim().isNotEmpty) {
      _nameController.text = user.displayName!.trim();
    }

    if (user.phoneNumber != null &&
        user.phoneNumber!.trim().isNotEmpty) {
      _phoneController.text = user.phoneNumber!.trim();
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
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
            24,
          ),
          duration: const Duration(
            milliseconds: 5000,
          ),
          backgroundColor: const Color(0xFF151515),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
            side: BorderSide(
              color: (error ? Colors.redAccent : _gold)
                  .withValues(alpha: 0.20),
            ),
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                error
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: error ? Colors.redAccent : _gold,
                size: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  bool _validateForm() {
    final String name = _nameController.text.trim();
    final String phone = _phoneController.text.trim();
    final String address = _addressController.text.trim();
    final String city = _cityController.text.trim();
    final String pincode = _pincodeController.text.trim();

    if (name.isEmpty) {
      _showMessage(
        'Please enter your full name.',
        error: true,
      );
      return false;
    }

    if (phone.length != 10 ||
        int.tryParse(phone) == null) {
      _showMessage(
        'Enter a valid 10-digit mobile number.',
        error: true,
      );
      return false;
    }

    if (address.length < 8) {
      _showMessage(
        'Please enter a complete delivery address.',
        error: true,
      );
      return false;
    }

    if (city.isEmpty) {
      _showMessage(
        'Please enter your city.',
        error: true,
      );
      return false;
    }

    if (pincode.length != 6 ||
        int.tryParse(pincode) == null) {
      _showMessage(
        'Enter a valid 6-digit pincode.',
        error: true,
      );
      return false;
    }

    return true;
  }

  Future<void> _placeOrder() async {
    if (_placingOrder) return;

    if (_cart.items.isEmpty) {
      _showMessage(
        'Your cart is empty.',
        error: true,
      );
      return;
    }

    if (!_validateForm()) return;

    setState(() {
      _placingOrder = true;
    });

    try {
      final User? user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw FirebaseException(
          plugin: 'firebase_auth',
          code: 'not-authenticated',
          message:
              'No authenticated user was found. Please log in again.',
        );
      }

      final double orderTotal = _cart.grandTotal;

      final String orderId = FirebaseFirestore
          .instance
          .collection('orders')
          .doc()
          .id;

      final List<Map<String, dynamic>> orderItems =
          _cart.items.map(
        (CartItem item) {
          return {
            'productId': item.id,
            'name': item.name,
            'subtitle': item.subtitle,
            'price': item.price,
            'oldPrice': item.oldPrice,
            'quantity': item.quantity,
            'imageUrl': item.imageUrl,
            'total': item.price * item.quantity,
          };
        },
      ).toList();

      final Map<String, dynamic> orderData = {
        'orderId': orderId,
        'userId': user.uid,
        'customer': {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
        },
        'deliveryAddress': {
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'pincode': _pincodeController.text.trim(),
        },
        'items': orderItems,
        'subtotal': _cart.subtotal,
        'deliveryFee': _cart.deliveryFee,
        'grandTotal': orderTotal,
        'paymentMethod': _selectedPayment,
        'paymentStatus': 'pending',
        'orderStatus': 'placed',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .set(orderData);

      if (!mounted) return;

      _cart.clear();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => _OrderSuccessScreen(
            orderId: orderId,
            total: orderTotal,
          ),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      setState(() {
        _placingOrder = false;
      });

      _showMessage(
        'Firebase ERROR\n'
        'Code: ${error.code}\n'
        'Message: ${error.message ?? 'No message'}',
        error: true,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _placingOrder = false;
      });

      _showMessage(
        'ERROR\n$error',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final CartService cart = _cart;

    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          const _CheckoutBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _entryController,
                    builder: (
                      BuildContext context,
                      Widget? child,
                    ) {
                      final double progress =
                          CurvedAnimation(
                        parent: _entryController,
                        curve: Curves.easeOutCubic,
                      ).value;

                      return Opacity(
                        opacity: progress,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            24 * (1 - progress),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: ListView(
                      physics:
                          const BouncingScrollPhysics(),
                      padding:
                          const EdgeInsets.fromLTRB(
                        18,
                        4,
                        18,
                        150,
                      ),
                      children: [
                        _buildStepIndicator(),
                        const SizedBox(height: 18),
                        _buildSectionTitle(
                          'Delivery details',
                          Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 10),
                        _buildDeliveryCard(),
                        const SizedBox(height: 22),
                        _buildSectionTitle(
                          'Payment method',
                          Icons.account_balance_wallet_outlined,
                        ),
                        const SizedBox(height: 10),
                        _buildPaymentCard(),
                        const SizedBox(height: 22),
                        _buildSectionTitle(
                          'Order summary',
                          Icons.receipt_long_outlined,
                        ),
                        const SizedBox(height: 10),
                        _buildOrderSummary(cart),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildBottomBar(cart),
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
        13,
      ),
      child: Row(
        children: [
          _GlassButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Complete your order securely',
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
              color: _gold.withValues(alpha: 0.07),
              shape: BoxShape.circle,
              border: Border.all(
                color: _gold.withValues(alpha: 0.14),
              ),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: _gold,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          _CheckoutStep(
            number: '01',
            title: 'Details',
            active: true,
            gold: _gold,
          ),
          Expanded(
            child: Container(
              height: 1,
              margin:
                  const EdgeInsets.symmetric(horizontal: 7),
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          _CheckoutStep(
            number: '02',
            title: 'Payment',
            active: true,
            gold: _gold,
          ),
          Expanded(
            child: Container(
              height: 1,
              margin:
                  const EdgeInsets.symmetric(horizontal: 7),
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          _CheckoutStep(
            number: '03',
            title: 'Confirm',
            active: true,
            gold: _gold,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: _gold,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.065),
        ),
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Full name',
            hint: 'Enter your name',
            icon: Icons.person_outline_rounded,
            textCapitalization:
                TextCapitalization.words,
          ),
          const SizedBox(height: 11),
          _buildTextField(
            controller: _phoneController,
            label: 'Mobile number',
            hint: '10-digit mobile number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            maxLength: 10,
          ),
          const SizedBox(height: 11),
          _buildTextField(
            controller: _addressController,
            label: 'Delivery address',
            hint: 'House / flat, street, area',
            icon: Icons.home_outlined,
            maxLines: 3,
            textCapitalization:
                TextCapitalization.sentences,
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  hint: 'City',
                  icon: Icons.location_city_outlined,
                  textCapitalization:
                      TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  controller: _pincodeController,
                  label: 'Pincode',
                  hint: 'Pincode',
                  icon:
                      Icons.markunread_mailbox_outlined,
                  keyboardType:
                      TextInputType.number,
                  maxLength: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization =
        TextCapitalization.none,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 2,
            bottom: 6,
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.025,
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.065,
              ),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization:
                textCapitalization,
            maxLines: maxLines,
            maxLength: maxLength,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            cursorColor: _gold,
            buildCounter: (
              BuildContext context, {
              required int currentLength,
              required bool isFocused,
              required int? maxLength,
            }) {
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.white24,
                fontSize: 11,
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.white30,
                size: 18,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 13,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.065),
        ),
      ),
      child: Column(
        children: [
          _PaymentOption(
            title: 'Cash on Delivery',
            subtitle:
                'Pay when your order arrives',
            icon: Icons.payments_outlined,
            value: 'cod',
            selected: _selectedPayment == 'cod',
            gold: _gold,
            onTap: () {
              setState(() {
                _selectedPayment = 'cod';
              });
            },
          ),
          const SizedBox(height: 8),
          _PaymentOption(
            title: 'Online payment',
            subtitle:
                'UPI / Card / Net Banking',
            icon: Icons.credit_card_outlined,
            value: 'online',
            selected:
                _selectedPayment == 'online',
            gold: _gold,
            onTap: () {
              setState(() {
                _selectedPayment = 'online';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartService cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.065),
        ),
      ),
      child: Column(
        children: [
          ...List.generate(
            cart.items.length,
            (index) {
              final CartItem item =
                  cart.items[index];

              return Padding(
                padding: EdgeInsets.only(
                  bottom:
                      index == cart.items.length - 1
                          ? 15
                          : 11,
                ),
                child: Row(
                  children: [
                    _SummaryThumbnail(
                      imageUrl: item.imageUrl,
                      gold: _gold,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Qty ${item.quantity} × ₹${item.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white30,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                      style: TextStyle(
                        color: _gold,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(
            color: Colors.white10,
            height: 1,
          ),
          const SizedBox(height: 15),
          _BillLine(
            title: 'Subtotal',
            value:
                '₹${cart.subtotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 10),
          _BillLine(
            title: 'Delivery',
            value: cart.deliveryFee == 0
                ? 'FREE'
                : '₹${cart.deliveryFee.toStringAsFixed(0)}',
            valueColor:
                cart.deliveryFee == 0
                    ? _gold
                    : Colors.white70,
          ),
          const Padding(
            padding:
                EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              color: Colors.white10,
              height: 1,
            ),
          ),
          Row(
            children: [
              const Text(
                'Total payable',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '₹${cart.grandTotal.toStringAsFixed(0)}',
                style: TextStyle(
                  color: _gold,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CartService cart) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 25,
            sigmaY: 25,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              18,
              13,
              18,
              15,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF090909)
                  .withValues(alpha: 0.96),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(
                    alpha: 0.07,
                  ),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total payable',
                          style: TextStyle(
                            color: Colors.white30,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${cart.grandTotal.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: _gold,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _placingOrder
                        ? null
                        : _placeOrder,
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 180),
                      height: 53,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 22,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _placingOrder
                            ? _gold.withValues(
                                alpha: 0.45,
                              )
                            : _gold,
                        borderRadius:
                            BorderRadius.circular(17),
                      ),
                      child: _placingOrder
                          ? const SizedBox(
                              width: 21,
                              height: 21,
                              child:
                                  CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                Text(
                                  'Place order',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons
                                      .arrow_forward_rounded,
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
          ),
        ),
      ),
    );
  }
}

class _CheckoutStep extends StatelessWidget {
  final String number;
  final String title;
  final bool active;
  final Color gold;

  const _CheckoutStep({
    required this.number,
    required this.title,
    required this.active,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 27,
          height: 27,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? gold
                : Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: TextStyle(
              color:
                  active ? Colors.black : Colors.white38,
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color:
                active ? Colors.white70 : Colors.white30,
            fontSize: 8,
            fontWeight:
                active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final bool selected;
  final Color gold;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.selected,
    required this.gold,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected
              ? gold.withValues(alpha: 0.07)
              : Colors.white.withValues(alpha: 0.018),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? gold.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.055),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? gold.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.035),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color:
                    selected ? gold : Colors.white38,
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
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white30,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration:
                  const Duration(milliseconds: 180),
              width: 21,
              height: 21,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? gold
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? gold
                      : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.black,
                      size: 13,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _BillLine extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _BillLine({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SummaryThumbnail extends StatelessWidget {
  final String? imageUrl;
  final Color gold;

  const _SummaryThumbnail({
    required this.imageUrl,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 47,
      height: 47,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        gradient: const RadialGradient(
          colors: [
            Color(0xFF30250E),
            Color(0xFF0A0A0A),
          ],
        ),
        border: Border.all(
          color: gold.withValues(alpha: 0.08),
        ),
      ),
      child: imageUrl != null &&
              imageUrl!.trim().isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.contain,
                errorBuilder:
                    (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                ) {
                  return Icon(
                    Icons.shopping_bag_outlined,
                    color: gold,
                    size: 21,
                  );
                },
              ),
            )
          : Icon(
              Icons.shopping_bag_outlined,
              color: gold,
              size: 21,
            ),
    );
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
              color: Colors.white.withValues(
                alpha: 0.035,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.075,
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

class _CheckoutBackground extends StatelessWidget {
  const _CheckoutBackground();

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
                  const Color(0xFFD4AF37).withValues(
                    alpha: 0.065,
                  ),
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
                  const Color(0xFFD4AF37).withValues(
                    alpha: 0.025,
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

class _OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final double total;

  const _OrderSuccessScreen({
    required this.orderId,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    const Color gold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          const _CheckoutBackground(),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 105,
                      height: 105,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            gold.withValues(alpha: 0.07),
                        border: Border.all(
                          color:
                              gold.withValues(alpha: 0.20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                gold.withValues(alpha: 0.10),
                            blurRadius: 45,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: gold,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 27),
                    const Text(
                      'Order placed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Your order has been received successfully.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.025,
                        ),
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              Colors.white.withValues(
                            alpha: 0.06,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          _SuccessRow(
                            label: 'Order ID',
                            value: orderId,
                          ),
                          const SizedBox(height: 12),
                          _SuccessRow(
                            label: 'Amount',
                            value:
                                '₹${total.toStringAsFixed(0)}',
                            valueColor: gold,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .popUntil(
                          (route) => route.isFirst,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 53,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: gold,
                          borderRadius:
                              BorderRadius.circular(17),
                        ),
                        child: const Text(
                          'Back to home',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SuccessRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 9,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}