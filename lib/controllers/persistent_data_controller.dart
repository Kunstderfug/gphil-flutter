import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:gphil/models/library.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/models/score.dart';
import 'package:gphil/models/score_user_prefs.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/services/sanity_service.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersistentDataController with ChangeNotifier {
  final imageFormat = 'png';
  AppState? appState;
  String _message = "";
  String _error = "";
  final s = ScoreProvider();

  String get message => _message;
  String get error => _error;

  set message(String value) {
    _message = value;
    notifyListeners();
  }

  set error(String value) {
    _error = value;
    notifyListeners();
  }

  void reset() {
    _message = "";
    _error = "";
    notifyListeners();
  }

  Future<bool> isOnline() async {
    final result = await InternetConnection().hasInternetAccess;
    log('isOnline: $result');
    return result;
  }

  Future<String> get _directoryPath async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> get _gphilRootDirectory async {
    final path = await _directoryPath;
    //check if the section path exists
    Directory directory = Directory('$path/gphil');
    if (await directory.exists()) {
      return directory.path;
    }
    directory = await Directory('$path/gphil').create(recursive: true);

    return directory.path;
  }

//DATA PATHS

  Future<String> sessionDirectory() async {
    final String rootPath = await _gphilRootDirectory;
    Directory directory = Directory('$rootPath/user_sessions');
    if (!await directory.exists()) {
      directory = await directory.create(recursive: true);
    }
    return directory.path;
  }

  Future<String> scoreDirectory(String scoreId) async {
    final String path = await _gphilRootDirectory;
    Directory directory = Directory('$path/$scoreId');
    if (await directory.exists()) {
      return directory.path;
    }
    directory = await Directory('$path/$scoreId').create(recursive: true);

    return directory.path;
  }

  Future<String> audioDirectory(String scoreId) async {
    final String directory = await scoreDirectory(scoreId);

    Directory audioDirectory = Directory('$directory/audio');
    if (await audioDirectory.exists()) {
      return audioDirectory.path;
    }
    audioDirectory =
        await Directory('$directory/audio').create(recursive: true);
    return audioDirectory.path;
  }

  //get sections directory
  Future<String> sectionsDirectory(String scoreId) async {
    final String path = await scoreDirectory(scoreId);
    Directory directory = Directory('$path/sections');
    if (await directory.exists()) {
      return directory.path;
    }
    directory = await Directory('$path/sections').create(recursive: true);
    return directory.path;
  }

  //get clicks directory
  Future<String> clicksDirectory(String scoreId) async {
    final String path = await scoreDirectory(scoreId);
    Directory directory = Directory('$path/clicks');
    if (await directory.exists()) {
      return directory.path;
    }
    directory = await Directory('$path/clicks').create(recursive: true);
    return directory.path;
  }

  //get images directory
  Future<String> imagesDirectory(String scoreId) async {
    final String path = await scoreDirectory(scoreId);
    Directory directory = Directory('$path/images');
    if (await directory.exists()) {
      return directory.path;
    }
    directory = await Directory('$path/images').create(recursive: true);
    return directory.path;
  }

  Future<File> jsonSectionFile(String scoreId, String sectionKey) async {
    final path = await sectionsDirectory(scoreId);
    return File('$path/$sectionKey.json');
  }

  Future<File> jsonClickFile(String scoreId, String sectionKey) async {
    final String path = await clicksDirectory(scoreId);
    return File('$path/${sectionKey}_click.json');
  }

  Future<File> imageFile(String scoreId, String imageId) async {
    final path = await imagesDirectory(scoreId);
    return File('$path/$imageId');
  }

  Future<File> audioFile(
      String scoreId, String audioFileName, String audioFormat) async {
    final path = await audioDirectory(scoreId);
    return File('$path/$audioFileName.$audioFormat');
  }

