// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:gphil/models/score.dart';
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';

class DatabaseHelper {
  static const String DB_NAME = 'GPHIL_DB';
  static const int DB_VERSION = 1;
  static const String STORE_NAME = 'score';

  Future<Database?> openDb(String scoreId) async {
    final IdbFactory? idb = getIdbFactory();
    return await idb?.open(DB_NAME, version: DB_VERSION,
        onUpgradeNeeded: (VersionChangeEvent event) {
      Database db = event.database;
      db.createObjectStore(STORE_NAME);
    });
  }

  Future<void> saveScore(String scoreId, InitScore fileContent) async {
    Database? db = await openDb(STORE_NAME);
    if (db == null) {
      return;
    }
    Transaction txn = db.transaction(STORE_NAME, 'readwrite');
    ObjectStore store = txn.objectStore(STORE_NAME);
    await store.put(fileContent.toJson(), scoreId);
    await txn.completed;
  }

  Future<InitScore?> getScore(String scoreId) async {
    Database? db = await openDb(STORE_NAME);
    log('db: $db');
    if (db == null) {
      return null;
    }
    Transaction txn = db.transaction(STORE_NAME, 'readonly');
    ObjectStore store = txn.objectStore(STORE_NAME);
    final fileContent = await store.getObject(scoreId);
    await txn.completed;
    if (fileContent == null) {
      return null;
    } else {
      final jsonFile = json.encode(fileContent);
      return InitScore.fromJson(json.decode(jsonFile));
    }
  }
}
