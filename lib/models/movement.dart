import 'package:gphil/models/score.dart';
import 'package:gphil/models/section.dart';

class InitMovement {
  ScoreRef score;
  int index;
  String key;
  String title;
  List<InitSection> sections;
  int? renderTail; //in seconds

  InitMovement({
    required this.score,
    required this.index,
    required this.key,
    required this.title,
    required this.sections,
    this.renderTail,
  });

  factory InitMovement.fromJson(Map<String, dynamic> json) => InitMovement(
        score: ScoreRef?.fromJson(json["score"]),
        index: json["index"],
        key: json["_key"],
        title: json["title"],
        sections: List<InitSection>.from(
            json["sections"].map((x) => InitSection.fromJson(x))),
        renderTail: json["renderTail"],
      );

  Map<String, dynamic> toJson() => {
        "score": score.toJson(),
        "index": index,
        "_key": key,
        "title": title,
        "sections": List<dynamic>.from(sections.map((x) => x.toJson())),
        "renderTail": renderTail,
      };
}

class Movement extends InitMovement {
  List<Section> setupSections;

  Movement({
    super.renderTail,
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
        renderTail: json["renderTail"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "score": score.toJson(),
        "index": index,
        "_key": key,
        "title": title,
        "sections": List<dynamic>.from(sections.map((x) => x.toJson())),
        "setupSections":
            List<dynamic>.from(setupSections.map((x) => x.toJson())),
        "renderTail": renderTail,
      };
}
