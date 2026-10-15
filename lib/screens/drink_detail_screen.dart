import 'package:flutter/material.dart';

import '../models/drink.dart';
import '../models/cart_item.dart';
import '../widgets/category_badge.dart';
import '../widgets/drink_image.dart';
import '../widgets/rating_stars.dart';
import '../widgets/sticky_action_bar.dart';

class DrinkDetailScreen extends StatefulWidget {
  const DrinkDetailScreen({
    super.key,
    required this.drink,
    required this.liked,
    required this.rating,
    required this.rated,
    required this.onFavorite,
    required this.onRatingChanged,
    required this.onRatingCleared,
    required this.onAddToCart,
  });
  final Drink drink;
  final bool liked;
  final double rating;
  final bool rated;
  final VoidCallback onFavorite;
  final ValueChanged<double> onRatingChanged;
  final VoidCallback onRatingCleared;
  final ValueChanged<CartItem> onAddToCart;
  @override
  State<DrinkDetailScreen> createState() => _DrinkDetailScreenState();
}

class _DrinkDetailScreenState extends State<DrinkDetailScreen> {
  String size = 'M';
  String milk = 'Whole';
  String syrup = 'None';
  late double currentRating = widget.rating;
  late bool hasRated = widget.rated;
  late bool isLiked = widget.liked;
  CartItem get selectedItem =>
      CartItem(drink: widget.drink, size: size, milk: milk, syrup: syrup);
  double get price => selectedItem.price;

  Widget choices(
    List<String> values,
    String selected,
    ValueChanged<String> onChanged,
  ) => Wrap(
    spacing: 8,
    children: values
        .map(
          (value) => ChoiceChip(
            label: Text(value),
            selected: selected == value,
            onSelected: (_) => onChanged(value),
          ),
        )
        .toList(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.drink.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.45,
                  child: DrinkImage(drink: widget.drink),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton.filled(
                    onPressed: () {
                      setState(() => isLiked = !isLiked);
                      widget.onFavorite();
                    },
                    icon: Icon(
                      isLiked ? Icons.bookmark : Icons.bookmark_border,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: Text(
                    widget.drink.title,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                RatingStars(rating: widget.drink.rating),
                const SizedBox(width: 8),
                Text(
                  '₸${price.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              hasRated
                  ? 'Your rating: ${currentRating.toInt()}/5'
                  : 'Rate this drink',
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (var stars = 1; stars <= 5; stars++)
                  IconButton(
                    tooltip: 'Rate $stars ${stars == 1 ? 'star' : 'stars'}',
                    isSelected: hasRated && stars <= currentRating,
                    onPressed: () => rate(stars.toDouble()),
                    icon: const Icon(Icons.star_border),
                    selectedIcon: const Icon(Icons.star),
                  ),
                if (hasRated)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        hasRated = false;
                        currentRating = widget.drink.rating;
                      });
                      widget.onRatingCleared();
                    },
                    child: const Text('Remove rating'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                CategoryBadge(label: widget.drink.category),
                const CategoryBadge(label: 'Milk-based'),
                const CategoryBadge(label: 'Sweet'),
                if (widget.drink.category == 'Cold')
                  const CategoryBadge(label: 'Iced')
                else
                  const CategoryBadge(label: 'Hot'),
              ],
            ),
            Text(widget.drink.description),
            const SizedBox(height: 20),
            const Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            choices(
              ['S', 'M', 'L'],
              size,
              (value) => setState(() => size = value),
            ),
            const SizedBox(height: 16),
            const Text('Milk', style: TextStyle(fontWeight: FontWeight.bold)),
            choices(
              ['Whole', 'Oat', 'Almond'],
              milk,
              (value) => setState(() => milk = value),
            ),
            const SizedBox(height: 16),
            const Text('Syrup', style: TextStyle(fontWeight: FontWeight.bold)),
            choices(
              ['None', 'Vanilla', 'Caramel', 'Hazelnut'],
              syrup,
              (value) => setState(() => syrup = value),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to menu'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: StickyActionBar(
        price: price,
        onPressed: () => widget.onAddToCart(selectedItem),
      ),
    );
  }

  void rate(double value) {
    setState(() {
      currentRating = value.round().clamp(1, 5).toDouble();
      hasRated = true;
    });
    widget.onRatingChanged(currentRating);
  }
}
