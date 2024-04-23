import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:gphil/models/score_user_prefs.dart';
import 'package:gphil/controllers/image_controller.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

class PersistentDataController {
  final imageFormat = 'png';
  final imageController = ImageController();

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

    return directory.path;
  }

  Future<String> getScoreDirectory(String scoreId) async {
    final path = await _sectionDirectoryPath;
    Directory directory = Directory('$path/$scoreId');
    if (await directory.exists()) {
      return directory.path;
    }
    directory = await Directory('$path/$scoreId').create(recursive: true);

    return directory.path;
  }

  Future<File> jsonSectionFile(String scoreId, String sectionKey) async {
    final path = await getScoreDirectory(scoreId);
    return File('$path/$sectionKey.json');
  }

  Future<File> jsonClickFile(String sectionId) async {
    final path = await _sectionDirectoryPath;
    return File('$path/$sectionId.json');
  }

  Future<File> imageFile(String scoreId, String imageId) async {
    final path = await getScoreDirectory(scoreId);
    return File('$path/$imageId');
  }

  Future<Map<String, dynamic>?> readJsonFile(
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

  Future<SectionPrefs> writeJsonFile(
      String scoreId, String sectionKey, SectionPrefs data) async {
    File file = await jsonSectionFile(scoreId, sectionKey);
    if (await file.exists() && json.encode(data) == await file.readAsString()) {
      return data;
    }
    await file.writeAsString(json.encode(data));

    return data;
  }

  Future<File?> readImageFile(
      String scoreId, String imageUrl, String imageRef) async {
    File file = await imageFile(scoreId, imageRef);
    Uint8List byteList;

    if (await file.exists()) {
      try {
        byteList = await file.readAsBytes();
        imageController.imageData = byteList;
        imageController.imageFile = file;
      } catch (e) {
        log(e.toString());
      }
    } else {
      Response response = await Client().get(
        Uri.parse(imageUrl),
      );

      Uint8List byteList = response.bodyBytes;
      imageController.imageData = byteList;
      imageController.imageFile = file;
      await writeImageFile(byteList, file);
    }

    return file;
  }

  Future<void> writeImageFile(Uint8List byteList, File file) async {
    await file.writeAsBytes(byteList, flush: true);
  }

  deleteImage(String scoreId, String imageRef) async {
    File file = await imageFile(scoreId, imageRef);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
