import 'cart_item.dart';

class CoffeeOrder {
  CoffeeOrder({
    required this.number,
    required List<CartItem> items,
    required this.discount,
  }) : items = List.unmodifiable(items);

  final int number;
  final List<CartItem> items;
  final double discount;
  double get total =>
      items.fold<double>(0, (sum, item) => sum + item.price) - discount;
}