//READ & WRITE DATA
  Future<Map<String, dynamic>?> readSectionJsonFile(
      String scoreId, String sectionKey) async {
    String fileContent;

    File file = await jsonSectionFile(scoreId, sectionKey);

    if (await file.exists()) {
      try {
        fileContent = await file.readAsString();
        return json.decode(fileContent);
      } catch (e) {
        log(e.toString());
      }
    }
    return null;
  }

  Future<SectionPrefs> writeSectionJsonFile(
      String scoreId, String sectionKey, SectionPrefs data) async {
    File sectionFile = await jsonSectionFile(scoreId, sectionKey);
    if (await sectionFile.exists() &&
        json.encode(data) == await sectionFile.readAsString()) {
      return data;
    } else {
      await sectionFile.writeAsString(json.encode(data), flush: true);
      log('wrote $sectionFile, autoContinue: ${await sectionFile.readAsString()}');
    }
    return data;
  }

  Future<SectionPrefs> updateSectionPrefs(
      String scoreId, String sectionKey, SectionPrefs data) {
    log('updating $sectionKey');
    return writeSectionJsonFile(scoreId, sectionKey, data);
  }

  Future<List<ClickData>> writeClickJsonFile(
      String scoreId, String sectionKey, List<ClickData> data) async {
    File file = await jsonClickFile(scoreId, sectionKey);
    if (await file.exists() && json.encode(data) == await file.readAsString()) {
      return data;
    }
    await file.writeAsString(json.encode(data));
    return data;
  }

  Future<List<ClickData>> readClickJsonFile(
      String scoreId, String sectionKey, String clickUrl) async {
    String fileContent;
    File file = await jsonClickFile(scoreId, sectionKey);
    if (await file.exists()) {
      try {
        fileContent = await file.readAsString();
        final jsonContent = (json.decode(fileContent) as List)
            .map((e) => ClickData.fromJson(e))
            .toList();
        if (jsonContent[0].time != 0) {
          jsonContent.insert(0, ClickData(time: 0, beat: 0));
        }
        return jsonContent;
      } catch (e) {
        log(e.toString());
      }
    } else {
      Response response = await Client().get(
        Uri.parse(clickUrl),
      );

      if (response.statusCode == 200) {
        List<ClickData> clickData = (json.decode(response.body) as List)
            .map((e) => ClickData.fromJson(e))
            .toList();
        await writeClickJsonFile(scoreId, sectionKey, clickData);
        return clickData;
      }
    }
    return [];
  }

  Future<File?> readImageFile(String scoreId, String imageRef) async {
    String imageUrl = SanityService().getImageUrl(imageRef);
    final String imageRefString = imageUrl.split('/').last.split('?').first;
    File file = await imageFile(scoreId, imageRefString);

    if (!await file.exists()) {
      Response response = await Client().get(
        Uri.parse(imageUrl),
      );

      Uint8List byteList = response.bodyBytes;
      await writeImageFile(byteList, file);
    }

    return file;
  }

  Future<void> writeImageFile(Uint8List byteList, File file) async {
    await file.writeAsBytes(byteList, flush: true);
  }

  Future<void> deleteImage(String scoreId, String imageRef) async {
    File file = await imageFile(scoreId, imageRef);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<bool> writeAudioFile(
      String scoreId, String audioFileName, Uint8List byteList) async {
    final String path = await audioDirectory(scoreId);
    final File file = File('$path/$audioFileName');
    await file.writeAsBytes(byteList, flush: true);
    return true;
  }

  Future<({Uint8List bytes, String path})> readAudioFile(
      String scoreId, String audioFileName, String audioUrl) async {
    Uint8List byteList = Uint8List(0);
    final String path = await audioDirectory(scoreId);
    final String fullPath = '$path/$audioFileName';
    final File file = File(fullPath);

    // reset();
    if (await file.exists() && await file.length() > 0) {
      message = "Loading $audioFileName";
      byteList = await file.readAsBytes();
      return (bytes: byteList, path: fullPath);
    } else {
      try {
        message = "Downloading $audioFileName";
        Response response = await Client().get(
          Uri.parse(audioUrl),
        );
        if (response.statusCode == 200) {
          byteList = response.bodyBytes;
          message = "";
          await writeAudioFile(scoreId, audioFileName, byteList);
          return (bytes: byteList, path: fullPath);
        } else {
          error = 'Failed to download audio file';
          throw Exception('Failed to download audio file');
        }
      } catch (e) {
        error = e.toString();
        log(e.toString());
      } finally {
        // message = "";
      }

      return (bytes: byteList, path: fullPath);
    }
  }

  //save score data
  Future<void> writeScoreData(String scoreId, InitScore data) async {
    if (!kIsWeb) {
      final String path = await _gphilRootDirectory;
      final File scoreFile = File('$path/score_$scoreId.json');

      log('writeScoreData ${data.id}');
      await scoreFile.writeAsString(json.encode(data));
    }
  }

  //read score data
  Future<InitScore?> readScoreData(String scoreId) async {
    InitScore? scoreJson;
    if (!kIsWeb) {
      final String rootPath = await _gphilRootDirectory;
      final File localScoreJson = File('$rootPath/score_$scoreId.json');

      if (await localScoreJson.exists()) {
        final Map<String, dynamic> scoreData = await Isolate.run(
            () async => await json.decode(await localScoreJson.readAsString()));
        scoreJson = await Isolate.run(() => InitScore.fromJson(scoreData));
      } else {
        log('downloading score data');
        scoreJson = await SanityService().fetchScore(scoreId);
        if (scoreJson != null) {
          await writeScoreData(scoreId, scoreJson);
        }
      }
    } else {
      scoreJson = await getWebScoreData(scoreId);
    }
    return scoreJson;
  }

  List<Section> getSectionsToUpdate(Score score) {
    final sectionsToUpdate = <Section>[];
    for (final Movement movement in score.setupMovements) {
      for (final Section section in movement.setupSections) {
        if (section.updateRequired != null) sectionsToUpdate.add(section);
      }
    }
    return sectionsToUpdate;
  }

  Future<List<String>> getAudioFilesToUpdate(List<Section> sections) async {
    final audioFilesToUpdate = <String>[];
    for (final section in sections) {
      final audioFileNames =
          section.fileList.map((e) => getAudioFileNAme(e)).toList();
      audioFilesToUpdate.addAll(audioFileNames);
    }
    return audioFilesToUpdate;
  }

  //update score
  Future<InitScore?> updateScore(String scoreId, String scoreRev) async {
    final tasks = <Future>[];

    try {
      message = "Updating score...";
      await deleteScore(scoreId);
      InitScore? scoreJson = await readScoreData(scoreId);

      //get images and sections data
      if (scoreJson != null) {
        Future<void> getImageFile(String scoreId, String imageRef) async {
          await readImageFile(scoreId, imageRef);
        }

        final Score score = await setupScore(scoreJson);
        final sections = getSectionsToUpdate(score);

        for (final section in sections) {
          await deleteAudio(scoreId, section.name);
          if (section.sectionImage != null) {
            String imageRef = section.sectionImage!.asset.ref;
            tasks.add(getImageFile(scoreId, imageRef));
          }
        }

        await Future.wait(tasks);
      }
      await writeScoreRevision(scoreId, scoreRev);
      return scoreJson;
    } catch (e) {
      error = e.toString();
      log(e.toString());
      return null;
    } finally {
      message = "";
      // error = "";
    }
  }

//WEB DATA
  // Method to retrieve score data from SharedPreferences
  Future<InitScore?> getWebScoreData(String scoreId) async {
    final prefs = await SharedPreferences.getInstance();
    final String scoreKey = 'score_$scoreId';
    final String? scoreDataString = prefs.getString(scoreKey);
    if (scoreDataString != null && scoreDataString.isNotEmpty) {
      log('getWebScoreData: ${scoreDataString.substring(0, 100)}');
      final Map<String, dynamic> scoreData = jsonDecode(scoreDataString);
      return InitScore.fromJson(scoreData);
    } else {
      log('getWebScoreData: fetching from web');
      final InitScore? score = await SanityService().fetchScore(scoreId);
      if (score != null) {
        log('getWebScoreData: saving to web, $score');
        await saveWebScoreData(score);
        return score;
      }
    }
    return null;
  }

  // Method to save score data to SharedPreferences
  Future<void> saveWebScoreData(InitScore score) async {
    final prefs = await SharedPreferences.getInstance();
    final String scoreKey = 'score_${score.id}';

    final Map<String, dynamic> scoreData = score.toJson();

    await prefs.setString(scoreKey, jsonEncode(scoreData));
    log('Saved score data for: ${score.shortTitle}');
  }

//write json file in the root folder if all scores are up to date
  Future<void> writeLibraryStatus() async {
    final String path = await _gphilRootDirectory;
    final File statusFile = File('$path/library_status.json');
    await statusFile.writeAsString(json.encode({
      'last_updated': DateTime.now().millisecondsSinceEpoch,
      'isUptoDate': true
    }));
  }

//save all items in the score library
  Future<void> writeLibrary(List<InitScore> scores) async {
    for (InitScore score in scores) {
      final String path = await scoreDirectory(score.id);
      final File scoreFile = File('$path/score_${score.id}.json');
      await scoreFile.writeAsString(json.encode(score));
      await checkScoreRevision(score.id, score.rev);
    }
  }

  //get all items from local library
  Future<List<LibraryItem>> getLocalLibrary() async {
    final List<LibraryItem> library = [];
    final String path = await _gphilRootDirectory;
    final Directory directory = Directory(path);
    if (await directory.exists()) {
      final List<FileSystemEntity> files = directory.listSync();
      for (FileSystemEntity file in files) {
        if (file.path.endsWith('.json')) {
          final Map<String, dynamic> scoreData =
              await json.decode(await File(file.path).readAsString());
          library.add(LibraryItem.fromJson(scoreData));
          log('added local score to the library: ${scoreData['id']}');
        }
      }
    }
    return library;
  }

//wrire score revision
  Future<String> writeScoreRevision(String scoreId, String scoreRev) async {
    final String path = await scoreDirectory(scoreId);
    final File scoreFile = File('$path/score_rev.json');
    if (await scoreFile.exists()) {
      final Map<String, dynamic> scoreJson =
          json.decode(await scoreFile.readAsString());
      scoreJson['rev'] = scoreRev;
      await scoreFile.writeAsString(json.encode(scoreJson));
    } else {
      await scoreFile.writeAsString(json.encode({'rev': scoreRev}));
    }
    return scoreRev;
  }

  //check for score revision
  Future<bool> checkScoreRevision(String scoreId, String scoreRev) async {
    final String path = await scoreDirectory(scoreId);
    final File scoreRevFile = File('$path/score_rev.json');
    if (await scoreRevFile.exists()) {
      final Map<String, dynamic> scoreJson =
          json.decode(await scoreRevFile.readAsString());
      log('score rev:  + ${scoreJson['rev']}');
      return scoreJson['rev'] == scoreRev;
    } else {
      writeScoreRevision(scoreId, scoreRev);
      return true;
    }
  }

  Future<void> deleteScore(String scoreId) async {
    // final String directory = await getScoreDirectory(scoreId);
    // final String sectionPath = await getSectionsDirectory(scoreId);
    final String imagePath = await imagesDirectory(scoreId);
    final String clickPath = await clicksDirectory(scoreId);
    // final String audioPath = await getAudioDirectory(scoreId);
    final String path = await _gphilRootDirectory;
    final scoreFile = File('$path/score_$scoreId.json');
    if (await scoreFile.exists()) {
      scoreFile.deleteSync();
    }

    // Directory(sectionPath).deleteSync(recursive: true);
    Directory(imagePath).deleteSync(recursive: true);
    Directory(clickPath).deleteSync(recursive: true);
  }

  Future<void> deleteAudio(String scoreId, String sectionName) async {
    final String path = await audioDirectory(scoreId);
    Directory directory = Directory(path);
    List<FileSystemEntity> entities = await directory.list().toList();

    try {
      // Filter and print matching files
      for (final entity in entities) {
        if (entity is File) {
          if (entity.path.contains(sectionName)) {
            log('Matching file: $sectionName');
            final File file = File(entity.path);
            if (await file.exists()) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      log('Error reading directory: $e');
    }
  }
}

String getAudioFileNAme(String audioUrl) {
  return audioUrl.split('/').last;
}
