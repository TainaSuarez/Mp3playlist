import 'package:flutter/material.dart';
import 'package:mp3_playlist/services/my_audio_handler.dart';
import 'package:mp3_playlist/view/home_page.dart';
import 'package:mp3_playlist/view_model/playlist_provider.dart';
import 'package:mp3_playlist/view_model/themes_provider.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.mp3_playlist.channel.audio',
    androidNotificationChannelName: 'Reproducción de audio',
    androidNotificationOngoing: true,
  );

  final audioHandler = MyAudioHandler();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemesProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider(audioHandler)), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MP3 Playlist',
      theme: Provider.of<ThemesProvider>(context).themeData,
      home: const HomePage(),
    );
  }
}
