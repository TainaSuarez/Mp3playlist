import 'package:flutter/material.dart';
import 'package:mp3_playlist/components/neu_box.dart';
import 'package:mp3_playlist/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class SongPage extends StatelessWidget {
  final int songIndex;
  
  const SongPage({
    super.key,
    required this.songIndex,
  });

   //convert duration into min:sec
   String formatTime(Duration duration) {
    String twoDigitSeconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    String formattedTime = "${duration.inMinutes}:$twoDigitSeconds";
    return formattedTime;
   }
     
  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, value, child) {
      //get playlist
      final playlist = value.playlist;

      //get current song index
      final currentSongIndex = playlist[value.currentSongIndex ?? 0];

      //return a scaffold
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //app bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //back button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    //title
                    const Text("P L A Y L I S T"),
                    //menu button
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.menu),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                //album artwork
                NeuBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(value.playlist[songIndex].albumArtImagePath),
                  ),
                ),
                const SizedBox(height: 20),
                //song and artist name and icon
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //song and artist name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            value.playlist[songIndex].songName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            value.playlist[songIndex].artistName,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      //heart icon
                      Icon(
                        Icons.favorite,
                        color: Colors.red[400],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                //song duration progress
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //start time
                          Text(formatTime(value.currentDuration)),
                          //shuffle icon
                          const Icon(Icons.shuffle),
                          //repeat icon
                          const Icon(Icons.repeat),
                          //end time
                          Text(formatTime(value.totalDuration)),
                        ],
                      ),
                      //song duration progress
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                        ),
                        child: Slider(
                          min: 0,
                          max: value.totalDuration.inSeconds.toDouble(),
                          value: value.currentPosition.inSeconds.toDouble(),
                          activeColor: Colors.green,
                          onChanged: (double newValue) {
                            //duration when the user is sliding around
                          },
                          onChangeEnd: (double newValue) {
                            //sliding has finished, go to the new position is song duration
                            value.seekTo(Duration(seconds: newValue.toInt()));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                //playback controls
                Row(
                  children: [
                    //skip previous
                    Expanded(
                      child: GestureDetector(
                        onTap: value.playPreviousSong,
                        child: const NeuBox(
                          child: Icon(Icons.skip_previous),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    //play pause
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () => value.pauseOrResume(),
                        child: NeuBox(
                          child: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
                        ),
                      ),
                    ),
                    //skip forward
                    Expanded(
                      child: GestureDetector(
                        onTap: value.playNextSong,
                        child: const NeuBox(
                          child: Icon(Icons.skip_next),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
