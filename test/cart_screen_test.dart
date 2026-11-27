import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:final_project/data/mock_drinks.dart';
import 'package:final_project/models/cart_item.dart';
import 'package:final_project/blocs/cart_bloc.dart';
import 'package:final_project/screens/cart_screen.dart';
import 'package:final_project/widgets/drink_card.dart';

Future<void> dispatch(CartBloc cart, CartEvent event) async {
  final updated = cart.stream.first;
  cart.add(event);
  await updated;
}

void main() {
  test('quantities preserve extras and order snapshots', () async {
    final cart = CartBloc();
    addTearDown(cart.close);
    final item = CartItem(
      drink: mockDrinks.firstWhere((drink) => drink.id == 'latte'),
      size: 'L',
      milk: 'Oat',
      syrup: 'Vanilla',
    );
    await dispatch(cart, AddProductEvent(item));
    final snapshot = cart.state.items;
    await dispatch(
      cart,
      AddProductEvent(
        CartItem(
          drink: item.drink,
          size: item.size,
          milk: item.milk,
          syrup: item.syrup,
        ),
      ),
    );
    expect(cart.state.quantity(item), 2);
    expect(cart.state.totalPrice, item.price * 2);
    expect(snapshot.length, 1);
    await dispatch(cart, AddProductEvent(CartItem(drink: item.drink)));
    expect(cart.state.positions.length, 2);
    await dispatch(cart, DecreaseProductEvent(item));
    expect(cart.state.quantity(item), 1);
    await dispatch(cart, RemoveProductEvent(item.id));
    expect(cart.state.count, 1);
    final replacement = CartItem(drink: item.drink, size: 'S', milk: 'Almond');
    await dispatch(cart, AddProductEvent(CartItem(drink: item.drink)));
    await dispatch(
      cart,
      ReplaceProductEvent(cart.state.items.first, replacement),
    );
    expect(cart.state.quantity(replacement), 2);
    expect(cart.state.totalPrice, replacement.price * 2);
    await dispatch(
      cart,
      AddProductEvent(CartItem(drink: item.drink, size: 'L')),
    );
    await dispatch(
      cart,
      ReplaceProductEvent(cart.state.positions.last, replacement),
    );
    expect(cart.state.positions.length, 1);
    expect(cart.state.quantity(replacement), 3);
    await dispatch(cart, const ClearCartEvent());
    expect(cart.state.totalPrice, 0);
  });
  testWidgets('cart changes immediately update mounted catalog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final cart = CartBloc();
    addTearDown(cart.close);
    cart.add(AddProductEvent(CartItem(drink: mockDrinks.first)));
    await tester.pumpWidget(
      BlocProvider.value(
        value: cart,
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  height: 300,
                  width: 200,
                  child: DrinkCard(
                    drink: mockDrinks.firstWhere(
                      (drink) => drink.id == 'latte',
                    ),
                    onTap: () {},
                  ),
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
    expect(cart.state.count, 1);
    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pumpAndSettle();
    expect(cart.state.count, 2);
    await tester.tap(find.byTooltip('Decrease quantity'));
    await tester.pumpAndSettle();
    expect(cart.state.count, 1);
    await tester.tap(find.text('Clear All'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear cart'));
    await tester.pumpAndSettle();
    expect(find.textContaining('from '), findsOneWidget);
    expect(cart.state.count, 0);
    expect(tester.takeException(), isNull);
  });
}
