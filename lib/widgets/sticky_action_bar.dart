import '../utils/format_price.dart';

import 'package:flutter/material.dart';

class StickyActionBar extends StatelessWidget {
  const StickyActionBar({
    super.key,
    required this.price,
    required this.onPressed,
  });

  final double price;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onPressed,
                key: const ValueKey('add-configured-drink'),
                icon: const Icon(Icons.add),
                label: Text('₸${formatPrice(price)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
