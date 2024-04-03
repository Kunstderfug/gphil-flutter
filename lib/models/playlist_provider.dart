import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'song.dart';

class PlaylistProvider extends ChangeNotifier {
  final List<Song> songs = [
    Song(
      songName: 'Intro_1',
      artistName: 'Rhapsody In Blue',
      albumArtImagePath: 'assets/images/1_test.png',
      audioPath:
          'https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/INTRO_1/GERSHWIN_BLUE_RHAPSODY_1_INTRO_1_60.mp3',
      autoContinueAt: const Duration(milliseconds: 55406),
    ),
    Song(
      songName: 'Intro_2',
      artistName: 'Rhapsody In Blue',
      albumArtImagePath: 'assets/images/1_test.png',
      audioPath:
          'https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/INTRO_2/GERSHWIN_BLUE_RHAPSODY_1_INTRO_2_90.mp3',
      autoContinueAt: const Duration(milliseconds: 18887),
    ),
    Song(
      songName: 'Intro_3',
      artistName: 'Rhapsody In Blue',
      albumArtImagePath: 'assets/images/1_test.png',
      audioPath:
          'https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/INTRO_3/GERSHWIN_BLUE_RHAPSODY_1_INTRO_3_100.mp3',
    ),
    Song(
      songName: 'EP_1',
      artistName: 'Rhapsody In Blue',
      albumArtImagePath: 'assets/images/1_test.png',
      audioPath:
          'https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/EP_1/GERSHWIN_BLUE_RHAPSODY_1_EP_1_100.mp3',
    ),
    Song(
      songName: 'EP_2',
      artistName: 'Rhapsody In Blue',
      albumArtImagePath: 'assets/images/1_test.png',
      audioPath:
          'https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/EP_2/GERSHWIN_BLUE_RHAPSODY_1_EP_2_100.mp3',
    ),
    Song(
      songName: 'EP_3',
      artistName: 'Rhapsody In Blue',
      albumArtImagePath: 'assets/images/1_test.png',
      audioPath:
          'https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/EP_3/GERSHWIN_BLUE_RHAPSODY_1_EP_3_152.mp3',
      autoContinueAt: const Duration(milliseconds: 30298),
    ),
    Song(
      songName: 'EP_4',
      artistName: 'Rhapsody In Blue',
      albumArtImagePath: 'assets/images/1_test.png',
      audioPath:
          'https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/EP_4/GERSHWIN_BLUE_RHAPSODY_1_EP_4_160.mp3',
    ),
  ];

  List<Song> _playlist = [];
  int filesLoaded = 0;
  bool isLoading = false;

  int _currentSongIndex = 0;
  bool _isPlaying = false;
  bool _autoStart = false;
  late Duration _autoContinueAt;

  // AUDIO PLAYER
  // final AudioPlayer _audioPlayer = AudioPlayer();
  final List<MyAudioPlayer> _sessionPlayers = [];

// Durations
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

//GETTERS
  List<Song> get playlist => _playlist;
  int get currentSongIndex => _currentSongIndex;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isPlaying => _isPlaying;
  bool get autoStart => _autoStart;
  MyAudioPlayer get currentPlayer => _sessionPlayers[currentSongIndex];
  List<MyAudioPlayer> get sessionPlayers => _sessionPlayers;
  Duration get autoContinueAt => _autoContinueAt;
  bool get filesAreLoaded => filesLoaded == _sessionPlayers.length;

// SETTERS
  set totalDuration(Duration value) {
    _totalDuration = value;
    notifyListeners();
  }

  set currentPosition(Duration value) {
    _currentPosition = value;
    notifyListeners();
  }

  set currentSongIndex(int index) {
    log('setting new song index');
    // resetPlayer();
    if (!isPlaying) {
      currentPlayer.stop();
    }
    notifyListeners();
    _currentSongIndex = index;
    currentPosition = Duration.zero;
    currentPlayer = _sessionPlayers[_currentSongIndex];
    // totalDuration = currentPlayer.duration!;
    // notifyListeners();
  }

  set isPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

  set currentPlayer(MyAudioPlayer value) {
    _sessionPlayers[currentSongIndex] = value;
    notifyListeners();
  }

  set autoStart(bool value) {
    _autoStart = value;
    notifyListeners();
  }

  set autoContinueAt(Duration value) {
    _autoContinueAt = value;
    notifyListeners();
  }

  set playlist(List<Song> value) {
    _playlist = value;
    notifyListeners();
  }

// constructor
  PlaylistProvider() {
    initPlaylist();
    initSessionPlayers();
    listenToChanges();
  }

  void initPlaylist() {
    playlist = songs;
  }

  //create array of AudioPlayers for all songs in playlist
  void initSessionPlayers() async {
    isLoading = true;
    _sessionPlayers.clear();
    filesLoaded = 0;
    notifyListeners();
    for (Song song in playlist) {
      final MyAudioPlayer player = MyAudioPlayer();
      player.setSourceUrl(song.audioPath);
      await player.setDuration();
      _sessionPlayers.add(player);
      filesLoaded++;
      // log(filesLoaded.toString());
      notifyListeners();
    }

    isLoading = false;
    log(_sessionPlayers.toString());
    notifyListeners();
  }

// play a song
  void play() {
    bool jumped = false;
    totalDuration = currentPlayer.duration!;
    currentPlayer.resume();
    isPlaying = true;
    notifyListeners();

    void listenToChanges() {
      currentPlayer.onPositionChanged.listen((position) {
        currentPosition = position;
        if (playlist[_currentSongIndex].autoContinueAt != null) {
          if (position.inMilliseconds != 0 &&
              position.inMilliseconds >=
                  playlist[_currentSongIndex].autoContinueAt!.inMilliseconds &&
              !jumped) {
            playNextSong();
            jumped = true;
            return;
          }
        }
        notifyListeners();
      });
    }

    if (_sessionPlayers.indexOf(currentPlayer) == _currentSongIndex) {
      listenToChanges();
    }
  }

// pause a song
  void pause() {
    log('pausing');
    _sessionPlayers[currentSongIndex].pause();
    isPlaying = false;
    notifyListeners();
  }

// resume playing
  void resume() async {
    log('resuming');
    if (_currentPosition.inSeconds > 0) {
      await _sessionPlayers[currentSongIndex].resume();
      isPlaying = true;
      notifyListeners();
      return;
    } else {
      play();
    }
  }

// pause or resume
  void pauseOrResume() {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  void stop() {
    for (final player in _sessionPlayers) {
      player.stop();
    }
    isPlaying = false;
    notifyListeners();
  }

// seek
  void seek(Duration position) async {
    await currentPlayer.seek(position);
  }

//play next song
  void playPreviousSong() {
    currentSongIndex = (_currentSongIndex - 1) % playlist.length;
    play();
    listenToChanges();
  }

// play previous song
  void playNextSong() {
    if (currentSongIndex < playlist.length - 1) {
      currentSongIndex++;
      play();
      listenToChanges();
    }
  }

//listen to duration
  void listenToChanges() {
    //listen if the laast player fifnished playing
    if (_sessionPlayers.isNotEmpty) {
      _sessionPlayers.last.onPlayerComplete.listen((event) {
        resetPlayer();
        notifyListeners();
      });
    }
  }

  void resetPlayer() {
    // _sessionPlayers[currentSongIndex].stop();
    currentPosition = Duration.zero;
    isPlaying = false;
  }

//dispose audio player
}

class MyAudioPlayer extends AudioPlayer {
  late Duration? duration;

  Future<void> setDuration() async {
    duration = await super.getDuration();
  }

  MyAudioPlayer() {
    duration = null;
  }
}
