import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_links.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';

final persistentController = PersistentDataController();

class ScoreNavigation extends StatefulWidget {
  const ScoreNavigation({
    super.key,
    required this.p,
    required this.s,
    required this.n,
  });

  final PlaylistProvider p;
  final ScoreProvider s;
  final NavigationProvider n;

  @override
  State<ScoreNavigation> createState() => _ScoreNavigationState();
}

class _ScoreNavigationState extends State<ScoreNavigation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 13).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          iconSize: iconSizeXs,
          padding: const EdgeInsets.all(paddingMd),
          tooltip: 'Back to Library',
          onPressed: () {
            widget.n.setNavigationIndex(0);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        isTablet(context) ? const ScoreLinks() : const SizedBox(),
        Stack(alignment: AlignmentDirectional.center, children: [
          SizedBox(
            height: sizeLg,
            width: sizeLg,
            child: CircularProgressIndicator(
              color: Theme.of(context).highlightColor,
              value: widget.s.progressDownload,
            ),
          ),
          Row(
            children: [
              IconButton(
                  iconSize: iconSizeXs,
                  padding: const EdgeInsets.all(paddingMd),
                  tooltip: 'Download',
                  onPressed: () async =>
                      await widget.s.saveAudioFiles(widget.p.playlist),
                  icon: const Icon(Icons.download_outlined)),
              !widget.s.scoreIsUptoDate && widget.s.currentScore != null
                  ? IconButton(
                      iconSize: iconSizeXs,
                      padding: const EdgeInsets.all(paddingMd),
                      tooltip: 'Score update available, refresh',
                      onPressed: () async =>
                          await widget.s.updateCurrentScore(),
                      icon: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) => Transform.rotate(
                                angle: _animation.value,
                                child: Icon(Icons.refresh, color: redColor),
                              )))
                  : IconButton(
                      iconSize: iconSizeMd,
                      padding: const EdgeInsets.all(paddingMd),
                      tooltip: 'Delete score',
                      onPressed: () async => await persistentController
                          .deleteScore(widget.s.currentScore!.id),
                      icon: const Icon(
                        size: iconSizeXs,
                        Icons.delete,
                      )),
            ],
          ),
        ]),
      ],
    );
  }
}
