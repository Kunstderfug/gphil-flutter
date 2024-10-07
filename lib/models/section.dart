class InitSection {
  bool? metronomeAvailable;
  String name;
  bool? autoContinue;
  int movementIndex;
  String key;
  SectionImage? sectionImage;
  int? beatsPerBar;
  List<int> tempoRangeFull;
  List<int>? tempoRangeLayers;
  double? defaultSectionLength;
  int step;
  int? layerStep;
  int? beatLength;
  Duration? autoContinueMarker;
  int defaultTempo;
  int? userTempo;
  int? tempoMultiplier;
  List<String>? layers;
  bool? updateRequired;

  InitSection({
    this.metronomeAvailable,
    required this.name,
    this.autoContinue,
    required this.movementIndex,
    required this.key,
    this.sectionImage,
    this.beatsPerBar,
    required this.tempoRangeFull,
    this.tempoRangeLayers,
    this.defaultSectionLength,
    required this.step,
    this.layerStep,
    this.beatLength,
    this.autoContinueMarker,
    required this.defaultTempo,
    this.userTempo,
    this.tempoMultiplier,
    this.layers,
    this.updateRequired,
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
        tempoRangeLayers: json["tempoRangeLayers"] != null
            ? List<int>.from(json["tempoRangeLayers"].map((x) => x))
            : null,
        defaultSectionLength: json["defaultSectionLength"]?.toDouble(),
        step: json["step"],
        layerStep: json["layerStep"],
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
        updateRequired: json["updateRequired"],
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
        "tempoRangeLayers": tempoRangeLayers,
        "layerStep": layerStep,
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
        "updateRequired": updateRequired,
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
  int? userLayerTempo;
  bool muted;
  late bool looped;

  Section(
      {required super.name,
      required super.movementIndex,
      required super.key,
      required super.tempoRangeFull,
      required super.step,
      required super.defaultTempo,
      super.tempoRangeLayers,
      super.layerStep,
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
      super.updateRequired,
      required this.tempoRange,
      required this.fileList,
      required this.sectionIndex,
      this.userLayerTempo,
      this.clickDataUrl,
      this.scoreId = '',
      this.movementKey = '',
      this.sectionVolume = 0.8,
      this.muted = false,
      this.looped = false});

  factory Section.fromJson(Map<String, dynamic> json) => Section(
        metronomeAvailable: json["metronomeAvailable"],
        name: json["name"],
        movementIndex: json["movementIndex"],
        key: json["_key"],
        tempoRangeFull: List<int>.from(json["tempoRangeFull"].map((x) => x)),
        tempoRangeLayers: json["tempoRangeLayers"] != null
            ? List<int>.from(json["tempoRangeLayers"].map((x) => x))
            : null,
        layerStep: json["layerStep"],
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
        userLayerTempo: json["userLayerTempo"],
        tempoMultiplier: json["tempoMultiplier"],
        sectionVolume: json["sectionVolume"]?.toDouble() ?? 0.8,
        layers:
            json["layers"] == null ? null : List<String>.from(json["layers"]),
        muted: json['muted'] ?? false,
        updateRequired: json["updateRequired"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "metronomeAvailable": metronomeAvailable,
        "name": name,
        "movementIndex": movementIndex,
        "_key": key,
        "tempoRangeFull": List<dynamic>.from(tempoRangeFull.map((x) => x)),
        "tempoRangeLayers": tempoRangeLayers == null
            ? null
            : List<dynamic>.from(tempoRangeLayers!.map((x) => x)),
        "layerStep": layerStep,
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
        "userLayerTempo": userLayerTempo,
        "tempoMultiplier": tempoMultiplier,
        "sectionVolume": sectionVolume,
        "layers": layers,
        'muted': muted,
        "updateRequired": updateRequired,
      };
}

int convertToDuration(double duration) {
  return (duration * 1000).round();
}

double convertToDouble(int duration) {
  return duration / 1000;
}
