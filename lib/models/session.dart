import 'package:gphil/models/movement.dart';

class Session {
  final String composer;
  final String shortTitle;
  final String scoreId;
  List<Movement>? playlistMovements = [];

  Session({
    required this.composer,
    required this.shortTitle,
    required this.scoreId,
    this.playlistMovements,
  });
}
