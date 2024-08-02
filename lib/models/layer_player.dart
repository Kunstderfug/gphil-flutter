// import 'dart:developer';

import 'package:flutter_soloud/flutter_soloud.dart';

class AudioUrl {
  final int sectionIndex;
  final String sectionKey;
  final String url;

  AudioUrl(this.sectionIndex, this.sectionKey, this.url);
}

enum OrchestraLayer {
  flute,
  woodwinds,
  brass,
  percussion,
  strings,
}

class PlayerPool {
  final int sectionIndex;
  final String sectionKey;
  AudioSource audioSource;
  double? playerVolume;

  PlayerPool(
      {required this.sectionIndex,
      required this.sectionKey,
      required this.audioSource,
      this.playerVolume = 1.0});
}

class MainPlayer {
  bool isActive;
  bool isMuted = false;
  double? playerVolume;
  AudioSource audioSource;
  SoundHandle? activeHandle;
  SoLoud player;
  MainPlayer({
    required this.audioSource,
    required this.player,
    this.activeHandle,
    this.isActive = true,
    this.playerVolume,
  });
}

class LayerPlayer extends PlayerPool {
  final String layer;
  bool isActive;
  bool isMuted = false;
  SoundHandle? activeHandle;
  SoLoud player;

  LayerPlayer({
    required super.sectionIndex,
    required super.sectionKey,
    required super.audioSource,
    super.playerVolume,
    required this.layer,
    this.activeHandle,
    this.isActive = true,
    required this.player,
  });

  void setPlayerVolume(double value) {
    playerVolume = value;
    if (activeHandle != null && playerVolume != null) {
      player.setVolume(activeHandle!, playerVolume!);
    }
  }

  void seek(SoundHandle handle, Duration position) {
    player.seek(handle, position);
  }
}

class Layer {
  final String layerName;
  double volume;

  Layer({required this.layerName, this.volume = 1.0});
  String get fullName {
    switch (layerName) {
      case 'f':
        return 'Flute';
      case 'w':
        return 'Woodwinds';
      case 'ob':
        return 'Oboes';
      case 'cl':
        return 'Clarinets';
      case 'bsn':
        return 'Bassoons';
      case 'b':
        return 'Brass';
      case 'hn':
        return 'Horns';
      case 'p':
        return 'Percussion';
      case 's':
        return 'Strings';
      case 'db':
        return 'DBasses';
      case 'd':
        return 'Drums';
      case 'lg':
        return 'Guitar';
      case 'bg':
        return 'Bass guitar';
    }
    return 'Unnamed Layer';
  }

  void setVolume(double value) {
    volume = value;
    // log('global volume: $volume, layer: $layerName');
  }

  factory Layer.fromJson(Map<String, dynamic> json) {
    return Layer(
      layerName: json['layerName'],
      volume: json['volume'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'layerName': layerName, 'volume': volume};
  }
}

class LayerChannel {
  final String name;
  final LayerPlayer? player;
  LayerChannel({required this.name, required this.player});
}

class SectionLayer {
  final String layer;
  final String audioUrl;

  SectionLayer({required this.layer, required this.audioUrl});
}

class LayerPlayerPool {
  final int sectionIndex;
  final String sectionKey;
  int tempo;
  final List<SectionLayer> layers;
  MainPlayer mainPlayer;
  List<LayerPlayer> players;
  LayerPlayerPool(
      {required this.sectionIndex,
      required this.sectionKey,
      required this.tempo,
      required this.layers,
      required this.mainPlayer,
      required this.players});

  List<SoundHandle> get activeLayerHandles => players
      .where((p) => p.activeHandle != null)
      .map((p) => p.activeHandle!)
      .toList();

  List<LayerChannel> get layerChannels {
    List<LayerChannel> channels = [];
    for (LayerPlayer player in orderedPlayers) {
      channels.add(
        LayerChannel(
          name: player.layer,
          player: player,
          // channelVolume: player.playerVolume ?? 0.0,
        ),
      );
    }
    return channels;
  }

  List<LayerPlayer> get activeChannels =>
      players.where((p) => p.isActive).toList();

  List<LayerPlayer> get orderedPlayers {
    List<LayerPlayer> orderedPlayers = [];
    int index = 0;
    for (SectionLayer layer in layers) {
      final currentPlayer = players.firstWhere((p) => p.layer == layer.layer);
      orderedPlayers.insert(index, currentPlayer);
      index++;
    }
    return orderedPlayers;
  }

  //seek
  void seek(Duration position) {
    for (LayerPlayer player in players) {
      if (player.activeHandle != null) {
        player.seek(player.activeHandle!, position);
      }
    }
  }

//set individual channel volume
  void setChannelActive(String layer, bool active) {
    for (LayerPlayer player in players) {
      if (player.layer == layer) {
        player.isActive = active;
      }
    }
  }

  void setChannelSoloOrMuted(String layer, bool value) {
    for (LayerPlayer player in players) {
      if (player.layer == layer) {
        player.playerVolume = value ? 1.0 : 0.0;
        player.isActive = value ? true : false;
        player.isMuted = value ? false : true;
      }
    }
  }

  void setSoloOrMutedReset() {
    for (LayerPlayer player in players) {
      player.playerVolume = 1.0;
      player.isActive = true;
      player.isMuted = false;
    }
  }
}

class GlobalLayerPlayerPool {
  List<Layer> globalLayers;
  final globalPools = <LayerPlayerPool>[];

  GlobalLayerPlayerPool({required this.globalLayers});

  void setGlobalLayers(List<Layer> layers) {
    globalLayers = layers;
  }

  void setGlobalLayerVolume(double volume, String layer) {
    for (Layer l in globalLayers) {
      if (l.layerName == layer) {
        l.setVolume(volume);
      }
    }
  }

  void setIndividualLayerVolume(
      LayerPlayerPool pool, String layer, double volume) {
    for (LayerPlayer player in pool.players) {
      if (player.layer == layer) {
        player.setPlayerVolume(volume);
      }
    }
  }

  void resetPools() {
    globalPools.clear();
  }

  void resetLayers() {
    globalLayers.clear();
  }

  void resetAll() {
    resetPools();
    resetLayers();
  }
}
