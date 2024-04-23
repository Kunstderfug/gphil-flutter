import 'dart:io';
import 'package:flutter/foundation.dart';

class ImageController extends ChangeNotifier {
  File? _imageFile;
  Uint8List _imageData = Uint8List(0);
  bool _imageSet = false;
  Uint8List get imageData => _imageData;
  bool get imageSet => _imageSet;

  File? get imageFile => _imageFile;

  set imageFile(File? data) {
    _imageFile = data;
    notifyListeners();
  }

  set imageSet(bool data) {
    _imageSet = data;
    notifyListeners();
  }

  set imageData(Uint8List data) {
    _imageData = data;
    imageSet = true;
    notifyListeners();
  }
}
