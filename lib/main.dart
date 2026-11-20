import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/local_storage_service.dart';
import 'data/auth_store.dart';
import 'models/user.dart';
import 'screens/root_screen.dart';
import 'providers/settings_provider.dart';

import 'providers/cart_provider.dart';

import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final settings = SettingsProvider(LocalStorageService(preferences));
  runApp(
    KasimCoffeeApp(
      settings: settings,
      initialUser: AuthStore.restoreSession(preferences),
    ),
  );
}

class KasimCoffeeApp extends StatelessWidget {
  const KasimCoffeeApp({super.key, required this.settings, this.initialUser});

  final SettingsProvider settings;
  final User? initialUser;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider.value(value: settings),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) => MaterialApp(
          title: 'Kasim Coffee',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              ...const MaterialScrollBehavior().dragDevices,
              PointerDeviceKind.mouse,
            },
          ),
          home: initialUser == null
              ? const LoginScreen()
              : RootScreen(user: initialUser!),
        ),
      ),
    );
  }
}
