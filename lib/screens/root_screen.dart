import 'package:flutter/material.dart';

import '../data/mock_drinks.dart';
import '../models/drink.dart';
import '../models/cart_item.dart';
import '../models/coffee_order.dart';
import '../models/user.dart';
import 'cart_screen.dart';
import 'drink_detail_screen.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';
import 'menu_screen.dart';
import 'profile_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key, required this.user});
  final User user;
  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int tab = 0;
  final favorites = <String>{};
  final ratings = <String, double>{};
  final cart = <CartItem>[];
  final orders = <CoffeeOrder>[];
  int stamps = 0;

  void toggleFavorite(Drink drink) {
    setState(() {
      if (favorites.contains(drink.id)) {
        favorites.remove(drink.id);
      } else {
        favorites.add(drink.id);
      }
    });
  }

  void changeRating(Drink drink, double value) => setState(() {
    ratings[drink.id] = value.round().clamp(1, 5).toDouble();
  });
  void clearRating(Drink drink) => setState(() {
    ratings.remove(drink.id);
  });
  void reset() => setState(() {
    favorites.clear();
    ratings.clear();
    stamps = 0;
  });
  void openDrink(Drink drink) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => DrinkDetailScreen(
        drink: drink,
        liked: favorites.contains(drink.id),
        rating: ratings[drink.id] ?? drink.rating,
        rated: ratings.containsKey(drink.id),
        onFavorite: () => toggleFavorite(drink),
        onRatingChanged: (value) => changeRating(drink, value),
        onRatingCleared: () => clearRating(drink),
        onAddToCart: (item) {
          setState(() {
            cart.add(item);
            tab = 0;
          });
          Navigator.pop(context, true);
        },
      ),
    ),
  );

  void openCart() => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (cartContext) => CartScreen(
        items: cart,
        stamps: stamps,
        navigationBar: buildNavigationBar((value) {
          setState(() => tab = value);
          Navigator.of(cartContext).pop();
        }),
        onItemsChanged: (items) {
          setState(() {
            cart.clear();
            cart.addAll(items);
          });
        },
        onCheckout: () {
          if (cart.isEmpty) return;
          final redeem = stamps >= 10;
          final discount = redeem
              ? cart.map((item) => item.price).reduce((a, b) => a < b ? a : b)
              : 0.0;
          final order = CoffeeOrder(
            number: orders.length + 1,
            items: cart,
            discount: discount,
          );
          setState(() {
            orders.add(order);
            stamps =
                ((redeem ? stamps - 10 : stamps) +
                        cart.length -
                        (redeem ? 1 : 0))
                    .clamp(0, 10);
            cart.clear();
            tab = 0;
          });
          Navigator.of(cartContext).pop();
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Order #${order.number} confirmed'),
              content: Text(
                '${order.items.length} drinks • ₸${order.total.toStringAsFixed(0)}\n${order.discount > 0 ? 'Reward applied: ₸${order.discount.toStringAsFixed(0)}\n' : ''}Stamps: $stamps/10',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final screens = [
      MenuScreen(onDrinkTap: openDrink),
      FavoritesScreen(
        drinks: mockDrinks
            .where((drink) => favorites.contains(drink.id))
            .toList(),
        onDrinkTap: openDrink,
      ),
      ProfileScreen(
        user: widget.user,
        stamps: stamps,
        favoritesCount: favorites.length,
        ratingsGiven: ratings.length,
        onReset: reset,
        onLogout: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        ),
      ),
    ];
    return Scaffold(
      body: IndexedStack(index: tab, children: screens),
      floatingActionButton: tab == 0
          ? FloatingActionButton.extended(
              tooltip: 'Open cart',
              onPressed: openCart,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: const StadiumBorder(),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text(
                '₸${cart.fold<double>(0, (sum, item) => sum + item.price).toStringAsFixed(0)}',
              ),
            )
          : null,
      bottomNavigationBar: buildNavigationBar(
        (value) => setState(() => tab = value),
      ),
    );
  }

  Widget buildNavigationBar(ValueChanged<int> onSelected) => NavigationBar(
    selectedIndex: tab,
    onDestinationSelected: onSelected,
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.local_cafe_outlined),
        selectedIcon: Icon(Icons.local_cafe),
        label: 'Menu',
      ),
      NavigationDestination(
        icon: Icon(Icons.favorite_border),
        selectedIcon: Icon(Icons.favorite),
        label: 'Favorites',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ],
  );
}
