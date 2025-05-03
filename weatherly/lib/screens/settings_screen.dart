import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherly/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: (value) => settings.toggleDarkMode(value),
          ),
          ListTile(
            title: const Text('Theme Color'),
            trailing: Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
            onTap: () => _showThemeColorPicker(context),
          ),
          
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Rain Alerts'),
            value: settings.rainAlertsEnabled,
            onChanged: (value) => settings.toggleRainAlerts(value),
          ),
          SwitchListTile(
            title: const Text('Temperature Alerts'),
            value: settings.tempAlertsEnabled,
            onChanged: (value) => settings.toggleTempAlerts(value),
          ),
          
          _buildSectionHeader('Units'),
          RadioListTile<TemperatureUnit>(
            title: const Text('Celsius'),
            value: TemperatureUnit.celsius,
            groupValue: settings.temperatureUnit,
            onChanged: (unit) => settings.setTemperatureUnit(unit!),
          ),
          RadioListTile<TemperatureUnit>(
            title: const Text('Fahrenheit'),
            value: TemperatureUnit.fahrenheit,
            groupValue: settings.temperatureUnit,
            onChanged: (unit) => settings.setTemperatureUnit(unit!),
          ),
          
          _buildSectionHeader('About'),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  void _showThemeColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme Color'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            children: [
              _colorOption(context, Colors.blue, 'Blue'),
              _colorOption(context, Colors.green, 'Green'),
              _colorOption(context, Colors.orange, 'Orange'),
              _colorOption(context, Colors.purple, 'Purple'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorOption(BuildContext context, Color color, String label) {
    return InkWell(
      onTap: () {
        context.read<SettingsProvider>().setPrimaryColor(color);
        Navigator.pop(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}