import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../widgets/drink_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.items,
    required this.onRemove,
    required this.onCheckout,
    required this.stamps,
    required this.onClear,
    required this.navigationBar,
  });

  final Widget navigationBar;
  final List<CartItem> items;
  final int stamps;
  final VoidCallback onClear;
  final VoidCallback onCheckout;
  final ValueChanged<CartItem> onRemove;

  @override
  Widget build(BuildContext context) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.price);
    final discount = stamps >= 10 && items.isNotEmpty
        ? items.map((item) => item.price).reduce((a, b) => a < b ? a : b)
        : 0.0;
    final total = subtotal - discount;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cart'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: 'Clear cart',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear your cart?'),
                    content: const Text(
                      'All drinks will be removed from your cart.',
                    ),
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
                if (confirmed == true && context.mounted) onClear();
              },
            ),
        ],
      ),
      body: items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Your cart is empty.\nAdd a drink from the menu to get started.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                final drink = item.drink;
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 104,
                        height: 104,
                        child: DrinkImage(drink: drink),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                drink.title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(item.configuration),
                              const SizedBox(height: 6),
                              Text(
                                '₸${item.price.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  tooltip: 'Remove from cart',
                                  onPressed: () => onRemove(item),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
                      Text(
                        'Free drink reward: −₸${discount.toStringAsFixed(0)}',
                      ),
                    Text(
                      'Total ₸${total.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: onCheckout,
                      child: const Text('Place order'),
                    ),
                  ],
                ),
              ),
            ),
          navigationBar,
        ],
      ),
    );
  }
}
