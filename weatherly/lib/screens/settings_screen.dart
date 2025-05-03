import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final Function(ThemeMode) onThemeChange;

  const SettingsScreen({required this.onThemeChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Theme"),
            trailing: DropdownButton<ThemeMode>(
              value: ThemeMode.system,
              items: [
                DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
                DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
                DropdownMenuItem(value: ThemeMode.system, child: Text("System")),
              ],
              onChanged: (mode) {
                if (mode != null) onThemeChange(mode);
              },
            ),
          ),
        ],
      ),
    );
  }
}
