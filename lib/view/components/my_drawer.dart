import 'package:flutter/material.dart';
import 'package:mp3_playlist/view/settings_page.dart';

class MyDeawer extends StatelessWidget{
  const MyDeawer({super.key});
@override
Widget build(BuildContext context) {
  
  return Drawer(
    backgroundColor: Theme.of(context).colorScheme.background,
    child: Column(
      children: [
        
        DrawerHeader(
          child: Center(
            child: Icon(
              Icons.music_note, size: 40,
              color: Theme.of(context).colorScheme.inversePrimary
              ),
              ),
              ),

        Padding(
          padding: const EdgeInsets.only(left:25.0, top: 25),
          child: ListTile(
            title: const Text("H O M E"),
            leading: const Icon(Icons.home),
            onTap: () => Navigator.pop(context),
            
            ),
        
      ),

        Padding(
          padding: const EdgeInsets.only(left:25.0, top: 0),
          child: ListTile(
            title: const Text("A J U S T E S"),
            leading: const Icon(Icons.settings),
            onTap: () {
              
              Navigator.pop(context);

              
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