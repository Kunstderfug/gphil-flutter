class Song {
  final String songName;
  final String artistName;
  final String albumArtImagePath;
  final String audioPath;
  Duration? autoContinueAt;

  Song(
      {required this.songName,
      required this.artistName,
      required this.albumArtImagePath,
      required this.audioPath,
      this.autoContinueAt});
}
