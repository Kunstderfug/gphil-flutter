import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpacityProvider extends ChangeNotifier {
  double opacity = 0;

  void resetOpacity() {
    opacity = 0;
    notifyListeners();
  }

  void setOpacity(double value) async {
    final prefs = await SharedPreferences.getInstance();
    opacity = value;
    prefs.setDouble('opacity', value);
    prefs.setBool('opacity-set', true);
    notifyListeners();
  }

  Future<void> getOpacity() async {
    final prefs = await SharedPreferences.getInstance();
    opacity = prefs.getDouble('opacity') ?? 0.25;
  }
}
