import 'package:flutter/material.dart';
import 'package:mp3_playlist/view/components/neu_box.dart';
import 'package:mp3_playlist/view_model/playlist_provider.dart';
import 'package:mp3_playlist/model/song.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';

class SongPage extends StatelessWidget {
  const SongPage({super.key});

  String formatTime(Duration duration) {
    String twoDigitSeconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    String formattedTime = "${duration.inMinutes}:$twoDigitSeconds";
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, value, child) {
      final playlist = value.playlist;
      final currentSongIndex = value.currentSongIndex;

      if (currentSongIndex == null || currentSongIndex < 0 || currentSongIndex >= playlist.length) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(title: const Text("P L A Y L I S T")),
          body: const Center(child: Text("Selecciona una canción")),
        );
      }

      final songFromList = playlist[currentSongIndex];

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
                  ],
                ),
                const SizedBox(height: 25),
                NeuBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(songFromList.albumArtImagePath),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              songFromList.songName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              songFromList.artistName,
                              style: TextStyle(color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
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
                          Text(formatTime(value.currentPosition)),
                          const Icon(Icons.shuffle),
                          const Icon(Icons.repeat),
                          Text(formatTime(Duration(
                            seconds: value.audioHandler.mediaItem.value?.duration?.inSeconds ?? 0
                          ))),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                        ),
                        child: Slider(
                          min: 0,
                          max: value.audioHandler.mediaItem.value?.duration?.inSeconds.toDouble() ?? 0,
                          value: value.currentPosition.inSeconds
                              .toDouble()
                              .clamp(0.0, value.audioHandler.mediaItem.value?.duration?.inSeconds.toDouble() ?? 0),
                          activeColor: Colors.green,
                          onChanged: (double newValue) {},
                          onChangeEnd: (double newValue) {
                            value.seekTo(Duration(seconds: newValue.toInt()));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (songFromList.downloadStatus == DownloadStatus.downloading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        const Text("Cargando..."),
                        LinearProgressIndicator(value: songFromList.downloadProgress),
                      ],
                    ),
                  ),
                if (songFromList.downloadStatus == DownloadStatus.error)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text("Error", style: TextStyle(color: Colors.red)),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: value.previousSong,
                        child: const NeuBox(child: Icon(Icons.skip_previous)),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final index = value.currentSongIndex;
                          if (index == null) return;
                          
                          if (!value.isPlaying) {
                            value.playCurrentSong();
                          } else {
                            value.playSongAtIndex(index);
                          }
                        },
                        child: NeuBox(
                          child: Icon(
                            Icons.play_arrow,
                            size: 28,
                            color: value.isPlaying ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (value.isPlaying) {
                            value.pauseSong();
                          }
                        },
                        child: NeuBox(
                          child: Icon(
                            Icons.pause,
                            size: 28,
                            color: value.isPlaying ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final index = value.currentSongIndex;
                          if (index == null) return;
                          value.seekTo(Duration.zero);
                          value.playSongAtIndex(index);
                        },
                        child: const NeuBox(
                          child: Icon(Icons.restart_alt, size: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: GestureDetector(
                        onTap: value.nextSong,
                        child: const NeuBox(child: Icon(Icons.skip_next)),
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
