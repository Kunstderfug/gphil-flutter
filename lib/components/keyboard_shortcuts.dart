import 'package:flutter/material.dart';

class KeyboardShortcuts extends StatelessWidget {
  final Map<List<String>, String> shortcuts;

  const KeyboardShortcuts({super.key, required this.shortcuts});

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
            const SizedBox(height: 16),
            ...shortcuts.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      ...entry.key.map((keyName) => _buildKey(keyName)),
                      const SizedBox(width: 16),
                      Expanded(child: Text(entry.value)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String keyName) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          keyName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}