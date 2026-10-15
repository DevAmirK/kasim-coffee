import 'package:flutter/material.dart';

import '../models/user.dart';
import '../widgets/stamp_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.stamps,
    required this.favoritesCount,
    required this.ratingsGiven,
    required this.onReset,
    required this.onLogout,
  });
  final User user;
  final int stamps;
  final int favoritesCount;
  final int ratingsGiven;
  final VoidCallback onReset;
  final VoidCallback onLogout;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${user.email} • ${user.coffeeLevel}\nMember since October 2026',
            ),
          ),
        ),
        const SizedBox(height: 16),
        StampCard(stamps: stamps),
        const SizedBox(height: 8),
        Text(
          '$favoritesCount favorites • $ratingsGiven ratings given',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Reset rewards and activity'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset rewards and activity?'),
                  content: const Text(
                    'This clears your stamps, favorites and ratings. Your cart and account will be kept.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (confirmed != true || !context.mounted) return;
              onReset();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Activity reset')));
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: onLogout,
          ),
        ),
      ],
    ),
  );
}
