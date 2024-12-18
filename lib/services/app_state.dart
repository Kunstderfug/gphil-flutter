import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

enum AppState {
  idle,
  connecting,
  loading,
  playing,
  paused,
  stopped,
  online,
  offline,
  resumed,
  playerError,
  genericError,
  networkError
}

class AppConnection extends ChangeNotifier {
  final ic = InternetConnection();
  AppState appState = AppState.idle;

  AppConnection() {
    ic.onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          appState = AppState.online;
          log('Connected');
          break;
        case InternetStatus.disconnected:
          appState = AppState.offline;
          log('Disconnected');
          break;
      }
      notifyListeners();
    });
  }
}
