import 'package:flutter/material.dart';
import 'package:gphil/theme/constants.dart';

class KeyboardShortcutsSection extends StatelessWidget {
  const KeyboardShortcutsSection({super.key});

  static final _navigationShortcuts = _ShortcutCategory(
    title: 'Navigation',
    icon: Icons.navigation_sharp,
    shortcuts: [
      _Shortcut(
        keys: ['Ctrl/Cmd', '1'],
        description: 'Go to Library',
      ),
      _Shortcut(
        keys: ['Ctrl/Cmd', '2'],
        description: 'Go to Performance',
      ),
      _Shortcut(
        keys: ['Ctrl/Cmd', '3'],
        description: 'Go to Help',
      ),
    ],
  );

  static final _playbackShortcuts = _ShortcutCategory(
    title: 'Playback Controls',
    icon: Icons.play_arrow_outlined,
    shortcuts: [
      _Shortcut(
        keys: ['Enter'],
        description: 'Start playback / Continue to next section',
      ),
      _Shortcut(
        keys: ['Space'],
        description: 'Stop playback',
      ),
      _Shortcut(
        keys: ['←'],
        description: 'Previous section',
      ),
      _Shortcut(
        keys: ['→'],
        description: 'Next section',
      ),
    ],
  );

  static final _practiceShortcuts = _ShortcutCategory(
    title: 'Practice Mode',
    icon: Icons.piano_outlined,
    shortcuts: [
      _Shortcut(
        keys: ['L'],
        description: 'Toggle section loop',
      ),
      _Shortcut(
        keys: ['S'],
        description: 'Toggle section skip',
      ),
      _Shortcut(
        keys: ['A'],
        description: 'Toggle auto-continue',
      ),
      _Shortcut(
        keys: ['Arrow Up'],
        description: 'Increase current section volume',
      ),
      _Shortcut(
        keys: ['Arrow Down'],
        description: 'Decrease current section volume',
      ),
      _Shortcut(
        keys: ['M'],
        description: 'Toggle metronome sound',
      ),
      _Shortcut(
        keys: ['Comma'],
        description: 'Increase metronome sound',
      ),
      _Shortcut(
        keys: ['Period'],
        description: 'Decrease metronome sound',
      ),
      _Shortcut(
        keys: ['B'],
        description: 'Toggle metronome downbeat bell',
      ),
      _Shortcut(
        keys: ['O'],
        description: 'Save/Load session',
      ),
      _Shortcut(
        keys: ['P'],
        description: 'Toggle performance mode',
      ),
    ],
  );

  static final _otherShortcuts = _ShortcutCategory(
    title: 'Other',
    icon: Icons.settings_outlined,
    shortcuts: [
      _Shortcut(
        keys: ['Esc'],
        description: 'Exit to score view',
      ),
    ],
  );

  // First column categories
  static final _leftColumnCategories = [
    _navigationShortcuts,
    _playbackShortcuts,
  ];

  // Second column categories
  static final _rightColumnCategories = [
    _practiceShortcuts,
    _otherShortcuts,
  ];

  // All categories for single column view
  static final _allCategories = [
    ..._leftColumnCategories,
    ..._rightColumnCategories,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Keyboard Shortcuts',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),

        // Use LayoutBuilder to check available width
        LayoutBuilder(
          builder: (context, constraints) {
            final useColumns =
                constraints.maxWidth > 900; // Threshold for two columns

            if (useColumns) {
              // Two-column layout
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column
                  Expanded(
                    child: Column(
                      children: [
                        ..._leftColumnCategories,
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // Space between columns
                  // Right column
                  Expanded(
                    child: Column(
                      children: [
                        ..._rightColumnCategories,
                      ],
                    ),
                  ),
                ],
              );
            } else {
              // Single column layout
              return Column(
                children: [
                  // All categories in single column...
                  ..._allCategories,
                ],
              );
            }
          },
        ),
      ],
    );
  }
}

class _ShortcutCategory extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_Shortcut> shortcuts;

  const _ShortcutCategory({
    required this.title,
    required this.shortcuts,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: redColor.withOpacity(0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: redColor.withOpacity(0.7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSizeLg,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...shortcuts,
        ],
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  final List<String> keys;
  final String description;

  const _Shortcut({
    required this.keys,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Row(
              children: [
                ...keys.asMap().entries.map((entry) {
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: highlightColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: greenColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: greenColor,
                            fontFamily: 'monospace',
                            fontSize: fontSizeMd,
                          ),
                        ),
                      ),
                      if (entry.key < keys.length - 1)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text('+'),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: fontSizeMd),
            ),
          ),
        ],
      ),
    );
  }
}
