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
  int? tempoMultiplier;
  List<String>? layers;

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
    this.tempoMultiplier,
    this.layers,
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
        tempoMultiplier: json["tempoMultiplier"],
        layers:
            json["layers"] == null ? null : List<String>.from(json["layers"]),
      );

  Map<String, dynamic> toJson() => {
        "metronomeAvailable": metronomeAvailable,
        "name": name,
        "autoContinue": autoContinue,
        "movementIndex": movementIndex,
        "_key": key,
        "sectionImage": sectionImage == null
            ? null
            : SectionImage.fromJson(sectionImage!.toJson()),
        "beatsPerBar": beatsPerBar,
        "tempoRangeFull": List<dynamic>.from(tempoRangeFull.map((x) => x)),
        "defaultSectionLength": defaultSectionLength,
        "step": step,
        "beatLength": beatLength,
        "autoContinueMarker": autoContinueMarker != null
            ? convertToDouble(autoContinueMarker!.inMilliseconds)
            : null,
        "defaultTempo": defaultTempo,
        "userTempo": userTempo,
        "tempoMultiplier": tempoMultiplier,
        "layers": layers,
      };
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

  Map<String, dynamic> toJson() => {
        "_ref": ref,
      };
}

int convertToDuration(double duration) {
  return (duration * 1000).round();
}

double convertToDouble(int duration) {
  return duration / 1000;
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

  Map<String, dynamic> toJson() => {
        "_type": type,
        "asset": asset.toJson(),
      };
}

class Section extends InitSection {
  late String scoreId = '';
  List<int> tempoRange;
  List<String> fileList;
  String? clickDataUrl = '';
  late int sectionIndex;
  late String movementKey;
  double? sectionVolume;

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
    super.beatLength,
    super.autoContinue,
    super.autoContinueMarker,
    super.sectionImage,
    super.userTempo,
    super.tempoMultiplier,
    super.layers,
    required this.tempoRange,
    required this.fileList,
    required this.sectionIndex,
    this.clickDataUrl,
    this.scoreId = '',
    this.movementKey = '',
    this.sectionVolume = 0.8,
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
        beatLength: json["beatLength"],
        autoContinue: json["autoContinue"],
        autoContinueMarker: json["autoContinueMarker"] == null
            ? null
            : Duration(
                milliseconds:
                    convertToDuration(json["autoContinueMarker"].toDouble())),
        userTempo: json["userTempo"],
        tempoMultiplier: json["tempoMultiplier"],
        sectionVolume: json["sectionVolume"]?.toDouble() ?? 0.8,
        layers:
            json["layers"] == null ? null : List<String>.from(json["layers"]),
      );

  @override
  Map<String, dynamic> toJson() => {
        "metronomeAvailable": metronomeAvailable,
        "name": name,
        "movementIndex": movementIndex,
        "_key": key,
        "tempoRangeFull": List<dynamic>.from(tempoRangeFull.map((x) => x)),
        "step": step,
        "defaultTempo": defaultTempo,
        "tempoRange": List<dynamic>.from(tempoRange.map((x) => x)),
        "fileList": List<dynamic>.from(fileList.map((x) => x)),
        "defaultSectionLength": defaultSectionLength,
        "sectionIndex": sectionIndex,
        "sectionImage": sectionImage == null
            ? null
            : SectionImage.fromJson(sectionImage!.toJson()),
        "beatsPerBar": beatsPerBar,
        "beatLength": beatLength,
        "autoContinue": autoContinue,
        "autoContinueMarker": autoContinueMarker,
        "userTempo": userTempo,
        "tempoMultiplier": tempoMultiplier,
        "sectionVolume": sectionVolume,
        "layers": layers,
      };
}
