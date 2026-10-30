import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/data/mock_drinks.dart';
import 'package:final_project/models/cart_item.dart';
import 'package:final_project/screens/cart_screen.dart';

void main() {
  late List<CartItem> cart;

  Future<void> openCart(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: CartScreen(
          items: cart,
          onItemsChanged: (value) => cart = value,
          onCheckout: () {},
          stamps: 0,
          navigationBar: const SizedBox(height: 60),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'duplicate drinks have unique keys; swipe undo restores order and total',
    (tester) async {
      cart = [
        CartItem(drink: mockDrinks[0]),
        CartItem(drink: mockDrinks[0]),
        CartItem(drink: mockDrinks[1]),
      ];
      final original = List<CartItem>.of(cart);
      await openCart(tester);
      await tester.drag(
        find.byKey(ValueKey(original[1].id)),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();
      expect(cart.map((item) => item.id), [original[0].id, original[2].id]);
      expect(find.text('Total ₸2000'), findsOneWidget);
      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();
      expect(cart, orderedEquals(original));
      expect(find.text('Total ₸2900'), findsOneWidget);
      await tester.tap(find.byTooltip('Show grid'));
      await tester.pumpAndSettle();
      expect(find.byType(GridView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('empty cart restores seed drinks and can become empty again', (
    tester,
  ) async {
    cart = [];
    await openCart(tester);
    expect(find.text('Catalog is Empty'), findsOneWidget);
    await tester.tap(find.text('Reset Catalog'));
    await tester.pumpAndSettle();
    expect(
      cart.map((item) => item.drink.id),
      mockDrinks.take(3).map((drink) => drink.id),
    );
    for (var i = 0; i < 3; i++) {
      await tester.drag(find.byType(Dismissible).first, const Offset(-500, 0));
      await tester.pumpAndSettle();
    }
    expect(cart, isEmpty);
    expect(find.text('Catalog is Empty'), findsOneWidget);
    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    expect(cart.single.drink.id, 'latte');
    expect(tester.takeException(), isNull);
  });

  testWidgets('mouse pull refresh waits then prepends in list and grid', (
    tester,
  ) async {
    cart = [CartItem(drink: mockDrinks[2])];
    await openCart(tester);
    for (var i = 0; i < 2; i++) {
      final scroll = find.byKey(ValueKey(i == 0 ? 'cart-list' : 'cart-grid'));
      await tester.drag(
        scroll,
        const Offset(0, 350),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(cart.length, i + 1);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(cart.length, i + 2);
      expect(cart.first.drink.id, mockDrinks[i].id);
      expect(cart.map((item) => item.id).toSet().length, cart.length);
      if (i == 0) {
        await tester.tap(find.byTooltip('Show grid'));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('grid fits narrow screens and larger text; builders stay lazy', (
    tester,
  ) async {
    cart = List.generate(
      1000,
      (i) => CartItem(drink: mockDrinks[i % mockDrinks.length]),
    );
    await openCart(tester);
    expect(find.byType(Dismissible).evaluate().length, lessThan(100));
    await tester.tap(find.byTooltip('Show grid'));
    await tester.pumpAndSettle();
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final width in [320.0, 390.0, 1200.0]) {
      tester.view.physicalSize = Size(width, 844);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(Dismissible).evaluate().length, lessThan(100));
    }
  });
}
