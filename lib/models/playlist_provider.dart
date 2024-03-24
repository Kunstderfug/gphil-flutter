import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'song.dart';

class PlaylistProvider extends ChangeNotifier {
  final List<String> urls = [
    "https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/INTRO_1/GERSHWIN_BLUE_RHAPSODY_1_INTRO_1_65.mp3",
    "https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/INTRO_2/GERSHWIN_BLUE_RHAPSODY_1_INTRO_2_90.mp3",
    "https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/INTRO_3/GERSHWIN_BLUE_RHAPSODY_1_INTRO_3_100.mp3",
    "https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/EP_1/GERSHWIN_BLUE_RHAPSODY_1_EP_1_100.mp3",
    "https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/EP_2/GERSHWIN_BLUE_RHAPSODY_1_EP_2_100.mp3",
    "https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/EP_3/GERSHWIN_BLUE_RHAPSODY_1_EP_3_156.mp3",
    "https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/EP_4/GERSHWIN_BLUE_RHAPSODY_1_EP_4_160.mp3"
  ];

  final List<Song> _playlist = [
    Song(
      songName: 'Intro_1',
      artistName: 'Rhapsody In Blue',
      albumArtImagePath: 'assets/images/1_test.png',
      audioPath:
          'https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/INTRO_1/GERSHWIN_BLUE_RHAPSODY_1_INTRO_1_65.mp3',
    ),
    Song(
      songName: 'Intro_2',
      artistName: 'Rhapsody In Blue',
      albumArtImagePath: 'assets/images/1_test.png',
      audioPath:
          'https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/INTRO_2/GERSHWIN_BLUE_RHAPSODY_1_INTRO_2_90.mp3',
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
          'https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/EP_3/GERSHWIN_BLUE_RHAPSODY_1_EP_3_156.mp3',
    ),
    Song(
      songName: 'EP_4',
      artistName: 'Rhapsody In Blue',
      albumArtImagePath: 'assets/images/1_test.png',
      audioPath:
          'https://gprktgiajxiwjzjsqdly.supabase.co/storage/v1/object/public/gershwin-blue/1/EP_4/GERSHWIN_BLUE_RHAPSODY_1_EP_4_160.mp3',
    ),
  ];

  int? _currentSongIndex = 0;
// init not playing
  bool _isPlaying = false;

  // AUDIO PLAYER
  final AudioPlayer _audioPlayer = AudioPlayer();

// Durations
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

//GETTERS
  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isPlaying => _isPlaying;

// SETTERS
  set totalDuration(Duration value) {
    _totalDuration = value;
    notifyListeners();
  }

  set currentPosition(Duration value) {
    _currentPosition = value;
    notifyListeners();
  }

  set currentSongIndex(int? index) {
    _currentSongIndex = index;
    _audioPlayer.setSourceUrl(playlist[_currentSongIndex!].audioPath);
    notifyListeners();
  }

  set isPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

// constructor
  PlaylistProvider() {
    listenToChanges();
  }

// play a song
  void playSong() async {
    final String path = playlist[_currentSongIndex!].audioPath;
    if (!_isPlaying) {
      log('playing: $path');
      await _audioPlayer.resume();
      isPlaying = true;
    } else {
      await _audioPlayer.stop();
      isPlaying = false;
      await _audioPlayer.resume();
      isPlaying = true;
    }
    notifyListeners();
  }

// pause a song
  void pauseSong() async {
    log('pausing');
    await _audioPlayer.pause();
    isPlaying = false;
    notifyListeners();
  }

// resume playing
  void resumeSong() async {
    log('resuming');
    if (_currentPosition.inSeconds > 0) {
      await _audioPlayer.resume();
      isPlaying = true;
      notifyListeners();
      return;
    } else {
      playSong();
    }
  }

// pause or resume
  void pauseOrResume() {
    if (_isPlaying) {
      pauseSong();
    } else {
      resumeSong();
    }
  }

// seek
  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

//play next song
  void playPreviousSong() {
    if (_currentPosition.inSeconds > 3) {
      seek(Duration.zero);
      return;
    } else if (_currentSongIndex != null) {
      currentSongIndex = (_currentSongIndex! - 1) % playlist.length;
      playSong();
    } else {
      currentSongIndex = playlist.length - 1;
    }
  }

// play previous song
  void playNextSong() {
    if (_currentSongIndex != null) {
      currentSongIndex = (_currentSongIndex! + 1) % playlist.length;
      playSong();
    } else {
      currentSongIndex = 0;
    }
  }

//listen to duration
  void listenToChanges() {
    // listen for total duration
    _audioPlayer.onDurationChanged.listen((duration) {
      totalDuration = duration;
      notifyListeners();
    });

    // listen to current position
    _audioPlayer.onPositionChanged.listen((position) {
      currentPosition = position;
      notifyListeners();
    });

    //listen to song is completed
    _audioPlayer.onPlayerComplete.listen((event) {
      currentPosition = Duration.zero;
      isPlaying = false;
      notifyListeners();
    });
  }

//dispose audio player
}
