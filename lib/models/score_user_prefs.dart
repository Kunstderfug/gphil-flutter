// To parse this JSON data, do
//
//     final scoreUserPref = scoreUserPrefFromJson(jsonString);

import 'dart:convert';

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
        sections: List<SectionPrefs>.from(
            json["sections"].map((x) => SectionPrefs.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "scoreId": scoreId,
        "rev": rev,
        "sections": List<dynamic>.from(sections.map((x) => x.toJson())),
      };
}

class SectionPrefs {
  final String sectionKey;
  final int defaultTempo;
  final int? userTempo;
  final bool? autoContinue;
  final double? sectionVolume;

  SectionPrefs({
    required this.sectionKey,
    required this.defaultTempo,
    this.userTempo,
    this.autoContinue,
    this.sectionVolume = 0.75,
  });

  factory SectionPrefs.fromJson(Map<String, dynamic> json) => SectionPrefs(
        sectionKey: json["sectionKey"],
        defaultTempo: json["defaultTempo"],
        userTempo: json["userTempo"],
        autoContinue: json["autoContinue"],
        sectionVolume: json["sectionVolume"] ?? 0.75,
      );

  Map<String, dynamic> toJson() => {
        "sectionKey": sectionKey,
        "defaultTempo": defaultTempo,
        "userTempo": userTempo,
        "autoContinue": autoContinue,
        "sectionVolume": sectionVolume,
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
