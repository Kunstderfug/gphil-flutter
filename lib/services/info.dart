import 'package:flutter/material.dart';

class InfoMessage with ChangeNotifier {
  String _message = "";
  String _error = "";

  String get message => _message;
  String get error => _error;

  void setMessage(String message) {
    _message = message;
    notifyListeners();
  }

  void setTitle(String title) {
    _error = title;
    notifyListeners();
  }
}
