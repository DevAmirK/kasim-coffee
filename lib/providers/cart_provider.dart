import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.price);
  int countDrink(String id) =>
      _items.where((item) => item.drink.id == id).length;
  int quantity(CartItem item) =>
      _items.where((other) => sameConfiguration(item, other)).length;
  bool sameConfiguration(CartItem a, CartItem b) =>
      a.drink.id == b.drink.id &&
      a.size == b.size &&
      a.milk == b.milk &&
      a.syrup == b.syrup;
  List<CartItem> get positions {
    final result = <CartItem>[];
    for (final item in _items) {
      if (!result.any((other) => sameConfiguration(item, other))) {
        result.add(item);
      }
    }
    return result;
  }

  void add(CartItem item, {int? at}) {
    if (_items.contains(item)) return;
    _items.insert((at ?? _items.length).clamp(0, _items.length), item);
    notifyListeners();
  }

  void increase(CartItem item) => add(
    CartItem(
      drink: item.drink,
      size: item.size,
      milk: item.milk,
      syrup: item.syrup,
    ),
  );
  void decrease(CartItem item) {
    final index = _items.lastIndexWhere(
      (other) => sameConfiguration(item, other),
    );
    if (index < 0) return;
    _items.removeAt(index);
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.removeWhere((other) => sameConfiguration(item, other));
    notifyListeners();
  }

  void replace(CartItem original, CartItem replacement) {
    final count = quantity(original);
    if (count == 0) return;
    final index = _items.indexWhere(
      (item) => sameConfiguration(item, original),
    );
    _items.removeWhere((item) => sameConfiguration(item, original));
    _items.insertAll(
      index,
      List.generate(
        count,
        (_) => CartItem(
          drink: replacement.drink,
          size: replacement.size,
          milk: replacement.milk,
          syrup: replacement.syrup,
        ),
      ),
    );
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
