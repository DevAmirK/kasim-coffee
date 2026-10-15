import 'package:flutter/material.dart';

import '../models/drink.dart';
import '../widgets/drink_grid.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.drinks,
    required this.onDrinkTap,
  });
  final List<Drink> drinks;
  final ValueChanged<Drink> onDrinkTap;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: CustomScrollView(
      slivers: [
        const SliverAppBar(title: Text('Your favorites'), floating: true),
        if (drinks.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('Save a drink to see it here.')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: DrinkGrid(drinks: drinks, onDrinkTap: onDrinkTap),
          ),
      ],
    ),
  );
}
