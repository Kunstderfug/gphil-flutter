import 'package:flutter/material.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class ImageProgress extends StatefulWidget {
  final double windowSize;
  const ImageProgress({super.key, required this.windowSize});

  @override
  State<ImageProgress> createState() => _ImageProgressState();
}

class _ImageProgressState extends State<ImageProgress>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startProgress() {
    _controller.forward();
    isStarted = true;

    Future.delayed(const Duration(milliseconds: 5000), () {
      // _controller.stop();
      resetAnimation();
    });
  }

  void resetAnimation() {
    _controller.stop();
    _controller.reset();
    final p = Provider.of<PlaylistProvider>(context, listen: false);
    p.imageProgress = false;
    isStarted = false;
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);
    if (p.imageProgress && p.nextSectionImage != null && !isStarted) {
      startProgress();
    }

    return FadeTransition(
      opacity: _animation,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return SizedBox(
            width: widget.windowSize,
            height: 4,
            child: LinearProgressIndicator(
              value: _animation.value,
              color: redColor,
              backgroundColor: Colors.transparent,
            ),
          );
        },
      ),
    );
  }
}
