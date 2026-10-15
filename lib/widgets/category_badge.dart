import 'package:flutter/material.dart';

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      side: BorderSide.none,
    );
  }
}
