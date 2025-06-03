import 'dart:io';
import 'dart:isolate';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mp3_playlist/model/song.dart';
import 'package:audio_service/audio_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:permission_handler/permission_handler.dart';

class PlaylistProvider extends ChangeNotifier {
  final AudioHandler _audioHandler;
  List<Song> _playlist = [];
  int? _currentSongIndex;

  // duraciones
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // estado de reproducción
  bool _isPlaying = false;

  // getters
  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get currentDuration => _currentPosition;
  Duration get totalDuration => _totalDuration;
  AudioHandler get audioHandler => _audioHandler;

  PlaylistProvider(this._audioHandler) {
    _initAudioHandler();
    _loadPlaylist();
    _setupPlaybackStateListener(); 
    _setupMediaItemListener(); 
    _setupPositionListener(); 
  }

  Future<void> _initAudioHandler() async {
   
  }

  void _setupPlaybackStateListener() {

     _audioHandler.playbackState.listen((state) {
    final newIsPlaying = state.playing;
    if (_isPlaying != newIsPlaying) {
      _isPlaying = newIsPlaying;
      notifyListeners();
    }
  });
  }

  void _setupMediaItemListener() {
     _audioHandler.mediaItem.listen((mediaItem) {
    if (mediaItem != null) {
      _totalDuration = mediaItem.duration ?? Duration.zero;
      final index = _playlist.indexWhere((song) => 
          song.audioPath == mediaItem.id || 
          (song.localPath != null && song.localPath == mediaItem.id));
      if (index != -1) {
        _currentSongIndex = index;
        notifyListeners();
      }
    }
  });
    
  }

  void _setupPositionListener() {
    AudioService.position.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });
  }

  Future<void> _loadPlaylist() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.rafaelamorim.com.br/mobile2/musicas/list.json'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _playlist = jsonData.map((json) => Song.fromJson(json)).toList();
         await _checkDownloads(); 
        notifyListeners();
      } else {
        throw Exception('Error al cargar la playlist: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al cargar la playlist: $e');
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
  
       await _checkDownloads(); 
      notifyListeners();
    }
  }

  set currentSongIndex(int? newIndex) {
    debugPrint('PlaylistProvider.set currentSongIndex llamado con newIndex: $newIndex'); 
    if (_currentSongIndex != newIndex) {
      _currentSongIndex = newIndex;
      notifyListeners();
    }
  }


  Future<void> playSongAtIndex(int index) async {
  debugPrint('playSongAtIndex llamado con index: $index');
  if (index >= 0 && index < _playlist.length) {
    final song = _playlist[index];
    final audioId = song.localPath ?? song.audioPath;

    
    final currentMediaItem = _audioHandler.mediaItem.value;
    final bool isSameSong = currentMediaItem?.id == audioId;

    if (isSameSong && _isPlaying) {
      await pauseSong();
      return;
    }

    _currentSongIndex = index;
    
    final mediaItem = MediaItem(
      id: audioId,
      album: "Playlist MP3",
      title: song.songName,
      artist: song.artistName,
      artUri: null,
      duration: null,
    );

    try {
      
      if (!isSameSong) {
        final List<MediaItem> queue = _playlist.map((s) => MediaItem(
          id: s.localPath ?? s.audioPath,
          album: "Playlist MP3",
          title: s.songName,
          artist: s.artistName,
          artUri: null,
          duration: null,
        )).toList();

        await _audioHandler.updateQueue(queue);
        await _audioHandler.skipToQueueItem(index);
      }
      
      await _audioHandler.play();
    } catch (e) {
      debugPrint('Error al iniciar reproducción: $e');
      _playlist[index].downloadStatus = DownloadStatus.error;
      notifyListeners();
    }
  }
}

  Future<void> playCurrentSong() async {
    debugPrint('playCurrentSong llamado');
    if (_currentSongIndex != null) {
      try {
        await _audioHandler.play();
      } catch (e) {
        debugPrint('Error al reproducir la canción actual: $e');
      }
    }
  }

  Future<void> _checkDownloads() async {
      final appDocDir = await getApplicationDocumentsDirectory(); 
      for (var song in _playlist) {
         final filename = Uri.parse(song.audioPath).pathSegments.last;
         final localFile = File('${appDocDir.path}/$filename'); 

        if (await localFile.exists()) {
          song.localPath = localFile.path;
          song.downloadStatus = DownloadStatus.completed;
        } else {
           song.localPath = null;
           if (song.downloadStatus != DownloadStatus.downloading) { 
             song.downloadStatus = DownloadStatus.notStarted;
           }
        }
         
         if (song.downloadStatus != DownloadStatus.downloading && song.downloadStatus != DownloadStatus.completed) {
           song.downloadProgress = 0.0;
         }
      }
     
  }

  Future<void> pauseSong() async {
    try {
      await _audioHandler.pause();
      
    } catch (e) {
      debugPrint('Error al pausar la canción: $e');
    }
  }

  Future<void> resumeSong() async {
    debugPrint('PlaylistProvider.resumeSong() llamado'); 
    try {
      await _audioHandler.play();
    
    } catch (e) {
      debugPrint('Error al reanudar la canción: $e');
    }
  }

  Future<void> pauseOrResume() async {
    
    final state = _audioHandler.playbackState.value;
    if (state.playing) {
      await pauseSong();
    } else {
      await resumeSong();
    }
  }

  Future<void> seekTo(Duration position) async {
    await _audioHandler.seek(position);
  }

  Future<void> nextSong() async {
    await _audioHandler.skipToNext();
   
  }

  Future<void> previousSong() async {
    await _audioHandler.skipToPrevious();
    
  }

  @override
  void dispose() {
    super.dispose();
  }
}
