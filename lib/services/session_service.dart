import 'dart:convert';
import 'dart:developer';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/layer_player.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/models/score.dart';
import 'package:gphil/models/score_user_prefs.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SessionType {
  practice,
  performance;

  String get displayName => name[0].toUpperCase() + name.substring(1);
}

class UserSession {
  final String name;
  final DateTime timestamp;
  final String scoreId;
  final SessionType type;
  final List<SectionPrefs> sectionPrefs;

  UserSession({
    required this.name,
    required this.timestamp,
    required this.scoreId,
    required this.type,
    required this.sectionPrefs,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'timestamp': timestamp.toIso8601String(),
        'scoreId': scoreId,
        'type': type.name,
        'sections': sectionPrefs.map((section) => section.toJson()).toList(),
      };

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
        name: json['name'],
        timestamp: DateTime.parse(json['timestamp']),
        scoreId: json['scoreId'],
        type: SessionType.values.firstWhere((t) => t.name == json['type'],
            orElse: () => SessionType.practice),
        sectionPrefs: (json['sections'] as List)
            .map((section) => SectionPrefs.fromJson(section))
            .toList(),
      );
}

class SessionService {
  final PersistentDataController pc = PersistentDataController();
  // final PlaylistProvider p;
  final ScoreProvider s;

  SessionService(this.s);

  Future<String> get _sessionDirectoryPath async => await pc.sessionDirectory();

  Future<File> _getSessionFile(String sessionName, SessionType type) async {
    final String path = await _sessionDirectoryPath;
    // Convert spaces to underscores and add session type
    final String fileName = '${type.name}_$sessionName.json';
    return File('$path/$fileName');
  }

  Future<void> saveSession(String name, String scoreId, SessionType type,
      List<Section> sections, PlaylistProvider p) async {
    final List<SectionPrefs> sectionPrefs = sections.map((section) {
      return SectionPrefs(
        sectionKey: section.key,
        defaultTempo: section.defaultTempo,
        userTempo: section.userTempo,
        userLayerTempo: section.userLayerTempo,
        autoContinue: section.autoContinue,
        sectionVolume: section.sectionVolume,
        muted: section.muted,
        looped: section.looped,
        layers:
            section.layers?.map((layer) => Layer(layerName: layer)).toList(),
      );
    }).toList();

    final UserSession session = UserSession(
      name: name,
      timestamp: DateTime.now(),
      scoreId: scoreId, // Added scoreId
      sectionPrefs: sectionPrefs,
      type: type,
    );
    final formattedDate =
        DateFormat('MMM d, y HH:mm').format(session.timestamp);

    //safe filename
    final String safeFileName =
        '${name}_$formattedDate'.replaceAll(RegExp(r'[/\\<>:"|?*\s]'), '_');
    final File sessionFile = await _getSessionFile(safeFileName, type);
    await sessionFile.writeAsString(json.encode(session.toJson()));
    p.sessionChanged = false;
    //saving session name to local storage
    final pref = await SharedPreferences.getInstance();
    await pref.setString('sessionName', safeFileName);
  }

  Future<void> deleteSession(String name, SessionType type) async {
    final File sessionFile = await _getSessionFile(name, type);
    if (await sessionFile.exists()) {
      await sessionFile.delete();
    }
  }

  Future<List<UserSession>> getSessions() async {
    final String path = await _sessionDirectoryPath;
    final Directory directory = Directory(path);

    if (!await directory.exists()) {
      return [];
    }

    final List<FileSystemEntity> files = await directory
        .list()
        .where((entity) => entity.path.endsWith('.json'))
        .toList();

    final List<UserSession> sessions = [];

    for (final file in files) {
      try {
        final String contents = await File(file.path).readAsString();
        final UserSession session = UserSession.fromJson(json.decode(contents));
        sessions.add(session);
      } catch (e) {
        log('Error reading session file: ${file.path}');
        log(e.toString());
      }
    }

    // Sort sessions by timestamp, most recent first
    sessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sessions;
  }

