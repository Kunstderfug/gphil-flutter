import 'package:flutter/foundation.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/services/app_state.dart';

class LoadingStateProvider extends ChangeNotifier {
  final PlaylistProvider playlistProvider;

  int _previousFilesDownloaded = 0;
  int _previousFilesLoaded = 0;
  String _previousMessage = '';
  String _previousError = '';
  bool _previousIsDownloading = false;
  bool _previousIsLoading = false;
  List<Section> _tempoIsNotInThoseSections = [];
  bool _isTempoInAllRanges = false;
  List<int> _tempoRangeLayers = [];

  LoadingStateProvider(this.playlistProvider) {
    playlistProvider.addListener(_handlePlaylistChanges);
  }

  // Getters for the values we want to track
  int get filesDownloaded => playlistProvider.filesDownloaded;
  int get filesLoaded => playlistProvider.filesLoaded;
  bool get isDownloading => playlistProvider.filesDownloading;
  String get message => playlistProvider.message;
  String get error => playlistProvider.error;
  List<String> get currentlyLoadedFiles =>
      playlistProvider.currentlyLoadedFiles;
  AppState? get appState => playlistProvider.appState;
  bool get isLoading => playlistProvider.isLoading;
  List<Section> get tempoIsNotInThoseSections =>
      playlistProvider.tempoIsNotInThoseSections;
  List<int> get tempoRangeLayers =>
      playlistProvider.currentSection?.tempoRangeLayers ?? [];
  bool get isTempoInAllRanges => playlistProvider.isTempoInAllRanges;

  void _handlePlaylistChanges() {
    // Only notify if relevant values have changed
    if (_hasLoadingStateChanged()) {
      // Update previous values
      _previousFilesDownloaded = filesDownloaded;
      _previousFilesLoaded = filesLoaded;
      _previousMessage = message;
      _previousError = error;
      _previousIsDownloading = isDownloading;
      _previousIsLoading = isLoading;
      _tempoIsNotInThoseSections = tempoIsNotInThoseSections;
      _isTempoInAllRanges = isTempoInAllRanges;
      _tempoRangeLayers = tempoRangeLayers;

      notifyListeners();
    }
  }

  bool _hasLoadingStateChanged() {
    return _previousFilesDownloaded != filesDownloaded ||
        _previousFilesLoaded != filesLoaded ||
        _previousMessage != message ||
        _previousError != error ||
        _previousIsLoading != isLoading ||
        _tempoIsNotInThoseSections != tempoIsNotInThoseSections ||
        _tempoRangeLayers != tempoRangeLayers ||
        _isTempoInAllRanges != isTempoInAllRanges ||
        _previousIsDownloading != isDownloading;
  }

  @override
  void dispose() {
    playlistProvider.removeListener(_handlePlaylistChanges);
    super.dispose();
  }
}
