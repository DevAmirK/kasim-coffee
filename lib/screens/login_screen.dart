import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/auth_store.dart';
import '../models/user.dart';
import 'register_screen.dart';
import 'root_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.registeredUser});
  final User? registeredUser;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool hidden = true;

  @override
  void initState() {
    super.initState();
    email.text = AuthStore.lastEmail ?? AuthStore.registeredUser?.email ?? '';
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;
    final user = widget.registeredUser ?? AuthStore.registeredUser;
    AuthStore.lastEmail = email.text.trim();
    if (user != null &&
        (user.email != email.text.trim() || user.password != password.text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Wrong email or password')));
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RootScreen(
          user:
              user ??
              User(
                name: email.text.split('@').first,
                email: email.text.trim(),
                password: password.text,
                coffeeLevel: 'Beginner',
              ),
        ),
      ),
    );
  }

  void quickLogin() {
    final user = AuthStore.registeredUser;
    if (user == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => RootScreen(user: user)),
    );
  }

  void developmentLogin() {
    const user = User(
      name: 'Test User',
      email: 'test@example.com',
      password: 'test123',
      coffeeLevel: 'Beginner',
    );
    AuthStore.lastEmail = user.email;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RootScreen(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('☕', style: TextStyle(fontSize: 58)),
                    Text(
                      'Welcome to Kasim Coffee',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Your cozy corner for better coffee.'),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) =>
                          value == null ||
                              !value.contains('@') ||
                              !value.contains('.')
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: password,
                      obscureText: hidden,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => hidden = !hidden),
                          icon: Icon(
                            hidden ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.length < 6
                          ? 'Use at least 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: submit,
                        child: const Padding(
                          padding: EdgeInsets.all(14),
                          child: Text('Sign in'),
                        ),
                      ),
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: developmentLogin,
                          icon: const Icon(Icons.bolt),
                          label: const Text('Quick login'),
                        ),
                      ),
                    ],
                    if (AuthStore.registeredUser != null) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: quickLogin,
                          icon: const Icon(Icons.bolt),
                          label: Text(
                            'Quick login as ${AuthStore.registeredUser!.name}',
                          ),
                        ),
                      ),
                    ],
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RegisterScreen(
                              onRegistered: (user) => Navigator.of(context)
                                  .pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => RootScreen(user: user),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        child: const Text('New here? Create an account'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

