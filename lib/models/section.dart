class InitSection {
  bool? metronomeAvailable;
  String name;
  bool? autoContinue;
  int movementIndex;
  String key;
  SectionImage? sectionImage;
  int? beatsPerBar;
  List<int> tempoRangeFull;
  double? defaultSectionLength;
  int step;
  int? beatLength;
  Duration? autoContinueMarker;
  int defaultTempo;
  int? userTempo;

  InitSection({
    this.metronomeAvailable,
    required this.name,
    this.autoContinue,
    required this.movementIndex,
    required this.key,
    this.sectionImage,
    this.beatsPerBar,
    required this.tempoRangeFull,
    this.defaultSectionLength,
    required this.step,
    this.beatLength,
    this.autoContinueMarker,
    required this.defaultTempo,
    this.userTempo,
  });

  factory InitSection.fromJson(Map<String, dynamic> json) => InitSection(
        metronomeAvailable: json["metronomeAvailable"],
        name: json["name"],
        autoContinue: json["autoContinue"],
        movementIndex: json["movementIndex"],
        key: json["_key"],
        sectionImage: json["sectionImage"] == null
            ? null
            : SectionImage.fromJson(json["sectionImage"]),
        beatsPerBar: json["beatsPerBar"],
        tempoRangeFull: List<int>.from(json["tempoRangeFull"].map((x) => x)),
        defaultSectionLength: json["defaultSectionLength"]?.toDouble(),
        step: json["step"],
        beatLength: json["beatLength"],
        autoContinueMarker: json["autoContinueMarker"] == null
            ? null
            : Duration(
                milliseconds:
                    convertToDuration(json["autoContinueMarker"].toDouble())),
        defaultTempo: json["defaultTempo"],
        userTempo: json["userTempo"] ?? json["defaultTempo"],
      );
}

class SectionImageAsset {
  final String ref;

  SectionImageAsset({
    required this.ref,
  });

  factory SectionImageAsset.fromJson(Map<String, dynamic> json) =>
      SectionImageAsset(
        ref: json["_ref"],
      );
}

int convertToDuration(double duration) {
  return (duration * 1000).round();
}

class SectionImage {
  final String type;
  SectionImageAsset asset;

  SectionImage({
    required this.type,
    required this.asset,
  });

  factory SectionImage.fromJson(Map<String, dynamic> json) => SectionImage(
        type: json["_type"],
        asset: SectionImageAsset.fromJson(json["asset"]),
      );
}

class Section extends InitSection {
  List<int> tempoRange;
  List<String> fileList;
  late int sectionIndex;

  Section({
    required super.name,
    required super.movementIndex,
    required super.key,
    required super.tempoRangeFull,
    required super.step,
    required super.defaultTempo,
    super.defaultSectionLength,
    super.metronomeAvailable,
    super.beatsPerBar,
    super.autoContinue,
    super.autoContinueMarker,
    super.sectionImage,
    super.userTempo,
    required this.tempoRange,
    required this.fileList,
    required this.sectionIndex,
  });

  factory Section.fromJson(Map<String, dynamic> json) => Section(
        metronomeAvailable: json["metronomeAvailable"],
        name: json["name"],
        movementIndex: json["movementIndex"],
        key: json["_key"],
        tempoRangeFull: List<int>.from(json["tempoRangeFull"].map((x) => x)),
        step: json["step"],
        defaultTempo: json["defaultTempo"],
        tempoRange: [],
        fileList: [],
        defaultSectionLength: json["defaultSectionLength"]?.toDouble(),
        sectionIndex: json["sectionIndex"],
        sectionImage: json["sectionImage"] == null
            ? null
            : SectionImage.fromJson(json["sectionImage"]),
        beatsPerBar: json["beatsPerBar"],
        autoContinue: json["autoContinue"],
        autoContinueMarker: json["autoContinueMarker"] == null
            ? null
            : Duration(
                milliseconds:
                    convertToDuration(json["autoContinueMarker"].toDouble())),
        userTempo: json["userTempo"],
      );
}
