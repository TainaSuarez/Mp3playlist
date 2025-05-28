import 'package:flutter/material.dart';
import 'package:mp3_playlist/components/my_drawer.dart';
import 'package:mp3_playlist/models/playlist_provider.dart';
import 'package:mp3_playlist/models/song.dart';
import 'package:provider/provider.dart';
import 'package:mp3_playlist/pages/song_page.dart';

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

  Navigator.push(context, MaterialPageRoute(builder: (context) => SongPage(songIndex: index),),);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text("P L A Y L I S T")),
      drawer: const Drawer(),
      body: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          //get the playlist
          final List<Song> playlist = value.playlist;
          //return list view of songs
         return ListView.builder(
          itemCount: playlist.length,
          itemBuilder: (context, index) {
                //get individual song
                     final Song song = playlist[index];
                //return list tile
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