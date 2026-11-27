import '../utils/format_price.dart';
import '../data/auth_store.dart';

import 'package:flutter/material.dart';

import '../models/drink.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/cart_bloc.dart';
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
  final favorites = <String, Drink>{};
  final ratings = <String, double>{};
  CartBloc get cartBloc => context.read<CartBloc>();

  final orders = <CoffeeOrder>[];
  int stamps = 0;

  void toggleFavorite(Drink drink) {
    setState(() {
      if (favorites.containsKey(drink.id)) {
        favorites.remove(drink.id);
      } else {
        favorites[drink.id] = drink;
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
        liked: favorites.containsKey(drink.id),
        rating: ratings[drink.id] ?? drink.rating,
        rated: ratings.containsKey(drink.id),
        onFavorite: () => toggleFavorite(drink),
        onRatingChanged: (value) => changeRating(drink, value),
        onRatingCleared: () => clearRating(drink),
        onAddToCart: (item) {
          setState(() {
            cartBloc.add(AddProductEvent(item));
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
        stamps: stamps,
        navigationBar: buildNavigationBar((value) {
          setState(() => tab = value);
          Navigator.of(cartContext).pop();
        }),
        onCheckout: () {
          final cart = cartBloc.state.items;
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
            cartBloc.add(const ClearCartEvent());
            tab = 0;
          });
          Navigator.of(cartContext).pop();
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Order #${order.number} confirmed'),
              content: Text(
                '${order.items.length} drinks • ₸${formatPrice(order.total)}\n${order.discount > 0 ? 'Reward applied: ₸${formatPrice(order.discount)}\n' : ''}Stamps: $stamps/10',
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
      HeroMode(
        enabled: tab == 0,
        child: MenuScreen(onDrinkTap: openDrink),
      ),
      FavoritesScreen(drinks: favorites.values.toList(), onDrinkTap: openDrink),
      ProfileScreen(
        user: widget.user,
        stamps: stamps,
        favoritesCount: favorites.length,
        ratingsGiven: ratings.length,
        onReset: reset,
        onLogout: () async {
          try {
            await AuthStore.clearSession();
          } catch (_) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not log out. Please try again.'),
              ),
            );
            return;
          }
          if (!context.mounted) return;
          cartBloc.add(const ClearCartEvent());
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        },
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kasim Coffee"),
        actions: [
          IconButton(
            tooltip: "Open cart",
            onPressed: openCart,
            icon: BlocBuilder<CartBloc, CartState>(
              buildWhen: (previous, current) => previous.count != current.count,
              builder: (context, cart) => Badge(
                label: Text('${cart.count}'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: tab, children: screens),
      floatingActionButton: tab == 0
          ? BlocBuilder<CartBloc, CartState>(
              builder: (context, cart) => FloatingActionButton.extended(
                tooltip: 'Open cart',
                onPressed: openCart,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: const StadiumBorder(),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text('₸${formatPrice(cart.totalPrice)}'),
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
