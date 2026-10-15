import 'package:flutter/material.dart';

class StampCard extends StatelessWidget {
  const StampCard({super.key, required this.stamps});

  final int stamps;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kasim Coffee rewards',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF222222),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Collect 10 stamps and your next drink is on us.',
              style: TextStyle(color: Color(0xFF444444)),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(10, (index) {
                final filled = index < stamps;
                return CircleAvatar(
                  radius: 19,
                  backgroundColor: filled
                      ? const Color(0xFF222222)
                      : Colors.white54,
                  child: Icon(
                    filled ? Icons.check : Icons.local_cafe,
                    color: filled ? const Color(0xFFF9E532) : Colors.white,
                    size: 19,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
