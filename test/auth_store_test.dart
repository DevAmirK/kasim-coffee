import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/data/auth_store.dart';
import 'package:final_project/models/user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthStore.registeredUser = null;
    AuthStore.lastEmail = null;
  });

  test('session restores without password and logout removes it', () async {
    final preferences = await SharedPreferences.getInstance();
    expect(AuthStore.restoreSession(preferences), isNull);
    const user = User(
      name: 'Amir',
      email: 'test@example.com',
      password: 'secret123',
      coffeeLevel: 'Enthusiast',
    );
    await AuthStore.saveSession(user);
    AuthStore.registeredUser = null;
    AuthStore.lastEmail = null;
    final restored = AuthStore.restoreSession(preferences)!;
    expect(restored.name, user.name);
    expect(restored.email, user.email);
    expect(restored.coffeeLevel, user.coffeeLevel);
    expect(restored.password, isEmpty);
    expect(
      preferences.getString(AuthStore.sessionKey),
      isNot(contains('secret123')),
    );
    await AuthStore.clearSession();
    expect(AuthStore.restoreSession(preferences), isNull);
  });

  test('invalid session falls back to login', () async {
    final preferences = await SharedPreferences.getInstance();
    for (final saved in ['invalid', '[]', '{}']) {
      await preferences.setString(AuthStore.sessionKey, saved);
      expect(AuthStore.restoreSession(preferences), isNull);
    }
  });
}
