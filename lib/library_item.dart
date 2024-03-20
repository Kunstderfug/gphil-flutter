class LibraryItem {
  final String composer;
  final String pathName;
  final String shortTitle;
  final bool? private;
  final bool? ready;
  final int complete;
  final String slug;

  LibraryItem({
    required this.pathName,
    required this.slug,
    this.composer = '',
    this.shortTitle = '',
    this.private,
    this.ready,
    this.complete = 0,
  });

  factory LibraryItem.fromJson(Map<String, dynamic> json) {
    return LibraryItem(
      composer: json['composer'],
      pathName: json['pathName'],
      shortTitle: json['shortTitle'],
      private: json['private'],
      ready: json['ready'],
      complete: json['complete'],
      slug: json['slug'],
    );
  }
}
