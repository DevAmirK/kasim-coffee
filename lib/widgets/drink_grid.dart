import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/drink.dart';
import 'drink_card.dart';

class DrinkGrid extends StatelessWidget {
  const DrinkGrid({super.key, required this.drinks, required this.onDrinkTap});
  final List<Drink> drinks;
  final ValueChanged<Drink> onDrinkTap;

  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) {
      final width = math.min(constraints.crossAxisExtent, 900.0);
      final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
      return SliverPadding(
        padding: EdgeInsets.symmetric(
          horizontal: (constraints.crossAxisExtent - width) / 2,
        ),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: (width - 12) / 2 + 130 * scale,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => DrinkCard(
              drink: drinks[index],
              onTap: () => onDrinkTap(drinks[index]),
            ),
            childCount: drinks.length,
          ),
        ),
      );
    },
  );
}
