import 'package:flutter/material.dart';
import 'song.dart';
import 'package:just_audio/just_audio.dart';

class PlaylistProvider extends ChangeNotifier{
  //playlist of songs
  final List<Song> _playlist = [
    Song(
      songName: "Crush",
      artistName: "Andree Amos/Isaac Elsie/Jace Amos/Patmixedit Patmixedit",
      albumArtImagePath: "assets/images/default_album_art.png",
      audioPath: "https://www.rafaelamorim.com.br/mobile2/musicas/AXIS1237_01_Crush_Full.mp3",
    ),
    Song(
      songName: "When Duty Calls",
      artistName: "Nathan Forsbach/Ross Redmond",
      albumArtImagePath: "assets/images/default_album_art.png",
      audioPath: "https://www.rafaelamorim.com.br/mobile2/musicas/AXIS1188_11_When%20Duty%20Calls_Full.mp3",
    ),
    Song(
      songName: "Higher Self",
      artistName: "John Cimino",
      albumArtImagePath: "assets/images/default_album_art.png",
      audioPath: "https://www.rafaelamorim.com.br/mobile2/musicas/AXIS1199_01_Higher%20Self_Full.mp3",
    ),
  ];

  //current song playing index
  int? _currentSongIndex;

  // AUDIOPLAYER
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Duraciones
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Estado de reproducción
  bool _isPlaying = false;

  // Getters
  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get currentDuration => _currentPosition;
  Duration get totalDuration => _totalDuration;
  AudioPlayer get audioPlayer => _audioPlayer;

  // Constructor
  PlaylistProvider() {
    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration = duration;
        notifyListeners();
      }
    });
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
  }

  // Setters
  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;
    if (newIndex != null) {
      playSong(_playlist[newIndex].audioPath);
    }
    notifyListeners();
  }

  // Reproducir canción
  Future<void> playSong(String url) async {
    await _audioPlayer.setUrl(url);
    await _audioPlayer.play();
  }

  // Pausar canción
  Future<void> pauseSong() async {
    await _audioPlayer.pause();
  }

  // Reanudar canción
  Future<void> resumeSong() async {
    await _audioPlayer.play();
  }

  // Pausar o reanudar
  Future<void> pauseOrResume() async {
    if (_audioPlayer.playing) {
      await pauseSong();
    } else {
      await resumeSong();
    }
  }

  // Ir a una posición específica
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Siguiente canción
  void playNextSong() {
    if (_currentSongIndex != null && _currentSongIndex! < _playlist.length - 1) {
      _currentSongIndex = _currentSongIndex! + 1;
      playSong(_playlist[_currentSongIndex!].audioPath);
      notifyListeners();
    }
  }

  // Canción anterior
  void playPreviousSong() {
    if (_currentSongIndex != null && _currentSongIndex! > 0) {
      _currentSongIndex = _currentSongIndex! - 1;
      playSong(_playlist[_currentSongIndex!].audioPath);
      notifyListeners();
    }
  }
}

