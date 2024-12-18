// To parse this JSON data, do
//
//     final library = libraryFromJson(jsonString);

import 'dart:convert';

import 'package:gphil/models/score.dart';

List<LibraryItem> libraryFromJson(List<dynamic> library) =>
    List<LibraryItem>.from(library.map((x) => LibraryItem.fromJson(x)));

String libraryToJson(List<LibraryItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LibraryItem {
  String pathName;
  String shortTitle;
  String slug;
  List<String>? layers;
  DateTime? updatedAt;
  String rev;
  Instrument? instrument;
  String? key;
  bool? private;
  bool? ready;
  int complete;
  String id;
  String composer;

  LibraryItem({
    required this.pathName,
    required this.shortTitle,
    required this.slug,
    this.layers,
    required this.updatedAt,
    required this.rev,
    this.instrument,
    this.key,
    this.private,
    this.ready,
    required this.complete,
    required this.id,
    required this.composer,
  });

  factory LibraryItem.fromJson(Map<String, dynamic> json) => LibraryItem(
        pathName: json["pathName"],
        shortTitle: json["shortTitle"],
        slug: json["slug"],
        layers: json["layers"] == null
            ? []
            : List<String>.from(json["layers"]!.map((x) => x)),
        updatedAt: DateTime.parse(json["_updatedAt"]),
        rev: json["_rev"],
        instrument: instrumentValues.map[json["instrument"]]!,
        key: json["key"],
        private: json["private"],
        ready: json["ready"],
        complete: json["complete"] ?? 0,
        id: json["_id"],
        composer: json["composer"],
      );

  factory LibraryItem.fromScore(Score score) {
    return LibraryItem(
      id: score.id,
      rev: score.rev,
      pathName: score.pathName,
      shortTitle: score.shortTitle,
      complete: score.completed ?? 0,
      instrument: instrumentFromString(score.instrument),
      ready: score.ready ?? false,
      slug: score.slug,
      updatedAt: score.updatedAt,
      composer: score.composer,
    );
  }

  Map<String, dynamic> toJson() => {
        "pathName": pathName,
        "shortTitle": shortTitle,
        "slug": slug,
        "layers":
            layers == null ? [] : List<dynamic>.from(layers!.map((x) => x)),
        "_updatedAt": updatedAt?.toIso8601String(),
        "_rev": rev,
        "instrument": instrumentValues.reverse[instrument],
        "key": key,
        "private": private,
        "ready": ready,
        "complete": complete,
        "_id": id,
        "composer": composer,
      };
}

enum Instrument {
  piano,
  violin,
  voice,
  cello,
  viola,
}

Instrument instrumentFromString(String? str) {
  if (str == null) return Instrument.piano; // default value
  return Instrument.values.firstWhere(
    (e) => e.name.toLowerCase() == str.toLowerCase(),
    orElse: () => Instrument.piano, // default value if not found
  );
}

final instrumentValues = EnumValues({
  "piano": Instrument.piano,
  "cello": Instrument.cello,
  "voice": Instrument.voice,
  "viola": Instrument.viola,
  "violin": Instrument.violin
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
