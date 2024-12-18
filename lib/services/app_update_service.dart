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
  String localBuild = '';
  String onlineBuild = '';
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

  bool updateAvailable = false;

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
    bool result = false;
    if (!updateChecked) {
      log('Update checked: $updateChecked');
      try {
        appState = AppState.connecting;
        notifyListeners();
        localBuild = await getVersionNumber();
        appVersionInfo = await getAppVersionInfo();
        onlineBuild = appVersionInfo?.build ?? localBuild;
        appState = AppState.idle;
        result = compareVersions(onlineBuild, localBuild);
        updateAvailable = result;
        log('$onlineBuild, $localBuild');
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
    return result;
  }

  bool compareVersions(String online, String local) {
    // Remove beta suffix from local version if present
    local = local.split('-')[0];

    // Clean versions to only contain numbers and dots
    String cleanVersion(String str) => str.replaceAll(RegExp(r'[^0-9.]'), '');

    online = cleanVersion(online);
    local = cleanVersion(local);

    // Split versions into parts
    List<int> onlineParts = online.split('.').map(int.parse).toList();
    List<int> localParts = local.split('.').map(int.parse).toList();

    // Compare each part
    for (int i = 0; i < onlineParts.length && i < localParts.length; i++) {
      if (onlineParts[i] > localParts[i]) return true;
      if (onlineParts[i] < localParts[i]) return false;
    }

    // If all parts are equal, consider versions equal
    return false;
  }

  Future<String> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // log(packageInfo.version);

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
      log('App version info: $appVersionInfo');
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
    fileName = 'GPhil_v${onlineBuild}_installer';
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
            ? '$url/app_release/GPhil_v$onlineBuild.dmg'
            : '$url/app_release/GPhil_v$onlineBuild.exe',
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
