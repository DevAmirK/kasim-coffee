import '../utils/format_price.dart';

import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../widgets/cart_product.dart';
import 'drink_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
    required this.onCheckout,
    required this.stamps,
    required this.navigationBar,
  });

  final Widget navigationBar;
  final int stamps;
  final VoidCallback onCheckout;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  CartProvider get cart => context.read<CartProvider>();
  List<CartItem> get items => cart.positions;

  void removeItem(CartItem item) => cart.remove(item);

  void editItem(CartItem item) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (detailContext) => DrinkDetailScreen(
        drink: item.drink,
        initialItem: item,
        liked: false,
        rating: item.drink.rating,
        rated: false,
        onFavorite: () {},
        onRatingChanged: (_) {},
        onRatingCleared: () {},
        onAddToCart: (replacement) {
          cart.replace(item, replacement);
          Navigator.of(detailContext).pop();
        },
      ),
    ),
  );

  Future<void> clearCart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear your cart?'),
        content: const Text('All drinks will be removed from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear cart'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      cart.clear();
    }
  }

  Widget product(int index) {
    final item = items[index];
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => removeItem(item),
      child: CartProduct(
        item: item,
        onEdit: () => editItem(item),
        quantity: cart.quantity(item),
        onIncrease: () => cart.increase(item),
        onDecrease: () => cart.decrease(item),
        onRemove: () => removeItem(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = context.watch<CartProvider>().totalPrice;
    final discount = widget.stamps >= 10 && items.isNotEmpty
        ? items.map((item) => item.price).reduce((a, b) => a < b ? a : b)
        : 0.0;
    final total = subtotal - discount;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cart'),
        actions: [
          if (items.isNotEmpty)
            TextButton(onPressed: clearCart, child: const Text('Clear All')),
        ],
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
            PointerDeviceKind.invertedStylus,
            PointerDeviceKind.trackpad,
          },
        ),
        child: items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 64),
                  const Icon(Icons.shopping_bag_outlined, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Choose a drink and customize it in the menu.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back to menu'),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                key: const ValueKey('cart-list'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, thickness: 0.5),
                itemBuilder: (_, index) => product(index),
              ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (items.isNotEmpty)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (discount > 0)
                      Text('Free drink reward: −₸${formatPrice(discount)}'),
                    FilledButton(
                      onPressed: widget.onCheckout,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: Text('Checkout · ${formatPrice(total)} ₸'),
                    ),
                  ],
                ),
              ),
            ),
          widget.navigationBar,
        ],
      ),
    );
  }
}
