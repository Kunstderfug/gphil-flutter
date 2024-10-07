import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:gphil/models/layer_player.dart';

class AudioProvider extends ChangeNotifier {
  // AUDIO PLAYERS
  final player = SoLoud.instance;
  SoundHandle? activeHandle;
  final activeLayerHandles =
      <SoundHandle>[]; //when multiple layers are available for mixing
  SoundHandle? passiveHandle;
  final playerPool = <PlayerPool>[];
  bool jumped = false;
  Ticker ticker = Ticker((elapsed) {});
  double globalVolume = 1;
  double playerVolume = 1;
  List<double> layersVolumes = <double>[0, 0, 0, 0];
  final playerLayers = <OrchestraLayer>[
    OrchestraLayer.woodwinds,
    OrchestraLayer.brass,
    OrchestraLayer.percussion,
    OrchestraLayer.strings,
  ];
  final layerPlayerPool = <LayerPlayerPool>[];
  bool layersEnabled = false;
  bool _isPlaying = false;

  // Durations
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;
  // Stream<int> position = Stream<int>.value(0);
  // StreamSubscription? positionSub;

  // GETTERS
  Duration get currentPosition => _currentPosition;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;

  // SETTERS
  set duration(Duration value) {
    _duration = value;
    notifyListeners();
  }

  set currentPosition(Duration value) {
    _currentPosition = value;
    notifyListeners();
  }

  set isPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

  // METHODS
  void resetPlayers() {
    playerPool.clear();
    layerPlayerPool.clear();
    activeLayerHandles.clear();
    activeHandle = null;
    playerVolume = 1;
    layersVolumes = [0, 0, 0, 0];
    _isPlaying = false;
    notifyListeners();
  }
}
