import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.darkMode, required this.onDarkModeChanged});
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(child: ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        const Text('Make your study space your own.'),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(22)),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.auto_stories_rounded, color: Colors.white)),
            const SizedBox(width: 13),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('StudyFlow', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              SizedBox(height: 3),
              Text('Your free study companion'),
            ])),
            const Icon(Icons.check_circle, color: Color(0xFF16866B)),
          ]),
        ),
        const SizedBox(height: 18),
        Card(color: scheme.surface, child: Column(children: [
          SwitchListTile(value: darkMode, onChanged: onDarkModeChanged, secondary: const Icon(Icons.dark_mode_outlined), title: const Text('Dark theme'), subtitle: const Text('Use a darker appearance')),
        ])),
        const SizedBox(height: 18),
        Text('Privacy', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Card(color: scheme.surface, child: const Column(children: [
          ListTile(leading: Icon(Icons.wifi_off_outlined), title: Text('Works offline'), subtitle: Text('No account or internet required.')),
          Divider(height: 1),
          ListTile(leading: Icon(Icons.lock_outline), title: Text('Stored on this device'), subtitle: Text('No backend, analytics, or ad SDK.')),
          Divider(height: 1),
          ListTile(leading: Icon(Icons.money_off_csred_outlined), title: Text('Always free'), subtitle: Text('No subscriptions, ads, or in-app purchases.')),
        ])),
        const SizedBox(height: 20),
        Center(child: Text('StudyFlow • Version 1.0.0', style: Theme.of(context).textTheme.bodySmall)),
      ],
    ));
  }
}
