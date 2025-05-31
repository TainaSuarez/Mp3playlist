import 'dart:io';
import 'dart:isolate';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mp3_playlist/model/song.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:permission_handler/permission_handler.dart';

class PlaylistProvider extends ChangeNotifier {
  List<Song> _playlist = [];
  int? _currentSongIndex;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // duraciones
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // estado de reproducción
  bool _isPlaying = false;

  // estado de descarga
  Map<String, bool> _downloaded = {};

  // getters
  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get currentDuration => _currentPosition;
  Duration get totalDuration => _totalDuration;
  AudioPlayer get audioPlayer => _audioPlayer;
  bool isDownloaded(String url) => _downloaded[url] ?? false;

  // constructor
  PlaylistProvider() {
    _initAudioPlayer();
    _loadPlaylist();
  }

  Future<void> _initAudioPlayer() async {
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
    _checkDownloads();
  }

  Future<void> _loadPlaylist() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.rafaelamorim.com.br/mobile2/musicas/list.json'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _playlist = jsonData.map((json) => Song.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Error al cargar la playlist: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al cargar la playlist: $e');
      // en caso de que de error va usar una lista de respaldo 
      _playlist = [
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
      notifyListeners();
    }
  }

  // setters
  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;
    if (newIndex != null) {
      final song = _playlist[newIndex];
      final url = song.audioPath;
      if (_downloaded[url] == true) {
        _playFromFile(url);
      } else {
        playSong(url);
        _startDownloadInBackground(url);
      }
    }
    notifyListeners();
  }

  // desde la url reproducir
  Future<void> playSong(String url) async {
    await _audioPlayer.setUrl(url);
    await _audioPlayer.play();
  }

  // reproducir cancion local
  Future<void> _playFromFile(String url) async {
    final file = await _getLocalFile(url);
    if (await file.exists()) {
      await _audioPlayer.setFilePath(file.path);
      await _audioPlayer.play();
    }
  }

  // descarga segundo plano
  void _startDownloadInBackground(String url) async {
    final ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_downloadIsolate, [url, receivePort.sendPort]);
    receivePort.listen((dynamic message) async {
      if (message == true) {
        _downloaded[url] = true;
        notifyListeners();
      }
    });
  }

  static void _downloadIsolate(List<dynamic> args) async {
    final String url = args[0];
    final SendPort sendPort = args[1];
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = await _getLocalFileStatic(url);
        await file.writeAsBytes(response.bodyBytes);
        sendPort.send(true);
      } else {
        sendPort.send(false);
      }
    } catch (_) {
      sendPort.send(false);
    }
  }

  static Future<File> _getLocalFileStatic(String url) async {
    final dir = await getApplicationDocumentsDirectory();
    final filename = Uri.parse(url).pathSegments.last;
    return File('${dir.path}/$filename');
  }

  Future<File> _getLocalFile(String url) async {
    return _getLocalFileStatic(url);
  }

  // verificar q canciones ya estan descargadas
  void _checkDownloads() async {
    for (var song in _playlist) {
      final file = await _getLocalFile(song.audioPath);
      if (await file.exists()) {
        _downloaded[song.audioPath] = true;
      }
    }
    notifyListeners();
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

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Siguiente canción
  void playNextSong() {
    if (_currentSongIndex != null && _currentSongIndex! < _playlist.length - 1) {
      _currentSongIndex = _currentSongIndex! + 1;
      currentSongIndex = _currentSongIndex;
      notifyListeners();
    }
  }

  // Canción anterior
  void playPreviousSong() {
    if (_currentSongIndex != null && _currentSongIndex! > 0) {
      _currentSongIndex = _currentSongIndex! - 1;
      currentSongIndex = _currentSongIndex;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

