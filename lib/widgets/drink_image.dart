import 'package:flutter/material.dart';

import '../models/drink.dart';
import '../theme/app_theme.dart';

class DrinkImage extends StatelessWidget {
  const DrinkImage({
    super.key,
    required this.drink,
    this.borderRadius = 0,
    this.imageUrl,
  });

  final Drink drink;
  final double borderRadius;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final source = imageUrl ?? drink.imageUrl;
    final placeholder = Container(
      color: AppTheme.accentSoft,
      alignment: Alignment.center,
      child: const Icon(Icons.local_cafe, size: 48),
    );
    if (source.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: source.startsWith('http')
          ? Image.network(
              source,
              webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            )
          : Image.asset(
              source,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}
