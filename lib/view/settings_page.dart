import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mp3_playlist/view_model/themes_provider.dart';
import 'package:provider/provider.dart';


class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary ,
      appBar:  AppBar(
        title: Text("A J U S T E S"),
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
            //Modo oscuro
            const Text("Modo Oscuro", style: TextStyle(fontWeight: FontWeight.bold)),
  
            
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