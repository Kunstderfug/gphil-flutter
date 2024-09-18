import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/services/sanity_service.dart';
import 'package:gphil/services/supabase_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sanity = SanityService();
final prefs = SharedPreferences.getInstance();

class AppUpdateService extends ChangeNotifier {
  String currentVersion = '';
  String onlineVersion = '';
  AppVersionInfo? appVersionInfo;
  String? progress;
  bool updateDownloaded = false;
  CancelToken? cancelToken;
  bool updateAbortedByUser = false;
  AppState? appState;
  String error = '';
  bool updateChecked = false;
  String downloadPath = '';
  String fileName = '';
  String filePath = '';
  String downloadError = '';
  final ac = AppConnection();

  bool get updateAvailable =>
      onlineVersion != '' && currentVersion != onlineVersion;

  String get platform => kIsWeb ? 'web' : Platform.operatingSystem;

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
    if (!updateChecked) {
      log('Update checked: $updateChecked');
      try {
        appState = AppState.connecting;
        notifyListeners();
        currentVersion = await getVersionNumber();
        appVersionInfo = await getAppVersionInfo();
        onlineVersion = appVersionInfo?.build ?? '';
        appState = AppState.idle;
        notifyListeners();
      } catch (e) {
        reset();
        log(e.toString());
      }
      updateChecked = true;
      notifyListeners();
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
      notifyListeners();
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
    final url = SupabaseService().supabaseUrl;
    final dio = Dio();
    fileName = 'GPhil_v${onlineVersion}_installer';
    cancelToken = CancelToken();
    try {
      // Get the document directory
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        reset();
        return null;
      }
      downloadPath = selectedDirectory;
      appState = AppState.loading;
      updateDownloaded = false;
      progress = '0';
      updateAbortedByUser = false;
      notifyListeners();

      // Define the file name

      String file = platform == 'macos' ? '$fileName.dmg' : '$fileName.exe';
      filePath = '$selectedDirectory/$file';
      // log(platform);

      await dio.download(
        platform == 'macos'
            ? '$url/app_release/GPhil_v$onlineVersion.dmg'
            : '$url/app_release/GPhil_v$onlineVersion.exe',
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (receivedBytes, totalBytes) {
          if (totalBytes == -1) {
            log('File size unknown');
            progress = '${receivedBytes / 1024 / 1024} MB';
            notifyListeners();
          } else {
            // log('Received: $receivedBytes, Total: $totalBytes');
            progress =
                '${(receivedBytes / totalBytes * 100).toStringAsFixed(0)}%';
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
      downloadError = 'Error downloading file: $e';
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
