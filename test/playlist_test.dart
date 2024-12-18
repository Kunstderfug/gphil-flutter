// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isLoopingActive', () {
    late Playlist playlist; // Replace YourClass with the actual class name

    setUp(() {
      playlist = Playlist();
    });

    test(
        'returns true when currentSection is looped and not in performance mode',
        () {
      playlist.currentSection = Section(looped: true);
      playlist.performanceMode = false;

      expect(playlist.isLoopingActive, true);
    });

    test('returns false when currentSection is not looped', () {
      playlist.currentSection = Section(looped: false);
      playlist.performanceMode = false;

      expect(playlist.isLoopingActive, false);
    });

    test('returns false when in performance mode', () {
      playlist.currentSection = Section(looped: true);
      playlist.performanceMode = true;

      expect(playlist.isLoopingActive, false);
    });

    test('returns false when currentSection is null', () {
      playlist.currentSection = null;
      playlist.performanceMode = false;

      expect(playlist.isLoopingActive, false);
    });
  });
}

// Mock classes for testing purposes
class Playlist {
  Section? currentSection;
  bool performanceMode = false;

  bool get isLoopingActive {
    if (currentSection?.looped == true && !performanceMode) {
      return true;
    } else {
      return false;
    }
  }
}

class Section {
  final bool looped;

  Section({required this.looped});
}
