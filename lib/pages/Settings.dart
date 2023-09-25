import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Color _seedColor = Colors.blue; // Default seed color

  void _updateColorScheme() {
    setState(() {
      // Update the color scheme based on the selected seed color
      final newColorScheme = ColorScheme.fromSeed(
        seedColor: _seedColor,
      );

      // Update the color scheme of the app
      final themeData = Theme.of(context).copyWith(
        colorScheme: newColorScheme,
      );
      // Theme.of(context).themeData = themeData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Seed Color'),
            trailing: CircleAvatar(
              backgroundColor: _seedColor,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Select Seed Color'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: _seedColor,
                        onColorChanged: (color) {
                          setState(() {
                            _seedColor = color;
                          });
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _updateColorScheme();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
