import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpacityProvider extends ChangeNotifier {
  double userOpacity = 0;

  OpacityProvider() {
    getOpacity();
  }

  void resetOpacity() {
    userOpacity = 0;
    notifyListeners();
  }

  void setOpacity(double value) async {
    final prefs = await SharedPreferences.getInstance();
    userOpacity = value;
    prefs.setDouble('opacity', value);
    prefs.setBool('opacity-set', true);
    notifyListeners();
  }

  Future<void> getOpacity() async {
    final prefs = await SharedPreferences.getInstance();
    final bool sectionsColorized = prefs.getBool('sectionsColorized') ?? false;
    if (sectionsColorized) {
      userOpacity = prefs.getDouble('opacity') ?? 0.25;
      notifyListeners();
    } else {
      userOpacity = 0;
      notifyListeners();
    }
  }
}
