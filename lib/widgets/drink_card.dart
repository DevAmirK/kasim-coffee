import '../utils/format_price.dart';

import 'package:flutter/material.dart';

import '../models/drink.dart';

import '../models/cart_item.dart';
import 'drink_image.dart';

class DrinkCard extends StatelessWidget {
  const DrinkCard({
    super.key,
    required this.drink,
    required this.onTap,
    this.animateImage = false,
  });
  final Drink drink;
  final VoidCallback onTap;
  final bool animateImage;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: animateImage
                ? Hero(
                    tag: 'product_image_${drink.id}',
                    child: DrinkImage(drink: drink),
                  )
                : DrinkImage(drink: drink),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: Text(
                drink.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
              ),
              onPressed: onTap,
              child: Text(
                'from ${formatPrice(CartItem(drink: drink, size: drink.volumes.keys.first).price)} ₸',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