  Future<({String? scoreId, List<SectionPrefs>? prefs, String? error})>
      readSessionPrefs(String name, SessionType type) async {
    try {
      final File sessionFile = await _getSessionFile(name, type);
      log('Session file: ${sessionFile.path}');
      if (!await sessionFile.exists()) {
        return (
          scoreId: null,
          prefs: null,
          error: 'Session file not found: $name',
        );
      }

      final String contents = await sessionFile.readAsString();
      final Map<String, dynamic> jsonData = json.decode(contents);
      final UserSession session = UserSession.fromJson(jsonData);

      if (session.sectionPrefs.isEmpty) {
        return (
          scoreId: null,
          prefs: null,
          error: 'No section preferences found in session',
        );
      }

      // Validate each SectionPrefs object
      for (final pref in session.sectionPrefs) {
        if (pref.sectionKey.isEmpty || pref.defaultTempo <= 0) {
          return (
            scoreId: null,
            prefs: null,
            error: 'Invalid section preferences found',
          );
        }
      }

      return (
        scoreId: session.scoreId,
        prefs: session.sectionPrefs,
        error: null,
      );
    } catch (e) {
      log('Error reading session file: $name');
      log(e.toString());
      return (
        scoreId: null,
        prefs: null,
        error: 'Failed to read session: ${e.toString()}',
      );
    }
  }

  Future<({Score? score, List<Movement>? movements})> loadSession(
      String name, SessionType type) async {
    // 0. Get section preferences from saved session
    final result = await readSessionPrefs(name, type);

    if (result.prefs == null ||
        result.scoreId == null ||
        result.scoreId!.isEmpty) {
      log('Error loading session: ${result.error}');
      return (score: null, movements: null);
    }

    // 1. Get original score
    Score? originalScore = await s.getScore(result.scoreId!);
    if (originalScore == null) {
      log('Score not found: ${result.scoreId}');
      return (score: null, movements: null);
    }

    // 2. Create a set of section keys from preferences for quick lookup
    final Set<String> prefSectionKeys =
        result.prefs!.map((p) => p.sectionKey).toSet();

    // 3. Create maps for quick section lookup
    final Map<String, Section> allSections = {};
    for (final movement in originalScore.setupMovements) {
      for (final section in movement.setupSections) {
        allSections[section.key] = section;
      }
    }

    // 4. Create updated sections with preferences
    final Map<String, Section> updatedSections = {};
    for (final pref in result.prefs!) {
      final Section? originalSection = allSections[pref.sectionKey];
      if (originalSection != null) {
        updatedSections[pref.sectionKey] = Section.fromMap({
          ...originalSection.toMap(),
          'userTempo': pref.userTempo,
          'userLayerTempo': pref.userLayerTempo,
          'autoContinue': pref.autoContinue,
          'sectionVolume': pref.sectionVolume,
          'muted': pref.muted ?? false,
          'looped': pref.looped ?? false,
          'layers': pref.layers?.map((l) => l.layerName).toList(),
        });
      }
    }

    // 5. Filter and create updated movements that only contain sections from preferences
    final List<Movement> updatedMovements = originalScore.setupMovements
        .where((movement) => movement.setupSections
            .any((section) => prefSectionKeys.contains(section.key)))
        .map((movement) {
      final List<Section> filteredSections = movement.setupSections
          .where((section) => prefSectionKeys.contains(section.key))
          .map((section) => updatedSections[section.key] ?? section)
          .toList();

      return Movement(
        score: movement.score,
        index: movement.index,
        key: movement.key,
        title: movement.title,
        sections: movement.sections,
        renderTail: movement.renderTail,
        setupSections: filteredSections,
      );
    }).toList();

    // 6. Create new score with filtered and updated movements
    final updatedScore = Score(
      movements: originalScore.movements,
      updatedAt: originalScore.updatedAt,
      rev: originalScore.rev,
      pathName: originalScore.pathName,
      slug: originalScore.slug,
      id: originalScore.id,
      shortTitle: originalScore.shortTitle,
      composer: originalScore.composer,
      setupMovements: updatedMovements,
      fullScoreUrl: originalScore.fullScoreUrl,
      pianoScoreUrl: originalScore.pianoScoreUrl,
      audioFormat: originalScore.audioFormat,
      globalLayers: originalScore.globalLayers,
    );

    return (
      score: updatedScore,
      movements: updatedMovements,
    );
  }
}
