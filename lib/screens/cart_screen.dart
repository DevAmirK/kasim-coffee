import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import '../data/mock_drinks.dart';
import '../models/cart_item.dart';
import '../widgets/cart_product.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
    required this.items,
    required this.onItemsChanged,
    required this.onCheckout,
    required this.stamps,
    required this.navigationBar,
  });

  final Widget navigationBar;
  final List<CartItem> items;
  final int stamps;
  final VoidCallback onCheckout;
  final ValueChanged<List<CartItem>> onItemsChanged;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final items = List<CartItem>.of(widget.items);
  bool grid = false;
  int generated = 0;

  void update(VoidCallback change) {
    setState(change);
    widget.onItemsChanged(List<CartItem>.of(items));
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    update(() {
      items.insert(
        0,
        CartItem(drink: mockDrinks[generated % mockDrinks.length]),
      );
      generated++;
    });
  }

  void removeItem(CartItem item) {
    final index = items.indexOf(item);
    update(() => items.removeAt(index));
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('${item.drink.title} removed'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            if (!mounted) return;
            update(() => items.insert(index.clamp(0, items.length), item));
          },
        ),
      ),
    );
  }

  void resetCatalog() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    update(
      () => items.addAll(
        mockDrinks.take(3).map((drink) => CartItem(drink: drink)),
      ),
    );
  }

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
      update(items.clear);
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
        grid: grid,
        onRemove: () => removeItem(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.price);
    final discount = widget.stamps >= 10 && items.isNotEmpty
        ? items.map((item) => item.price).reduce((a, b) => a < b ? a : b)
        : 0.0;
    final total = subtotal - discount;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cart'),
        actions: [
          IconButton(
            tooltip: grid ? 'Show list' : 'Show grid',
            onPressed: () => setState(() => grid = !grid),
            icon: Icon(grid ? Icons.view_list : Icons.grid_view),
          ),
          if (items.isNotEmpty)
            IconButton(
              tooltip: 'Clear cart',
              onPressed: clearCart,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
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
        child: RefreshIndicator(
          onRefresh: refresh,
          child: items.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 64),
                    const Icon(Icons.shopping_bag_outlined, size: 56),
                    const SizedBox(height: 16),
                    Text(
                      'Catalog is Empty',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Restore a starter set of 3 drinks to your cart.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: FilledButton(
                        onPressed: resetCatalog,
                        child: const Text('Reset Catalog'),
                      ),
                    ),
                  ],
                )
              : grid
              ? GridView.builder(
                  key: const ValueKey('cart-grid'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, index) => product(index),
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
                      onPressed: widget.onCheckout,
                      child: const Text('Place order'),
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
