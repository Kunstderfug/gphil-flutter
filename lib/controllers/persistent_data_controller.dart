import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:gphil/models/score.dart';
import 'package:gphil/models/score_user_prefs.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/services/sanity_service.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';

Future<bool> isOnline() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

class PersistentDataController {
  final imageFormat = 'png';

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

  Future<String> getScoreDirectory(String scoreId) async {
    final String path = await _gphilRootDirectory;
    Directory directory = Directory('$path/$scoreId');
    if (await directory.exists()) {
      return directory.path;
    }
    directory = await Directory('$path/$scoreId').create(recursive: true);

    return directory.path;
  }

  //AUDIO DATA PATH
  Future<String> getAudioDirectory(String scoreId) async {
    final String directory = await getScoreDirectory(scoreId);

    Directory audioDirectory = Directory('$directory/audio');
    if (await audioDirectory.exists()) {
      return audioDirectory.path;
    }
    audioDirectory =
        await Directory('$directory/audio').create(recursive: true);
    return audioDirectory.path;
  }

  //get sections directory
  Future<String> getSectionsDirectory(String scoreId) async {
    final String path = await getScoreDirectory(scoreId);
    Directory directory = Directory('$path/sections');
    if (await directory.exists()) {
      return directory.path;
    }
    directory = await Directory('$path/sections').create(recursive: true);
    return directory.path;
  }

  //get clicks directory
  Future<String> getClicksDirectory(String scoreId) async {
    final String path = await getScoreDirectory(scoreId);
    Directory directory = Directory('$path/clicks');
    if (await directory.exists()) {
      return directory.path;
    }
    directory = await Directory('$path/clicks').create(recursive: true);
    return directory.path;
  }

  //get images directory
  Future<String> getImagesDirectory(String scoreId) async {
    final String path = await getScoreDirectory(scoreId);
    Directory directory = Directory('$path/images');
    if (await directory.exists()) {
      return directory.path;
    }
    directory = await Directory('$path/images').create(recursive: true);
    return directory.path;
  }

  Future<File> jsonSectionFile(String scoreId, String sectionKey) async {
    final path = await getSectionsDirectory(scoreId);
    return File('$path/$sectionKey.json');
  }

  Future<File> jsonClickFile(String scoreId, String sectionKey) async {
    final String path = await getClicksDirectory(scoreId);
    return File('$path/${sectionKey}_click.json');
  }

