import 'package:gphil/models/movement.dart';

class InitScore {
  String pathName;
  List<String>? audioFormat;
  String slug;
  String? fullScoreUrl;
  String? pianoScoreUrl;
  dynamic layers;
  List<InitMovement> movements;
  String? priceId;
  String? key;
  dynamic about;
  DateTime updatedAt;
  String rev;
  String? instrument;
  int? price;
  dynamic tips;
  String? title;
  String id;
  bool? ready;
  String shortTitle;
  String composer;

  InitScore({
    required this.pathName,
    this.audioFormat,
    required this.slug,
    this.fullScoreUrl,
    this.pianoScoreUrl,
    this.layers,
    required this.movements,
    this.priceId,
    this.key,
    this.about,
    required this.updatedAt,
    required this.rev,
    this.instrument,
    this.price,
    this.tips,
    this.title,
    required this.id,
    this.ready,
    required this.shortTitle,
    required this.composer,
  });

  factory InitScore.fromJson(Map<String, dynamic> json) => InitScore(
        pathName: json["pathName"],
        audioFormat: json["audio_format"] == null
            ? []
            : List<String>.from(json["audio_format"].map((x) => x)),
        slug: json["slug"],
        fullScoreUrl: json["full_score_url"] ?? '',
        pianoScoreUrl: json["piano_score_url"] ?? '',
        layers: json["layers"] ?? [],
        movements: List<InitMovement>.from(
            json["movements"].map((x) => InitMovement.fromJson(x))),
        priceId: json["price_id"] ?? '',
        key: json["key"] ?? '',
        about: json["about"] ?? '',
        updatedAt: DateTime.parse(json["_updatedAt"]),
        rev: json["_rev"],
        instrument: json["instrument"] ?? '',
        price: json["price"] ?? 0,
        tips: json["tips"] ?? [],
        title: json["title"] ?? '',
        id: json["_id"],
        ready: json["ready"] ?? false,
        shortTitle: json["shortTitle"],
        composer: json["composer"],
      );
}

class ScoreRef {
  String ref;
  ScoreRef({
    required this.ref,
  });

  factory ScoreRef.fromJson(Map<String, dynamic> json) => ScoreRef(
        ref: json["_ref"],
      );
}

class Score extends InitScore {
  List<Movement> setupMovements;

  Score({
    required super.movements,
    required super.updatedAt,
    required super.rev,
    required super.pathName,
    required super.slug,
    required super.id,
    required super.shortTitle,
    required super.composer,
    required this.setupMovements,
  });

  factory Score.fromJson(Map<String, dynamic> json) => Score(
        movements: List<InitMovement>.from(
            json["movements"].map((x) => InitMovement.fromJson(x))),
        updatedAt: DateTime.parse(json["_updatedAt"]),
        rev: json["_rev"],
        pathName: json["pathName"],
        slug: json["slug"],
        id: json["_id"],
        shortTitle: json["shortTitle"],
        composer: json["composer"],
        setupMovements: List<Movement>.from(
            json["setupMovements"].map((x) => Movement.fromJson(x))),
      );
}
