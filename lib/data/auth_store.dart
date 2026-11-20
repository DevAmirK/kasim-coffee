import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthStore {
  static User? registeredUser;
  static String? lastEmail;
  static const sessionKey = 'active_user_profile';

  static User? restoreSession(SharedPreferences preferences) {
    final saved = preferences.getString(sessionKey);
    if (saved == null) return null;
    try {
      final json = jsonDecode(saved) as Map<String, dynamic>;
      final user = User(
        name: json['name'] as String,
        email: json['email'] as String,
        coffeeLevel: json['coffeeLevel'] as String,
        password: '', // Passwords are never persisted in preferences.
      );
      lastEmail = user.email;
      return user;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  static Future<void> saveSession(User user) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      sessionKey,
      jsonEncode({
        'name': user.name,
        'email': user.email,
        'coffeeLevel': user.coffeeLevel,
      }),
    );
    if (!saved) throw StateError('Could not save session');
    lastEmail = user.email;
  }

  static Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.remove(sessionKey)) {
      throw StateError('Could not clear session');
    }
  }
}
