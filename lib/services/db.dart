import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:gphil/models/score_user_prefs.dart';
import 'package:gphil/models/section.dart';
import 'package:http/http.dart' as http;
import 'package:idb_shim/idb_client.dart';
import 'package:idb_shim/idb_shim.dart';
import 'package:idb_shim/idb_browser.dart';

class DB {
  Future<({Uint8List bytes, String key})> readAudioFile(
      String scoreId, String audioFileName, String audioUrl) async {
    final String key = '$scoreId/$audioFileName';
    final db = await openAudioDb();

    try {
      final txn = db.transaction('audioFiles', idbModeReadOnly);
      final store = txn.objectStore('audioFiles');
      final Uint8List? storedBytes = await store.getObject(key) as Uint8List?;

      if (storedBytes != null && storedBytes.isNotEmpty) {
        return (bytes: storedBytes, key: key);
      } else {
        try {
          final response = await http.get(Uri.parse(audioUrl));
          if (response.statusCode == 200) {
            final Uint8List downloadedBytes = response.bodyBytes;
            await writeAudioFile(db, key, downloadedBytes);
            return (bytes: downloadedBytes, key: key);
          } else {
            throw Exception('Failed to download audio file');
          }
        } catch (e) {
          log('Error downloading audio file: $e');
          return (bytes: Uint8List(0), key: key);
        }
      }
    } finally {
      db.close();
    }
  }

  Future<void> writeAudioFile(Database db, String key, Uint8List bytes) async {
    final txn = db.transaction('audioFiles', idbModeReadWrite);
    final store = txn.objectStore('audioFiles');
    await store.put(bytes, key);
    await txn.completed;
  }

  Future<List<ClickData>> loadClickData(Section section) async {
    final String key = '${section.scoreId}/${section.key}';
    final db = await openClickDataDb();

    try {
      final txn = db.transaction('clickData', idbModeReadOnly);
      final store = txn.objectStore('clickData');
      final String? storedData = await store.getObject(key) as String?;

      if (storedData != null) {
        final List<dynamic> jsonList = json.decode(storedData);
        return jsonList
            .map((jsonItem) => ClickData.fromJson(jsonItem))
            .toList();
      } else {
        if (section.clickDataUrl != null) {
          try {
            final response = await http.get(Uri.parse(section.clickDataUrl!));
            if (response.statusCode == 200) {
              final List<dynamic> jsonList = json.decode(response.body);
              final List<ClickData> clickDataList = jsonList
                  .map((jsonItem) => ClickData.fromJson(jsonItem))
                  .toList();
              await writeClickData(db, key, jsonList);
              return clickDataList;
            } else {
              throw Exception('Failed to download click data');
            }
          } catch (e) {
            log('Error downloading click data: $e');
            return [];
          }
        } else {
          return [];
        }
      }
    } finally {
      db.close();
    }
  }

  Future<void> writeClickData(
      Database db, String key, List<dynamic> data) async {
    final txn = db.transaction('clickData', idbModeReadWrite);
    final store = txn.objectStore('clickData');
    await store.put(json.encode(data), key);
    await txn.completed;
  }

  //creating audio db
  Future<Database> openAudioDb() async {
    final IdbFactory factory = idbFactoryBrowser;
    final db = await factory.open('AudioDatabase', version: 1,
        onUpgradeNeeded: (VersionChangeEvent event) {
      final db = event.database;
      db.createObjectStore('audioFiles');
    });
    return db;
  }

  //creating click data db
  Future<Database> openClickDataDb() async {
    final IdbFactory factory = idbFactoryBrowser;
    final db = await factory.open('ClickDataDatabase', version: 1,
        onUpgradeNeeded: (VersionChangeEvent event) {
      final db = event.database;
      db.createObjectStore('clickData');
    });
    return db;
  }
}
