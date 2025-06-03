import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter/foundation.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler, QueueHandler {
  final AudioPlayer _player = AudioPlayer();
  List<MediaItem> _queue = [];
  int _currentIndex = 0;

  MyAudioHandler() {
    _player.playbackEventStream.listen((event) {
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          _player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: const [0, 1, 2],
        playing: _player.playing,
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ));
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  AudioPlayer get player => _player;

  @override
  Future<void> play() async {
    debugPrint('MyAudioHandler.play() llamado');
    return _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_queue.isNotEmpty) {
      _currentIndex = (_currentIndex + 1) % _queue.length;
      await _playCurrentItem();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_queue.isNotEmpty) {
      _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
      await _playCurrentItem();
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    debugPrint('skipToQueueItem llamado con index: $index');
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      await _playCurrentItem();
    } else {
      debugPrint('Error en skipToQueueItem: Índice fuera de rango');
    }
  }

  Future<void> _playCurrentItem() async {
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      final mediaItem = _queue[_currentIndex];
      debugPrint('Intentando reproducir: ${mediaItem.title} (${mediaItem.id})');
      try {
        final audioSource = AudioSource.uri(
          Uri.parse(mediaItem.id),
          tag: mediaItem,
        );
         debugPrint('AudioSource creado. Estableciendo fuente...');
        await _player.setAudioSource(audioSource);
         debugPrint('Fuente establecida. Intentando reproducir...');
        await play(); 
         debugPrint('Llamada a play() completada.');
      } catch (e) {
        debugPrint('Error al reproducir en _playCurrentItem: $e');
        
      }
    } else {
      debugPrint('Error: _currentIndex ($_currentIndex) fuera de rango para la cola (longitud ${_queue.length})');
    }
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    debugPrint('Actualizando cola con ${queue.length} items');
    this.queue.add(queue);
    _queue = List<MediaItem>.from(queue);
     debugPrint('Cola interna actualizada. Nueva longitud: ${_queue.length}');
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    final index = _queue.indexWhere((item) => item.id == mediaItem.id);
    if (index != -1) {
      _currentIndex = index;
      await _playCurrentItem();
    } else {
      _queue.add(mediaItem);
      _currentIndex = _queue.length - 1;
      await _playCurrentItem();
    }
  }
}
