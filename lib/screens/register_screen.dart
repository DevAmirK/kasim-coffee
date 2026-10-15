import 'package:flutter/material.dart';

import '../data/auth_store.dart';
import '../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.onRegistered});
  final ValueChanged<User> onRegistered;
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  String role = 'Beginner';
  bool terms = false;
  bool hiddenPassword = true;
  bool hiddenConfirm = true;
  String? termsError;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  void submit() {
    setState(
      () => termsError = terms ? null : 'Please accept the terms to continue.',
    );
    if (!formKey.currentState!.validate() || !terms) return;
    final user = User(
      name: name.text.trim(),
      email: email.text.trim(),
      password: password.text,
      coffeeLevel: role,
    );
    AuthStore.registeredUser = user;
    debugPrint('Registered ${user.email} as ${user.coffeeLevel}');
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Account created!')));
    widget.onRegistered(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    const Icon(Icons.local_cafe_rounded, size: 58),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: name,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          value == null || value.trim().length < 2
                          ? 'Enter your full name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: email,
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: password,
                      obscureText: hiddenPassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => hiddenPassword = !hiddenPassword),
                          icon: Icon(
                            hiddenPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.length < 6
                          ? 'Use at least 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirm,
                      obscureText: hiddenConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        prefixIcon: Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => hiddenConfirm = !hiddenConfirm),
                          icon: Icon(
                            hiddenConfirm
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (value) => value != password.text
                          ? 'Passwords do not match'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: role,
                      decoration: const InputDecoration(
                        labelText: 'Coffee level',
                        prefixIcon: Icon(Icons.local_cafe_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Beginner',
                          child: Text('Beginner'),
                        ),
                        DropdownMenuItem(
                          value: 'Enthusiast',
                          child: Text('Enthusiast'),
                        ),
                        DropdownMenuItem(
                          value: 'Barista-level',
                          child: Text('Barista-level'),
                        ),
                      ],
                      onChanged: (value) => setState(() => role = value!),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: terms,
                      onChanged: (value) => setState(() {
                        terms = value ?? false;
                        termsError = null;
                      }),
                      title: const Text(
                        'I agree to the terms and privacy policy',
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    if (termsError != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          termsError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: submit,
                        child: const Padding(
                          padding: EdgeInsets.all(14),
                          child: Text('Create account'),
                        ),
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
