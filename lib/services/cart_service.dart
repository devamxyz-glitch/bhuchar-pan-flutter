// REPLACE THIS FILE
// lib/services/cart_service.dart

import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final String category;
  final String subtitle;
  final double price;
  final double? oldPrice;
  final String? imageUrl;
  final int quantity;

  const CartItem({
    required this.id,
    required this.name,
    required this.category,
    required this.subtitle,
    required this.price,
    this.oldPrice,
    this.imageUrl,
    this.quantity = 1,
  });

  CartItem copyWith({
    String? id,
    String? name,
    String? category,
    String? subtitle,
    double? price,
    double? oldPrice,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subtitle: subtitle ?? this.subtitle,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }

  double get total => price * quantity;
}

class CartService extends ChangeNotifier {
  CartService._();

  static final CartService instance = CartService._();

  static const int minimumQuantity = 1;
  static const int maximumQuantity = 20;

  static const double freeDeliveryThreshold = 299.0;
  static const double standardDeliveryFee = 25.0;

  final List<CartItem> _items = <CartItem>[];

  List<CartItem> get items {
    return List<CartItem>.unmodifiable(_items);
  }

  bool get isEmpty {
    return _items.isEmpty;
  }

  bool get isNotEmpty {
    return _items.isNotEmpty;
  }

  int get itemCount {
    int count = 0;

    for (final CartItem item in _items) {
      count += item.quantity;
    }

    return count;
  }

  int get uniqueItemCount {
    return _items.length;
  }

  double get subtotal {
    double total = 0;

    for (final CartItem item in _items) {
      total += item.total;
    }

    return total;
  }

  double get deliveryFee {
    if (_items.isEmpty) {
      return 0;
    }

    if (subtotal >= freeDeliveryThreshold) {
      return 0;
    }

    return standardDeliveryFee;
  }

  double get grandTotal {
    return subtotal + deliveryFee;
  }

  double get amountForFreeDelivery {
    if (_items.isEmpty) {
      return 0;
    }

    if (subtotal >= freeDeliveryThreshold) {
      return 0;
    }

    return freeDeliveryThreshold - subtotal;
  }

  bool get hasFreeDelivery {
    return _items.isNotEmpty &&
        subtotal >= freeDeliveryThreshold;
  }

  bool contains(String productId) {
    return _items.any(
      (CartItem item) => item.id == productId,
    );
  }

  CartItem? getItem(String productId) {
    for (final CartItem item in _items) {
      if (item.id == productId) {
        return item;
      }
    }

    return null;
  }

  void addItem({
    required String id,
    required String name,
    required String category,
    required String subtitle,
    required double price,
    double? oldPrice,
    String? imageUrl,
    int quantity = 1,
  }) {
    final String cleanId = id.trim();

    if (cleanId.isEmpty) {
      return;
    }

    if (price < 0) {
      return;
    }

    if (quantity <= 0) {
      return;
    }

    final int safeQuantity = _clampQuantity(quantity);

    final int existingIndex = _items.indexWhere(
      (CartItem item) => item.id == cleanId,
    );

    if (existingIndex >= 0) {
      final CartItem existingItem = _items[existingIndex];

      final int newQuantity = _clampQuantity(
        existingItem.quantity + safeQuantity,
      );

      _items[existingIndex] = existingItem.copyWith(
        quantity: newQuantity,
      );
    } else {
      _items.add(
        CartItem(
          id: cleanId,
          name: name,
          category: category,
          subtitle: subtitle,
          price: price,
          oldPrice: oldPrice,
          imageUrl: imageUrl,
          quantity: safeQuantity,
        ),
      );
    }

    notifyListeners();
  }

  void updateQuantity(
    String productId,
    int quantity,
  ) {
    final int index = _items.indexWhere(
      (CartItem item) => item.id == productId,
    );

    if (index < 0) {
      return;
    }

    if (quantity <= 0) {
      _items.removeAt(index);
      notifyListeners();
      return;
    }

    final int safeQuantity = _clampQuantity(quantity);

    final CartItem currentItem = _items[index];

    if (currentItem.quantity == safeQuantity) {
      return;
    }

    _items[index] = currentItem.copyWith(
      quantity: safeQuantity,
    );

    notifyListeners();
  }

  void increment(String productId) {
    final CartItem? item = getItem(productId);

    if (item == null) {
      return;
    }

    if (item.quantity >= maximumQuantity) {
      return;
    }

    updateQuantity(
      productId,
      item.quantity + 1,
    );
  }

  void decrement(String productId) {
    final CartItem? item = getItem(productId);

    if (item == null) {
      return;
    }

    if (item.quantity <= minimumQuantity) {
      removeItem(productId);
      return;
    }

    updateQuantity(
      productId,
      item.quantity - 1,
    );
  }

  void removeItem(String productId) {
    final int index = _items.indexWhere(
      (CartItem item) => item.id == productId,
    );

    if (index < 0) {
      return;
    }

    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) {
      return;
    }

    _items.clear();
    notifyListeners();
  }

  int _clampQuantity(int quantity) {
    if (quantity < minimumQuantity) {
      return minimumQuantity;
    }

    if (quantity > maximumQuantity) {
      return maximumQuantity;
    }

    return quantity;
  }
}