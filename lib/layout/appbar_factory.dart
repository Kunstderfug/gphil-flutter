import 'package:flutter/material.dart';
import 'package:gphil/components/performance_appbar.dart';
import 'package:gphil/layout/score_appbar.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';

class AppBarFactory {
  static PreferredSizeWidget create({
    required NavigationProvider navigationProvider,
    required ScoreProvider scoreProvider,
  }) {
    if (!navigationProvider.isScoreScreen) {
      return PerformanceAppBar(
        n: navigationProvider,
        s: scoreProvider,
      );
    }
    return ScoreAppBar(s: scoreProvider);
  }
}
