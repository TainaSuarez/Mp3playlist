import 'package:flutter/material.dart';
import 'package:mp3_playlist/model/song.dart';
import 'package:mp3_playlist/view/components/my_drawer.dart';
import 'package:mp3_playlist/view_model/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'song_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late final dynamic playlistProvider;

  @override
  void initState() {
    super.initState();

    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
  }
   
void goToSong(int index) {
  playlistProvider.currentSongIndex = index;

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SongPage()),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text("P L A Y L I S T")),
      drawer: const MyDeawer(),
      body: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          final List<Song> playlist = value.playlist;
         return ListView.builder(
          itemCount: playlist.length,
          itemBuilder: (context, index) {
                     final Song song = playlist[index];
                return ListTile(
                  title: Text(song.songName),
                  subtitle: Text(song.artistName),
                  leading: Image.asset(song.albumArtImagePath),
                  onTap: () => goToSong(index)
                );
          }
         );
        },
        ),
      );
    
  }

}