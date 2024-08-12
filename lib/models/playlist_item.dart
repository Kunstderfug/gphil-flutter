class PlaylistItem {
  final String sectionName;
  final String imageUrl;
  final String audioUrl;
  final Duration? autoContinueAt;

  PlaylistItem(
      {required this.sectionName,
      required this.imageUrl,
      required this.audioUrl,
      this.autoContinueAt});
}
