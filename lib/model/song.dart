class Song {
  final String songName;
  final String artistName;
  final String albumArtImagePath;
  final String audioPath;
  String? localPath;
  DownloadStatus downloadStatus;
  double downloadProgress;

  Song({
    required this.songName,
    required this.artistName,
    required this.albumArtImagePath,
    required this.audioPath,
    this.localPath,
    this.downloadStatus = DownloadStatus.notStarted,
    this.downloadProgress = 0.0,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      songName: json['title'] as String,
      artistName: json['author'] as String,
      albumArtImagePath: "assets/images/default_album_art.png",
      audioPath: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': songName,
      'author': artistName,
      'url': audioPath,
      'albumArtImagePath': albumArtImagePath,
      'localPath': localPath,
      'downloadStatus': downloadStatus.toString(),
      'downloadProgress': downloadProgress,
    };
  }
}

enum DownloadStatus {
  notStarted,
  downloading,
  completed,
  error,
  paused
}