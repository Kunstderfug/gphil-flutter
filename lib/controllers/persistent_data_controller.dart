import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:gphil/models/score_user_prefs.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

class PersistentDataController {
  final imageFormat = 'png';

  Future<String> get _directoryPath async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> get _sectionDirectoryPath async {
    final path = await _directoryPath;
    //check if the section path exists
    Directory directory = Directory('$path/gphil/sections');
    if (await directory.exists()) {
      return directory.path;
    }
    directory = await Directory('$path/gphil/sections').create(recursive: true);
    log('directory created: ${directory.path}');

    return directory.path;
  }

  Future<String> getScoreDirectory(String scoreId) async {
    final path = await _sectionDirectoryPath;
    Directory directory = Directory('$path/$scoreId');
    if (await directory.exists()) {
      return directory.path;
    }
    directory = await Directory('$path/$scoreId').create(recursive: true);
    log('directory created: ${directory.path}');

    return directory.path;
  }

  Future<String> get _imagesDirectoryPath async {
    final path = await _directoryPath;
    return '$path/gphil_user_prefs/images';
  }

  Future<File> jsonSectionFile(String scoreId, String sectionKey) async {
    final path = await getScoreDirectory(scoreId);
    return File('$path/$sectionKey.json');
  }

  Future<File> jsonClickFile(String sectionId) async {
    final path = await _sectionDirectoryPath;
    return File('$path/$sectionId.json');
  }

  Future<File> imageFile(String imageId) async {
    final path = await _imagesDirectoryPath;
    return File('$path/$imageId.$imageFormat');
  }

  Future<Map<String, dynamic>?> readJsonFile(
      String scoreId, String sectionKey) async {
    String fileContent;

    File file = await jsonSectionFile(scoreId, sectionKey);

    if (await file.exists()) {
      try {
        fileContent = await file.readAsString();
        log('readJsonFile: $fileContent');
        return json.decode(fileContent);
      } catch (e) {
        log(e.toString());
      }
    }
    return null;
  }

  Future<SectionPrefs> writeJsonFile(
      String scoreId, String sectionKey, SectionPrefs data) async {
    File file = await jsonSectionFile(scoreId, sectionKey);
    if (await file.exists() && json.encode(data) == await file.readAsString()) {
      log('no need to write json file: ${file.path}');
      return data;
    }
    log('writing json file: ${file.path}');
    await file.writeAsString(json.encode(data));

    return data;
  }

  Future<Uint8List> readImageFile(String imageId) async {
    File file = await imageFile(imageId);
    Uint8List byteList = Uint8List(0);

    if (await file.exists()) {
      try {
        byteList = await file.readAsBytes();
      } catch (e) {
        log(e.toString());
      }
    }

    return byteList;
  }

  Future<Uint8List> writeImageFile(String imagePath, String imageId) async {
    Response response = await Client().get(
      Uri.parse(imagePath),
    );

    Uint8List bytes = response.bodyBytes;
    File file = await imageFile(imageId);
    await file.writeAsBytes(bytes);

    log(file.path);

    return bytes;
  }

  deleteImage(String imageId) async {
    File file = await imageFile(imageId);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
