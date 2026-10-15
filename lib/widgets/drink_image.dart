import 'package:flutter/material.dart';

import '../models/drink.dart';
import '../theme/app_theme.dart';

class DrinkImage extends StatelessWidget {
  const DrinkImage({super.key, required this.drink, this.borderRadius = 0});

  final Drink drink;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        'assets/drinks/${drink.id}.jpg',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: AppTheme.accentSoft,
          alignment: Alignment.center,
          child: const Icon(Icons.local_cafe, size: 48),
        ),
      ),
    );
  }
}
