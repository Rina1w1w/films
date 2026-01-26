import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final bool isDark;
  final Function(bool) onThemeChanged;

  const SettingsPage({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: SwitchListTile(
        title: const Text('Тёмная тема'),
        value: isDark,
        onChanged: onThemeChanged,
      ),
    );
  }
}
