import 'drink.dart';

class CartItem {
  const CartItem({
    required this.drink,
    this.size = 'M',
    this.milk = 'Whole',
    this.syrup = 'None',
  });

  final Drink drink;
  final String size;
  final String milk;
  final String syrup;

  String get configuration =>
      '$size • $milk milk • ${syrup == 'None' ? 'No syrup' : '$syrup syrup'}';
  double get price =>
      drink.price +
      (size == 'S'
          ? -50
          : size == 'L'
          ? 75
          : 0) +
      (milk == 'Whole' ? 0 : 50) +
      (syrup == 'None' ? 0 : 40);
}
