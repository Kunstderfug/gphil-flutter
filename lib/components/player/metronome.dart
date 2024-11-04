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
  int animationDuration = 3000;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: animationDuration))
      ..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    if (!p.isPlaying) {
      _animationController.stop();
    } else {
      setState(() {
        animationDuration = p.beatLength;
        _animationController.duration = Duration(
            milliseconds: animationDuration != 0 ? animationDuration : 3000);
        _animationController.repeat();
      });
    }

    double setAlignment() {
      if (!p.isStarted) {
        return 0;
      } else {
        return p.isLeft ? -1 : 1;
      }
    }

    Color setColor() {
      return p.currentSection?.autoContinueMarker != null &&
              p.currentSection?.autoContinue != false
          ? greenColor
          : redColor;
    }

    double size = 184;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
          shape: BoxShape.circle,
          border: Border.all(
              color: p.isFirstBeat && p.isStarted ? setColor() : Colors.white24,
              width: 2)),
      child: Center(
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Positioned(
              // top: -5,
              child: p.currentBeatData?.beat != null
                  ? p.isStarted
                      ? Opacity(
                          opacity: 0.1,
                          child: Text(
                            '${p.currentBeatData?.beat}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 130, fontWeight: FontWeight.bold),
                          ),
                        )
                      : AnimatedOpacity(
                          duration: Duration(milliseconds: animationDuration),
                          opacity: !p.isPlaying
                              ? 0.2
                              : _animationController.value / 2,
                          child: Icon(
                            !p.isPlaying ? Icons.play_arrow : Icons.pause,
                            size: 140,
                          ),
                        )
                  : AnimatedOpacity(
                      duration: Duration(milliseconds: animationDuration),
                      opacity:
                          !p.isPlaying ? 0.2 : _animationController.value / 2,
                      child: Center(
                        child: Text(
                          'No \nmetronome \ndata yet',
                          textAlign: TextAlign.center,
                          style: TextStyles().textLg,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            if (p.currentBeatData?.beat != null)
              AnimatedContainer(
                duration: Duration(milliseconds: p.beatLength),
                curve: Curves.linear,
                width: size,
                height: 22,
                alignment: Alignment(setAlignment(), 0),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: p.isStarted ? setColor() : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
