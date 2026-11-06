import '../utils/format_price.dart';

import 'package:flutter/material.dart';

import '../models/drink.dart';
import '../models/cart_item.dart';

import '../widgets/drink_image.dart';

class DrinkDetailScreen extends StatefulWidget {
  const DrinkDetailScreen({
    super.key,
    required this.drink,
    this.initialItem,
    required this.liked,
    required this.rating,
    required this.rated,
    required this.onFavorite,
    required this.onRatingChanged,
    required this.onRatingCleared,
    required this.onAddToCart,
  });
  final CartItem? initialItem;
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
  late String size = widget.initialItem?.size ?? 'M';
  late String milk = widget.initialItem?.milk ?? 'Whole';
  late String syrup = widget.initialItem?.syrup ?? 'None';
  late double currentRating = widget.rating;
  late bool hasRated = widget.rated;
  late bool isLiked = widget.liked;
  CartItem get selectedItem =>
      CartItem(drink: widget.drink, size: size, milk: milk, syrup: syrup);
  double get price => selectedItem.price;

  Widget options(
    String label,
    List<String> values,
    String selected,
    ValueChanged<String> change,
  ) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 5),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final segmentWidth = (constraints.maxWidth - 8) / values.length;
            return Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE9E7DF),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOutCubic,
                    left: segmentWidth * values.indexOf(selected),
                    top: 0,
                    bottom: 0,
                    width: segmentWidth,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  Row(
                    children: values
                        .map(
                          (value) => Expanded(
                            child: Semantics(
                              selected: value == selected,
                              button: true,
                              child: InkWell(
                                splashFactory: NoSplash.splashFactory,
                                overlayColor: const WidgetStatePropertyAll(
                                  Colors.transparent,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                onTap: () {
                                  if (value != selected) change(value);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 11,
                                    horizontal: 5,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    ),
  );

  void showRating() => showModalBottomSheet<void>(
    context: context,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Rate this drink',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => IconButton(
                  tooltip: 'Rate ${index + 1} stars',
                  icon: Icon(
                    index < currentRating && hasRated
                        ? Icons.star
                        : Icons.star_border,
                  ),
                  onPressed: () {
                    setState(() {
                      currentRating = index + 1.0;
                      hasRated = true;
                    });
                    widget.onRatingChanged(currentRating);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            if (hasRated)
              TextButton(
                onPressed: () {
                  setState(() => hasRated = false);
                  widget.onRatingCleared();
                  Navigator.pop(context);
                },
                child: const Text('Remove rating'),
              ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: DrinkImage(drink: widget.drink),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: IconButton.filledTonal(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    if (widget.initialItem == null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton.filledTonal(
                          tooltip: 'Favorite',
                          onPressed: () {
                            setState(() => isLiked = !isLiked);
                            widget.onFavorite();
                          },
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.drink.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Center(
                child: InkWell(
                  onTap: widget.initialItem == null ? showRating : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 18,
                          color: Color(0xFF9A6800),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${hasRated ? currentRating.toStringAsFixed(1) : widget.drink.rating}  ·  ${hasRated ? 'Your rating' : 'Rate drink'}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                widget.drink.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
              options(
                'Size',
                ['S', 'M', 'L'],
                size,
                (value) => setState(() => size = value),
              ),
              options(
                'Milk · alternatives +50 ₸',
                ['Whole', 'Oat', 'Almond'],
                milk,
                (value) => setState(() => milk = value),
              ),
              options(
                'Syrup · extra +40 ₸',
                ['None', 'Vanilla', 'Caramel', 'Hazelnut'],
                syrup,
                (value) => setState(() => syrup = value),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 56,
                child: FilledButton(
                  key: const ValueKey('add-configured-drink'),
                  onPressed: () => widget.onAddToCart(selectedItem),
                  child: Text(
                    '${widget.initialItem == null ? 'Add for' : 'Save changes ·'} ${formatPrice(price)} ₸',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
