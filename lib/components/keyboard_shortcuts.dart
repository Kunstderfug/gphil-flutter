import 'package:flutter/material.dart';

class KeyboardShortcutDisplay extends StatelessWidget {
  final Map<String, String> shortcuts;

  const KeyboardShortcutDisplay({super.key, required this.shortcuts});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Keyboard Shortcuts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...shortcuts.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Text(entry.key,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(entry.value),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
