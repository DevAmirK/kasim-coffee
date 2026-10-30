import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import 'category_badge.dart';
import 'drink_image.dart';

class CartProduct extends StatelessWidget {
  const CartProduct({
    super.key,
    required this.item,
    required this.grid,
    required this.onRemove,
  });

  final CartItem item;
  final bool grid;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final drink = item.drink;
    final price = '₸${item.price.toStringAsFixed(0)}';
    if (!grid) {
      return ListTile(
        leading: SizedBox(
          width: 56,
          height: 56,
          child: DrinkImage(drink: drink, borderRadius: 8),
        ),
        title: Text(drink.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CategoryBadge(label: drink.category),
                Text('★ ${drink.rating}'),
              ],
            ),
            Text(item.configuration),
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: IconButton(
          tooltip: 'Remove from cart',
          onPressed: onRemove,
          icon: const Icon(Icons.delete_outline),
        ),
      );
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                DrinkImage(drink: drink),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton.filledTonal(
                    tooltip: 'Remove from cart',
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drink.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${drink.category} · ★ ${drink.rating}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.configuration,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
