import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:final_project/data/mock_drinks.dart';
import 'package:final_project/models/cart_item.dart';
import 'package:final_project/providers/cart_provider.dart';
import 'package:final_project/screens/cart_screen.dart';
import 'package:final_project/widgets/drink_card.dart';

void main() {
  test('quantities preserve extras and order snapshots', () {
    final cart = CartProvider();
    final item = CartItem(
      drink: mockDrinks.first,
      size: 'L',
      milk: 'Oat',
      syrup: 'Vanilla',
    );
    cart.add(item);
    final snapshot = cart.items;
    cart.increase(item);
    expect(cart.quantity(item), 2);
    expect(cart.totalPrice, item.price * 2);
    expect(snapshot.length, 1);
    cart.add(CartItem(drink: item.drink));
    expect(cart.positions.length, 2);
    cart.decrease(item);
    expect(cart.quantity(item), 1);
    cart.remove(item);
    expect(cart.itemCount, 1);
    final replacement = CartItem(drink: item.drink, size: 'S', milk: 'Almond');
    cart.increase(cart.items.first);
    cart.replace(cart.items.first, replacement);
    expect(cart.quantity(replacement), 2);
    expect(cart.totalPrice, replacement.price * 2);
    cart.add(CartItem(drink: item.drink, size: 'L'));
    cart.replace(cart.positions.last, replacement);
    expect(cart.positions.length, 1);
    expect(cart.quantity(replacement), 3);
    cart.clear();
    expect(cart.totalPrice, 0);
  });
  testWidgets('cart changes immediately update mounted catalog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final cart = CartProvider();
    cart.add(CartItem(drink: mockDrinks.first));
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: cart,
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  height: 300,
                  width: 200,
                  child: DrinkCard(drink: mockDrinks.first, onTap: () {}),
                ),
                Expanded(
                  child: CartScreen(
                    onCheckout: () {},
                    stamps: 0,
                    navigationBar: const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(cart.itemCount, 1);
    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pumpAndSettle();
    expect(cart.itemCount, 2);
    await tester.tap(find.byTooltip('Decrease quantity'));
    await tester.pumpAndSettle();
    expect(cart.itemCount, 1);
    await tester.tap(find.text('Clear All'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear cart'));
    await tester.pumpAndSettle();
    expect(find.textContaining('from '), findsOneWidget);
    expect(cart.itemCount, 0);
    expect(tester.takeException(), isNull);
  });
}
