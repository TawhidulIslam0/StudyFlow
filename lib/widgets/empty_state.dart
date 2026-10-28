import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action});
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 46, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 12),
      Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 7),
      Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
      if (action != null) ...[const SizedBox(height: 16), action!],
    ])),
  );
}
