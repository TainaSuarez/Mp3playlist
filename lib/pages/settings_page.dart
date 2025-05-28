import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mp3_playlist/themes/themes_provider.dart'; // Corrige la importación

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary ,
      appBar:  AppBar(
        title: Text("S E T T I N G S"),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //dark mode 
            const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.bold)),
  
            //itch
            CupertinoSwitch(
              value: Provider.of<ThemesProvider>(context).isDarkMode,
              onChanged: (value) =>
                  Provider.of<ThemesProvider>(context, listen: false).toggleTheme(),
            )
          ],
        ),
      ),
    );
  }
}