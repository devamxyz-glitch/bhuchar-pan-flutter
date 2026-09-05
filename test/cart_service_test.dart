import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/services/cart_service.dart';

void main() {
  group('CartService', () {
    late CartService cart;

    setUp(() {
      cart = CartService.instance;
      cart.clear();
    });

    tearDown(() {
      cart.clear();
    });

    test('starts empty', () {
      expect(cart.isEmpty, isTrue);
      expect(cart.itemCount, 0);
      expect(cart.subtotal, 0);
      expect(cart.deliveryFee, 0);
      expect(cart.grandTotal, 0);
    });

    test('adds an item correctly', () {
      cart.addItem(
        id: 'p1',
        name: 'Classic Pan',
        category: 'Pan',
        subtitle: 'Fresh pan',
        price: 50,
      );

      expect(cart.items.length, 1);
      expect(cart.itemCount, 1);
      expect(cart.subtotal, 50);
      expect(cart.deliveryFee, 25);
      expect(cart.grandTotal, 75);
    });

    test('merges duplicate product quantities', () {
      cart.addItem(
        id: 'p1',
        name: 'Classic Pan',
        category: 'Pan',
        subtitle: 'Fresh pan',
        price: 50,
        quantity: 2,
      );

      cart.addItem(
        id: 'p1',
        name: 'Classic Pan',
        category: 'Pan',
        subtitle: 'Fresh pan',
        price: 50,
        quantity: 3,
      );

      expect(cart.uniqueItemCount, 1);
      expect(cart.itemCount, 5);
      expect(cart.subtotal, 250);
    });

    test('free delivery applies at ₹299', () {
      cart.addItem(
        id: 'p1',
        name: 'Premium Pan',
        category: 'Pan',
        subtitle: 'Premium',
        price: 299,
      );

      expect(cart.subtotal, 299);
      expect(cart.deliveryFee, 0);
      expect(cart.grandTotal, 299);
      expect(cart.hasFreeDelivery, isTrue);
    });

    test('calculates amount remaining for free delivery', () {
      cart.addItem(
        id: 'p1',
        name: 'Pan',
        category: 'Pan',
        subtitle: 'Fresh',
        price: 100,
      );

      expect(cart.amountForFreeDelivery, 199);
      expect(cart.hasFreeDelivery, isFalse);
    });

    test('increment increases quantity', () {
      cart.addItem(
        id: 'p1',
        name: 'Pan',
        category: 'Pan',
        subtitle: 'Fresh',
        price: 50,
      );

      cart.increment('p1');

      expect(cart.getItem('p1')!.quantity, 2);
      expect(cart.itemCount, 2);
    });

    test('decrement decreases quantity', () {
      cart.addItem(
        id: 'p1',
        name: 'Pan',
        category: 'Pan',
        subtitle: 'Fresh',
        price: 50,
        quantity: 3,
      );

      cart.decrement('p1');

      expect(cart.getItem('p1')!.quantity, 2);
    });

    test('decrement removes item at minimum quantity', () {
      cart.addItem(
        id: 'p1',
        name: 'Pan',
        category: 'Pan',
        subtitle: 'Fresh',
        price: 50,
      );

      cart.decrement('p1');

      expect(cart.isEmpty, isTrue);
    });

    test('quantity is capped at maximum 20', () {
      cart.addItem(
        id: 'p1',
        name: 'Pan',
        category: 'Pan',
        subtitle: 'Fresh',
        price: 50,
        quantity: 50,
      );

      expect(cart.getItem('p1')!.quantity, 20);
    });

    test('removes an item', () {
      cart.addItem(
        id: 'p1',
        name: 'Pan',
        category: 'Pan',
        subtitle: 'Fresh',
        price: 50,
      );

      cart.removeItem('p1');

      expect(cart.isEmpty, isTrue);
    });

    test('clear removes all items', () {
      cart.addItem(
        id: 'p1',
        name: 'Pan',
        category: 'Pan',
        subtitle: 'Fresh',
        price: 50,
      );

      cart.addItem(
        id: 'p2',
        name: 'Cold Drink',
        category: 'Drinks',
        subtitle: 'Cold',
        price: 40,
      );

      cart.clear();

      expect(cart.isEmpty, isTrue);
      expect(cart.itemCount, 0);
    });
  });
}
