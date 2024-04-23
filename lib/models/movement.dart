import 'package:gphil/models/score.dart';
import 'package:gphil/models/section.dart';

class InitMovement {
  ScoreRef score;
  int index;
  String key;
  String title;
  List<InitSection> sections;

  InitMovement({
    required this.score,
    required this.index,
    required this.key,
    required this.title,
    required this.sections,
  });

  factory InitMovement.fromJson(Map<String, dynamic> json) => InitMovement(
        score: ScoreRef?.fromJson(json["score"]),
        index: json["index"],
        key: json["_key"],
        title: json["title"],
        sections: List<InitSection>.from(
            json["sections"].map((x) => InitSection.fromJson(x))),
      );
}

class Movement extends InitMovement {
  List<Section> setupSections;

  Movement({
    required super.score,
    required super.index,
    required super.key,
    required super.title,
    required super.sections,
    required this.setupSections,
  });

  factory Movement.fromJson(Map<String, dynamic> json) => Movement(
        score: ScoreRef?.fromJson(json["score"]),
        index: json["index"],
        key: json["_key"],
        title: json["title"],
        sections: List<InitSection>.from(
            json["sections"].map((x) => InitSection.fromJson(x))),
        setupSections: List<Section>.from(
            json["setupSections"].map((x) => Section.fromJson(x))),
      );
}
