import 'package:flutter/material.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class Metronome extends StatefulWidget {
  const Metronome({super.key});

  @override
  State<Metronome> createState() => _MetronomeState();
}

class _MetronomeState extends State<Metronome>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Create a curved animation that goes back and forth
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.2, end: 0.5),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 0.2),
        weight: 1.0,
      ),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);
    final size = 184.0;

    // Update animation state and duration
    if (p.isPlaying) {
      _animationController.duration =
          Duration(milliseconds: p.beatLength != 0 ? p.beatLength : 3000);
      if (!_animationController.isAnimating) {
        _animationController.repeat();
      }
    } else {
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
    }

    Color setColor() => p.currentSection?.autoContinueMarker != null &&
            p.currentSection?.autoContinue != false
        ? greenColor
        : redColor;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
        shape: BoxShape.circle,
        border: Border.all(
          color: p.isFirstBeat && p.isStarted ? setColor() : Colors.white24,
          width: 2,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          // Background Icon/Text
          _buildBackgroundContent(p),

          // Animated Dot
          if (p.currentBeatData?.beat != null)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => AnimatedContainer(
                duration: Duration(milliseconds: p.beatLength),
                curve: Curves.linear,
                width: size,
                height: 22,
                alignment: Alignment(p.isStarted ? (p.isLeft ? -1 : 1) : 0, 0),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: p.isStarted ? setColor() : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackgroundContent(PlaylistProvider p) {
    if (p.currentBeatData?.beat != null) {
      if (p.isStarted) {
        return Opacity(
          opacity: 0.1,
          child: Text(
            '${p.currentBeatData?.beat}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 130, fontWeight: FontWeight.bold),
          ),
        );
      }
      return AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) => Opacity(
          opacity: _opacityAnimation.value,
          child: Icon(
            !p.isPlaying ? Icons.play_arrow : Icons.pause,
            size: 140,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) => Opacity(
        opacity: _opacityAnimation.value,
        child: Center(
          child: Text(
            'No \nmetronome \ndata yet',
            textAlign: TextAlign.center,
            style: TextStyles().textLg,
          ),
        ),
      ),
    );
  }
}
