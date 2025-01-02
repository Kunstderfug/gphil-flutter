// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gphil/components/score/section_image.dart';
// import 'package:gphil/models/section.dart';
import 'package:gphil/providers/playlist_provider.dart';
// import 'package:gphil/services/app_state.dart';
// import 'package:gphil/services/sanity_service.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class ImageProgress extends StatefulWidget {
  const ImageProgress({super.key});

  @override
  State<ImageProgress> createState() => _ImageProgressState();
}

class _ImageProgressState extends State<ImageProgress>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, p, child) {
        if (p.imageProgress && p.nextSectionImage != null) {
          _controller.forward().then((_) {
            p.imageProgress = false;
            _controller.reset();
          });
        }

        return AspectRatio(
          aspectRatio: 16 / 9, // Match your image aspect ratio
          child: Stack(
            children: [
              SectionImageFrame(
                  imageFile: p.currentSectionImage, section: p.currentSection!),
              Positioned(
                top: sizeXs,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _animation,
                  child: SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(
                      value: _animation.value,
                      color: p.setColor(),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
