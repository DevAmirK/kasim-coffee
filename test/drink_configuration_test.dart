import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/data/mock_drinks.dart';
import 'package:final_project/models/cart_item.dart';

void main() {
  test('espresso supports shots without milk or syrup charges', () {
    final espresso = mockDrinks.firstWhere((drink) => drink.id == 'espresso');
    final single = CartItem(drink: espresso, milk: 'Oat', syrup: 'Vanilla');
    expect(single.size, 'Single');
    expect(single.milk, 'None');
    expect(single.syrup, 'None');
    expect(single.price, 900);
    expect(CartItem(drink: espresso, size: 'Double').price, 1200);
  });

  test('latte combines size, alternative milk and syrup charges', () {
    final latte = mockDrinks.firstWhere((drink) => drink.id == 'latte');
    expect(CartItem(drink: latte).price, 1200);
    expect(
      CartItem(drink: latte, size: 'L', milk: 'Oat', syrup: 'Vanilla').price,
      2000,
    );
  });

  test('catalog configurations have valid volumes and prices', () {
    expect(
      mockDrinks.map((drink) => drink.id).toSet().length,
      mockDrinks.length,
    );
    for (final drink in mockDrinks) {
      expect(drink.ingredients, isNotEmpty);
      expect(drink.volumes.keys, containsAll(drink.sizeExtras.keys));
      for (final size in drink.volumes.keys) {
        expect(drink.volumeFor(size), greaterThan(0));
        expect(drink.priceFor(size), greaterThan(0));
      }
    }
  });
}
