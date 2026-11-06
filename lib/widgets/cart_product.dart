import '../utils/format_price.dart';

import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import 'drink_image.dart';

class CartProduct extends StatelessWidget {
  const CartProduct({
    super.key,
    required this.item,
    required this.onRemove,
    this.quantity = 1,
    this.onIncrease,
    this.onDecrease,
    this.onEdit,
  });
  final CartItem item;
  final int quantity;
  final VoidCallback onRemove;
  final VoidCallback? onIncrease, onDecrease, onEdit;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 76,
          height: 88,
          child: DrinkImage(drink: item.drink, borderRadius: 16),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.drink.title,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove from cart',
                    onPressed: onRemove,
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              Text(
                item.configuration,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextButton.icon(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: const Color(0xFF8A5700),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Decrease quantity',
                          onPressed: onDecrease,
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          tooltip: 'Increase quantity',
                          onPressed: onIncrease,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${formatPrice(item.price * quantity)} ₸',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
