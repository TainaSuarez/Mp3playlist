import 'package:flutter/material.dart';
import 'package:mp3_playlist/pages/settings_page.dart';

class MyDeawer extends StatelessWidget{
  const MyDeawer({super.key});
@override
Widget build(BuildContext context) {
  // This widget is the root of your application.
  return Drawer(
    backgroundColor: Theme.of(context).colorScheme.background,
    child: Column(
      children: [
        //logo
        DrawerHeader(
          child: Center(
            child: Icon(
              Icons.music_note, size: 40,
              color: Theme.of(context).colorScheme.inversePrimary
              ),
              ),
              ),

        //home tile
        Padding(
          padding: const EdgeInsets.only(left:25.0, top: 25),
          child: ListTile(
            title: const Text("H O M E"),
            leading: const Icon(Icons.home),
            onTap: () => Navigator.pop(context),
            
            ),
        
      ),

        //settings tile
        Padding(
          padding: const EdgeInsets.only(left:25.0, top: 0),
          child: ListTile(
            title: const Text("S E T T I N G S"),
            leading: const Icon(Icons.settings),
            onTap: () {
              //pop drawer
              Navigator.pop(context);

              //navigator to settings
              Navigator.push(
                context,
                 MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                  ),
                  );
            },
            
            ),
        ),
      ],
    ),
  );
}
}