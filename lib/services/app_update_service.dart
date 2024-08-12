import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gphil/services/sanity_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateService extends ChangeNotifier {
  String currentVersion = '';
  String? onlineVersion;
  AppVersionInfo? appVersionInfo;
  double? progress;
  bool updateDownloaded = false;
  String platform = Platform.operatingSystem;
  CancelToken? cancelToken;
  bool updateAvailable = false;
  bool updateAbortedByUser = false;
  bool loading = false;

  AppUpdateService() {
    if (updateDownloaded == false) {
      isAppVersionUpdated();
    }
  }

  void reset() {
    updateDownloaded = false;
    progress = null;
    updateAbortedByUser = false;
    notifyListeners();
  }

  Future<bool> isAppVersionUpdated() async {
    try {
      loading = true;
      notifyListeners();
      currentVersion = await getVersionNumber();
      appVersionInfo = await getAppVersionInfo();
      onlineVersion = appVersionInfo?.build ?? '';
      updateAvailable = currentVersion != onlineVersion;
      loading = false;
      notifyListeners();
    } catch (e) {
      reset();
      log(e.toString());
    }

    return currentVersion != onlineVersion;
  }

  Future<String> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    log(packageInfo.version);

    return packageInfo.version;
  }

  Future<AppVersionInfo?> getAppVersionInfo() async {
    final sanity = SanityService();
    final AppVersionInfo? appVersionInfo = await sanity.getOnlineVersion();
    if (appVersionInfo == null) {
      return null;
    }
    return appVersionInfo;
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
      updateDownloaded = false;
      progress = 0;
      updateAbortedByUser = false;
      notifyListeners();

      // Define the file name
      String fileName = platform == 'macos' ? 'Gphil.dmg' : 'gphil_windows.zip';
      String filePath = '$selectedDirectory/$fileName';
      log(platform);

      await dio.download(
        platform == 'macos'
            ? 'https://g-phil.app/app/gphil.dmgp'
            : 'https://g-phil.app/app/gphil_windows.zip',
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
      notifyListeners();
      return filePath;
    } catch (e) {
      log('Error downloading file: $e');
      progress = null;
      updateDownloaded = false;
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
