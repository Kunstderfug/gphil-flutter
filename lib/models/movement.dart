import 'package:gphil/models/score.dart';
import 'package:gphil/models/section.dart';

class Movement {
  ScoreRef score;
  int index;
  String key;
  String title;
  List<Section> sections;

  Movement({
    required this.score,
    required this.index,
    required this.key,
    required this.title,
    required this.sections,
  });

  factory Movement.fromJson(Map<String, dynamic> json) => Movement(
        score: ScoreRef?.fromJson(json["score"]),
        index: json["index"],
        key: json["_key"],
        title: json["title"],
        sections: List<Section>.from(
            json["sections"].map((x) => Section.fromJson(x))),
      );
}

class SetupMovement extends Movement {
  List<SetupSection> setupSections;

  SetupMovement({
    required super.score,
    required super.index,
    required super.key,
    required super.title,
    required super.sections,
    required this.setupSections,
  });

  factory SetupMovement.fromJson(Map<String, dynamic> json) => SetupMovement(
        score: ScoreRef?.fromJson(json["score"]),
        index: json["index"],
        key: json["_key"],
        title: json["title"],
        sections: List<Section>.from(
            json["sections"].map((x) => Section.fromJson(x))),
        setupSections: List<SetupSection>.from(
            json["setupSections"].map((x) => SetupSection.fromJson(x))),
      );
}
