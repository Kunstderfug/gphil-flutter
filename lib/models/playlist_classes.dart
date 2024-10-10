import 'dart:typed_data';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:gphil/models/layer_player.dart';
import 'package:gphil/models/score_user_prefs.dart';

class PlayerAudioSource {
  final AudioSource audioSource;
  final String sectionKey;

  PlayerAudioSource(
    this.audioSource,
    this.sectionKey,
  );
}

class WebAudioUrl {
  final String path;
  final String url;
  final int sectionIndex;
  final String sectionKey;
  final Uint8List bytes;

  WebAudioUrl(
      this.url, this.path, this.sectionIndex, this.sectionKey, this.bytes);
}

class SessionMovement {
  final String movementKey;
  final String scoreId;
  final String title;
  final int index;
  final int? renderTail;

  SessionMovement(
    this.movementKey,
    this.scoreId,
    this.title,
    this.index,
    this.renderTail,
  );
}

class SectionClickData {
  final String sectionKey;
  List<ClickData> clickData;

  SectionClickData(this.sectionKey, this.clickData);
}

class PlaylistDuration {
  final String sectionKey;
  List<int> beatLengths;

  PlaylistDuration({required this.sectionKey, required this.beatLengths});
}

final List<Layer> defaultMixer = [
  // Layer(layerName: 'f'),
  Layer(layerName: 'w'),
  Layer(layerName: 'b'),
  Layer(layerName: 'p'),
  Layer(layerName: 's'),
];
