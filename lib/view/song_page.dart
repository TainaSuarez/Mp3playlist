import 'package:flutter/material.dart';
import 'package:mp3_playlist/view/components/neu_box.dart';
import 'package:mp3_playlist/view_model/playlist_provider.dart';
import 'package:provider/provider.dart';

class SongPage extends StatelessWidget {
  final int songIndex;
  
  const SongPage({
    super.key,
    required this.songIndex,
  });

   
   String formatTime(Duration duration) {
    String twoDigitSeconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    String formattedTime = "${duration.inMinutes}:$twoDigitSeconds";
    return formattedTime;
   }
     
  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, value, child) {
     
      final playlist = value.playlist;

  
      final currentSongIndex = playlist[value.currentSongIndex ?? 0];

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    
                    const Text("P L A Y L I S T"),
                    
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.menu),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                
                NeuBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(value.playlist[songIndex].albumArtImagePath),
                  ),
                ),
                const SizedBox(height: 20),
                
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     
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
                      
                      Icon(
                        Icons.favorite,
                        color: Colors.red[400],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                         
                          Text(formatTime(value.currentDuration)),
                          
                          const Icon(Icons.shuffle),
                         
                          const Icon(Icons.repeat),
                          
                          Text(formatTime(value.totalDuration)),
                        ],
                      ),
                      
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
                            
                          },
                          onChangeEnd: (double newValue) {
                           
                            value.seekTo(Duration(seconds: newValue.toInt()));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                
                Row(
                  children: [
                  
                    Expanded(
                      child: GestureDetector(
                        onTap: value.playPreviousSong,
                        child: const NeuBox(
                          child: Icon(Icons.skip_previous),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () => value.pauseOrResume(),
                        child: NeuBox(
                          child: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
                        ),
                      ),
                    ),
                   
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
