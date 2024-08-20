import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/services/sanity_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

final sanity = SanityService();

class AppUpdateService extends ChangeNotifier {
  String currentVersion = '';
  String onlineVersion = '';
  AppVersionInfo? appVersionInfo;
  double? progress;
  bool updateDownloaded = false;
  String platform = Platform.operatingSystem;
  CancelToken? cancelToken;
  bool updateAbortedByUser = false;
  AppState? appState;
  String error = '';
  bool updateChecked = false;
  final ac = AppConnection();

  bool get updateAvailable =>
      onlineVersion != '' && currentVersion != onlineVersion;

  AppUpdateService() {
    isAppVersionUpdated();
  }

  void reset() {
    updateDownloaded = false;
    progress = null;
    updateAbortedByUser = false;
    notifyListeners();
  }

  Future<bool> isAppVersionUpdated() async {
    log('isAppVersionUpdated');
    if (!updateChecked) {
      try {
        appState = AppState.connecting;
        notifyListeners();
        currentVersion = await getVersionNumber();
        appVersionInfo = await getAppVersionInfo();
        onlineVersion = appVersionInfo?.build ?? '';
        appState = AppState.idle;
      } catch (e) {
        reset();
        log(e.toString());
      }
    }

    appState = AppState.idle;
    updateChecked = true;
    notifyListeners();
    return currentVersion != onlineVersion;
  }

  Future<String> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    log(packageInfo.version);

    return packageInfo.version;
  }

  Future<AppVersionInfo?> getAppVersionInfo() async {
    try {
      appState = AppState.connecting;
      notifyListeners();
      final AppVersionInfo? appVersionInfo = await sanity.getOnlineVersion();
      if (appVersionInfo == null) {
        appState = AppState.genericError;
        notifyListeners();
        return null;
      }
      appState = AppState.idle;
      notifyListeners();

      return appVersionInfo;
    } catch (e) {
      appState = AppState.genericError;
      notifyListeners();
      return null;
    }
  }

  Future<String?> updateApp() async {
    final dio = Dio();
    cancelToken = CancelToken();
    try {
      // Get the document directory
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        reset();
        return null;
      }
      appState = AppState.loading;
      updateDownloaded = false;
      progress = 0;
      updateAbortedByUser = false;
      notifyListeners();

      // Define the file name
      String fileName = platform == 'macos'
          ? 'Gphil_v$onlineVersion.dmg'
          : 'gphil_v$onlineVersion.zip';
      String filePath = '$selectedDirectory/$fileName';
      log(platform);

      await dio.download(
        platform == 'macos'
            ? 'https://g-phil.app/app/gphil_v$onlineVersion.dmg'
            : 'https://g-phil.app/app/gphil_v$onlineVersion.zip',
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (receivedBytes, totalBytes) {
          if (totalBytes == -1) {
            progress = receivedBytes / 1024 / 1024;
            notifyListeners();
          } else {
            progress = receivedBytes / totalBytes * 100;
            notifyListeners();
          }
        },
      );
      log('File downloaded to: $filePath');
      progress = null;
      updateDownloaded = true;
      appState = AppState.idle;
      notifyListeners();
      return filePath;
    } catch (e) {
      log('Error downloading file: $e');
      progress = null;
      updateDownloaded = false;
      appState = AppState.idle;
      notifyListeners();
      return null;
    }
  }

  void cancelUpdate() {
    progress = null;
    cancelToken?.cancel();
    cancelToken = null;
    updateAbortedByUser = true;
    notifyListeners();
  }
}
