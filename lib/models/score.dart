import 'package:gphil/models/movement.dart';

class Score {
  String pathName;
  List<String>? audioFormat;
  String slug;
  String? fullScoreUrl;
  String? pianoScoreUrl;
  dynamic layers;
  List<Movement> movements;
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

  Score({
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

  factory Score.fromJson(Map<String, dynamic> json) => Score(
        pathName: json["pathName"],
        audioFormat: json["audio_format"] == null
            ? []
            : List<String>.from(json["audio_format"].map((x) => x)),
        slug: json["slug"],
        fullScoreUrl: json["full_score_url"] ?? '',
        pianoScoreUrl: json["piano_score_url"] ?? '',
        layers: json["layers"] ?? [],
        movements: List<Movement>.from(
            json["movements"].map((x) => Movement.fromJson(x))),
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

class SetupScore extends Score {
  List<SetupMovement> setupMovements;

  SetupScore({
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

  factory SetupScore.fromJson(Map<String, dynamic> json) => SetupScore(
        movements: List<Movement>.from(
            json["movements"].map((x) => Movement.fromJson(x))),
        updatedAt: DateTime.parse(json["_updatedAt"]),
        rev: json["_rev"],
        pathName: json["pathName"],
        slug: json["slug"],
        id: json["_id"],
        shortTitle: json["shortTitle"],
        composer: json["composer"],
        setupMovements: List<SetupMovement>.from(
            json["setupMovements"].map((x) => SetupMovement.fromJson(x))),
      );
}
