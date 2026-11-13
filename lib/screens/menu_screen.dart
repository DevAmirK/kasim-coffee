import 'package:flutter/material.dart';

import '../data/product_api.dart';
import '../models/drink.dart';
import '../models/product.dart';
import '../utils/format_price.dart';
import '../widgets/drink_grid.dart';
import '../widgets/drink_image.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
    required this.onDrinkTap,
    this.loadProducts = fetchProducts,
  });

  final ValueChanged<Drink> onDrinkTap;
  final Future<List<Product>> Function() loadProducts;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<Product>? products;
  String? error;
  bool loading = false;
  bool showCards = true;
  String query = '';
  String category = 'All';

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (loading) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await widget.loadProducts();
      if (!mounted) return;
      setState(() {
        products = result;
        if (!result.any((product) => product.category == category)) {
          category = 'All';
        }
        loading = false;
      });
    } on CatalogException catch (exception) {
      if (!mounted) return;
      setState(() {
        error = exception.message;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error case final message?) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: load,
                child: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      );
    }

    final catalog = products;
    if (catalog == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final categories = {'All', ...catalog.map((product) => product.category)};
    final visible = catalog
        .where(
          (product) =>
              (category == 'All' || category == product.category) &&
              product.title.toLowerCase().contains(query.trim().toLowerCase()),
        )
        .toList();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextFormField(
              initialValue: query,
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search drinks',
                suffixIcon: IconButton(
                  tooltip: showCards ? 'Show list' : 'Show cards',
                  icon: Icon(showCards ? Icons.view_list : Icons.grid_view),
                  onPressed: () => setState(() => showCards = !showCards),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final value = categories.elementAt(index);
                return ChoiceChip(
                  label: Text(value),
                  selected: category == value,
                  onSelected: (_) => setState(() => category = value),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: load,
              child: showCards && visible.isNotEmpty
                  ? CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                          sliver: DrinkGrid(
                            drinks: visible,
                            onDrinkTap: widget.onDrinkTap,
                            animateImages: true,
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      itemCount: visible.isEmpty ? 1 : visible.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        if (visible.isEmpty) {
                          return const ListTile(title: Text('No drinks found'));
                        }
                        final product = visible[index];
                        return ListTile(
                          key: ValueKey(product.id),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          leading: SizedBox.square(
                            dimension: 52,
                            child: Hero(
                              tag: 'product_image_${product.id}',
                              child: DrinkImage(
                                drink: product,
                                borderRadius: 12,
                              ),
                            ),
                          ),
                          title: Text(product.title),
                          subtitle: Text(
                            '★ ${product.rating.toStringAsFixed(1)} · ${product.category}',
                          ),
                          trailing: Text('${formatPrice(product.price)} ₸'),
                          onTap: () => widget.onDrinkTap(product),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
