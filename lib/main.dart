import 'package:flutter/material.dart';
import 'package:mp3_playlist/view/home_page.dart';
import 'package:mp3_playlist/view_model/playlist_provider.dart';
import 'package:mp3_playlist/view_model/themes_provider.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
   MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => ThemesProvider()),
    ChangeNotifierProvider(create: (context) => PlaylistProvider()),

   ],
    child: const MyApp(),
   ),
  );
}

class MyApp extends StatelessWidget {
const MyApp ({super.key});

@override
Widget build(BuildContext context){
return MaterialApp(
debugShowCheckedModeBanner: false,
home: const HomePage(),
theme: Provider.of<ThemesProvider>(context).themeData
);

}

}