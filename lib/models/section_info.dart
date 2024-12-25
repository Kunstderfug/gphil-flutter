class SectionInfo {
  final String sectionName;
  final String movementIndex;
  final List<int> tempos;
  final String? imagePath;
  int beatsPerBar = 4;
  int beatLength = 4;

  late final int minTempo;
  late final int maxTempo;
  late final int step;

  SectionInfo({
    required this.sectionName,
    required this.movementIndex,
    required this.tempos,
    this.imagePath,
  }) {
    tempos.sort();
    minTempo = tempos.first;
    maxTempo = tempos.last;

    // Calculate step
    List<int> sortedTempos = tempos.toSet().toList()..sort();
    if (sortedTempos.length > 1) {
      List<int> differences = [];
      for (int i = 1; i < sortedTempos.length; i++) {
        differences.add(sortedTempos[i] - sortedTempos[i - 1]);
      }
      step = differences.reduce((a, b) => a < b ? a : b);
    } else {
      step = 5; // default step
    }
  }

  @override
  String toString() {
    return 'Section: $sectionName\nTempo Range: $minTempo-$maxTempo\nStep: $step\nMovement: $movementIndex';
  }
}
