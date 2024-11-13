import 'dart:convert';
import 'package:gphil/models/layer_player.dart';

ScoreUserPrefs scoreUserPrefFromJson(String str) =>
    ScoreUserPrefs.fromJson(json.decode(str));

String scoreUserPrefToJson(ScoreUserPrefs data) => json.encode(data.toJson());

class ScoreUserPrefs {
  final String scoreId;
  final String rev;
  final List<SectionPrefs> sections;

  ScoreUserPrefs({
    required this.scoreId,
    required this.rev,
    required this.sections,
  });

  factory ScoreUserPrefs.fromJson(Map<String, dynamic> json) => ScoreUserPrefs(
        scoreId: json["scoreId"],
        rev: json["rev"],
        sections: List<SectionPrefs>.from(json["sections"]
            .map((sectionPref) => SectionPrefs.fromJson(sectionPref))),
      );

  Map<String, dynamic> toJson() => {
        "scoreId": scoreId,
        "rev": rev,
        "sections":
            List<dynamic>.from(sections.map((section) => section.toJson())),
      };
}

class SectionPrefs {
  final String sectionKey;
  final int defaultTempo;
  final int? userTempo;
  final int? userLayerTempo;
  final bool? autoContinue;
  final double? sectionVolume;
  final List<Layer>? layers;
  final bool? muted;
  final bool? looped;

  SectionPrefs(
      {required this.sectionKey,
      required this.defaultTempo,
      this.userTempo,
      this.userLayerTempo,
      this.autoContinue,
      this.sectionVolume = 1,
      this.layers,
      this.muted,
      this.looped});

  factory SectionPrefs.fromJson(Map<String, dynamic> json) => SectionPrefs(
        sectionKey: json["sectionKey"],
        defaultTempo: json["defaultTempo"],
        userTempo: json["userTempo"],
        userLayerTempo: json["userLayerTempo"],
        autoContinue: json["autoContinue"],
        sectionVolume: json["sectionVolume"] ?? 1,
        muted: json['muted'] ?? false,
        looped: json['looped'] ?? false,
        layers: List<Layer>.from(json['layers'] != null
            ? json["layers"]?.map((x) => Layer.fromJson(x))
            : []),
      );

  Map<String, dynamic> toJson() => {
        "sectionKey": sectionKey,
        "defaultTempo": defaultTempo,
        "userTempo": userTempo,
        "userLayerTempo": userLayerTempo,
        "autoContinue": autoContinue,
        "sectionVolume": sectionVolume,
        "muted": muted,
        "looped": looped,
        "layers": layers != null
            ? List<dynamic>.from(layers!.map((x) => x.toJson()))
            : null,
      };
}

class ClickData {
  final int time;
  final int beat;

  ClickData({
    required this.time,
    required this.beat,
  });

  factory ClickData.fromJson(Map<String, dynamic> json) => ClickData(
        time: json["time"],
        beat: json["beat"],
      );

  Map<String, dynamic> toJson() => {
        "time": time,
        "beat": beat,
      };
}