  Future<File> imageFile(String scoreId, String imageId) async {
    final path = await getImagesDirectory(scoreId);
    return File('$path/$imageId.$imageFormat');
  }

//AUDIO FILE
  Future<File> audioFile(
      String scoreId, String audioFileName, String audioFormat) async {
    final path = await getAudioDirectory(scoreId);
    return File('$path/$audioFileName.$audioFormat');
  }

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
    }
    await sectionFile.writeAsString(json.encode(data));

    return data;
  }

  //write click data
  Future<List<ClickData>> writeClickJsonFile(
      String scoreId, String sectionKey, List<ClickData> data) async {
    File file = await jsonClickFile(scoreId, sectionKey);
    if (await file.exists() && json.encode(data) == await file.readAsString()) {
      return data;
    }
    await file.writeAsString(json.encode(data));
    return data;
  }

  //read click file
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
    final String imageRefString = imageUrl.split('/').last;
    File file = await imageFile(scoreId, imageRefString);
    // Uint8List byteList;

    if (!await file.exists()) {
      Response response = await Client().get(
        Uri.parse(imageUrl),
      );

      Uint8List byteList = response.bodyBytes;
      // imageController.imageData = byteList;
      // imageController.imageFile = file;
      await writeImageFile(byteList, file);
      // file = await imageFile(scoreId, imageRefString);
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

//write audio file
  Future<bool> writeAudioFile(
      String scoreId, String audioFileName, Uint8List byteList) async {
    final String path = await getAudioDirectory(scoreId);
    final File file = File('$path/$audioFileName');
    await file.writeAsBytes(byteList, flush: true);
    return true;
  }

  //read audio file
  Future<({Uint8List bytes, String path})> readAudioFile(
      String scoreId, String audioFileName, String audioUrl) async {
    Uint8List byteList = Uint8List(0);
    final String path = await getAudioDirectory(scoreId);
    final String fullPath = '$path/$audioFileName';
    final File file = File(fullPath);
    if (await file.exists() && await file.length() > 0) {
      byteList = await file.readAsBytes();
      return (bytes: byteList, path: fullPath);
    } else {
      try {
        Response response = await Client().get(
          Uri.parse(audioUrl),
        );
        if (response.statusCode == 200) {
          byteList = response.bodyBytes;
          await writeAudioFile(scoreId, audioFileName, byteList);
          return (bytes: byteList, path: fullPath);
        } else {
          throw Exception('Failed to download audio file');
        }
      } catch (e) {
        log(e.toString());
      }

      return (bytes: byteList, path: fullPath);
    }
  }

  //save score data
  Future<void> writeScoreData(String scoreId, InitScore data) async {
    final String path = await _gphilRootDirectory;
    final File scoreFile = File('$path/score_$scoreId.json');

    log('writeScoreData ${data.id}');
    await scoreFile.writeAsString(json.encode(data));
  }

  //read score data
  Future<InitScore?> readScoreData(String scoreId) async {
    final String rootPath = await _gphilRootDirectory;
    final File localScoreJson = File('$rootPath/score_$scoreId.json');
    final tasks = <Future>[];
    InitScore? scoreJson;

    if (await localScoreJson.exists()) {
      // log('reading score data');

      final Map<String, dynamic> scoreData = await Isolate.run(
          () async => await json.decode(await localScoreJson.readAsString()));
      scoreJson = await Isolate.run(() => InitScore.fromJson(scoreData));

      List<InitSection> getAllSections() {
        final allSections = <InitSection>[];
        for (final movement in scoreJson!.movements) {
          for (final section in movement.sections) {
            allSections.add(section);
          }
        }
        return allSections;
      }

      Future<void> getImageFile(String scoreId, String imageRef) async {
        await readImageFile(scoreId, imageRef);
      }

      final sections = getAllSections();

      for (final section in sections) {
        if (section.sectionImage != null) {
          String imageRef = section.sectionImage!.asset.ref;
          tasks.add(getImageFile(scoreId, imageRef));
        }
      }

      await Future.wait(tasks);
      return scoreJson;
    } else {
      log('downloading score data');
      scoreJson = await SanityService().fetchScore(scoreId);
      if (scoreJson != null) {
        await writeScoreData(scoreId, scoreJson);
        // return score;
      }
    }

    return scoreJson;
  }

//update score
  Future<void> updateScore(String scoreId, String scoreRev) async {
    await deleteScore(scoreId);
    await readScoreData(scoreId);
    await writeScoreRevision(scoreId, scoreRev);
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
      final String path = await getScoreDirectory(score.id);
      final File scoreFile = File('$path/score_${score.id}.json');
      await scoreFile.writeAsString(json.encode(score));
      await checkScoreRevision(score.id, score.rev);
    }
  }

//read library
  Future<List<InitScore>> readLibrary() async {
    List<InitScore> scores = [];
    final String path = await _gphilRootDirectory;

    //check if app is online. if no, return local library
    if (!await isOnline()) {
      scores = await getLocalLibrary();
    } else {
      //check if app is up to date
      final File statusFile = File('$path/library_status.json');
      if (await statusFile.exists()) {
        final Map<String, dynamic> statusData =
            json.decode(await statusFile.readAsString());

        //if up to date, return the whole library list
        if (statusData['isUptoDate'] == true) {
          scores = await getLocalLibrary();
        }
      }
    }

    return scores;
  }

  //get all items from local library
  Future<List<InitScore>> getLocalLibrary() async {
    final List<InitScore> scores = [];
    final String path = await _gphilRootDirectory;
    final Directory directory = Directory(path);
    if (await directory.exists()) {
      final List<FileSystemEntity> files = directory.listSync();
      for (FileSystemEntity file in files) {
        if (file.path.endsWith('.json')) {
          final Map<String, dynamic> scoreData = await Isolate.run(() async =>
              await json.decode(await File(file.path).readAsString()));
          scores.add(InitScore.fromJson(scoreData));
        }
      }
    }
    return scores;
  }

//wrire score revision
  Future<String> writeScoreRevision(String scoreId, String scoreRev) async {
    final String path = await getScoreDirectory(scoreId);
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
    final String path = await getScoreDirectory(scoreId);
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
    final String directory = await getScoreDirectory(scoreId);
    final String path = await _gphilRootDirectory;
    final scoreFile = File('$path/score_$scoreId.json');
    if (await scoreFile.exists()) {
      scoreFile.deleteSync();
    }

    Directory(directory).deleteSync(recursive: true);
  }
}
