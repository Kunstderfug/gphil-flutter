import 'package:flutter/material.dart';

class FirstBeatFlash extends StatelessWidget {
  const FirstBeatFlash({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: 260,
        height: 5,
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: Container(
            width: 400,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.red.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
