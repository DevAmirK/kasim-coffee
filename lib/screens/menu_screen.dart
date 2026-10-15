import 'package:flutter/material.dart';

import '../data/mock_drinks.dart';
import '../models/drink.dart';
import '../widgets/drink_grid.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.onDrinkTap});
  final ValueChanged<Drink> onDrinkTap;
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final search = TextEditingController();
  String category = 'All';
  String query = '';
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void clearFilters() => setState(() {
    search.clear();
    query = '';
    category = 'All';
  });
  @override
  Widget build(BuildContext context) {
    final drinks = mockDrinks
        .where(
          (drink) =>
              (category == 'All' || drink.category == category) &&
              drink.title.toLowerCase().contains(query.trim().toLowerCase()),
        )
        .toList();
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kasim Coffee',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const Text('Your daily coffee, made easy'),
                  const SizedBox(height: 24),
                  Text(
                    'Find your perfect sip',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: search,
                    onChanged: (value) => setState(() => query = value),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search drinks',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Coffee', 'Cold', 'Specialty', 'Tea']
                        .map(
                          (value) => ChoiceChip(
                            label: Text(value),
                            selected: category == value,
                            onSelected: (_) => setState(() => category = value),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          if (drinks.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No drinks found',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Try another name or reset your filters.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: clearFilters,
                      child: const Text('Reset filters'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: DrinkGrid(drinks: drinks, onDrinkTap: widget.onDrinkTap),
            ),
        ],
      ),
    );
  }
}
