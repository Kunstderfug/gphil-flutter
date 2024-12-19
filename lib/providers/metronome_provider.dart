import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gphil/models/playlist_classes.dart';
import 'package:gphil/models/score_user_prefs.dart';

class MetronomeProvider extends ChangeNotifier {
  //PROVIDERS
  final List<SectionClickData> playlistClickData = [];
  ClickData currentBeat = ClickData(time: 0, beat: 0);
  int currentBeatIndex = 0;
  int beatLength = 0;
  final List<PlaylistDuration> currentPlaylistDurations = [];
  bool isLeft = true;
  bool isStarted = false;
  Timer? metronomeTimer;
}
