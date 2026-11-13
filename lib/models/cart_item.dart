import 'drink.dart';

class CartItem {
  CartItem({
    required this.drink,
    String? size,
    String? milk,
    String syrup = 'None',
  }) : size = drink.volumes.containsKey(size) ? size! : drink.defaultSize,
       milk = drink.milkOptions.contains(milk) ? milk! : drink.defaultMilk,
       syrup = drink.syrupOptions.contains(syrup) ? syrup : 'None',
       id = 'cart-${_nextId++}';

  static int _nextId = 0;
  final String id;

  final Drink drink;
  final String size;
  final String milk;
  final String syrup;

  String get configuration => [
    '$size (${drink.volumeFor(size)} ml)',
    if (drink.milkOptions.isNotEmpty) '$milk milk',
    if (syrup != 'None') '$syrup syrup',
  ].join(' · ');
  double get price =>
      drink.priceFor(size) +
      (drink.milkOptions.contains(milk) && milk != drink.defaultMilk
          ? drink.milkExtra
          : 0) +
      (syrup != 'None' && drink.syrupOptions.contains(syrup)
          ? drink.syrupExtra
          : 0);
}
