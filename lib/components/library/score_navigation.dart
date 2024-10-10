import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_links.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

final persistentController = PersistentDataController();

class ScoreNavigation extends StatefulWidget {
  const ScoreNavigation({
    super.key,
  });

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
    );

    _animation = Tween<double>(begin: 0, end: 13).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context);
    final s = context.watch<ScoreProvider>();
    final a = Provider.of<AppConnection>(context);

    !s.scoreIsUptoDate ? _controller.repeat() : _controller.stop();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          iconSize: iconSizeXs,
          padding: const EdgeInsets.all(paddingMd),
          tooltip: 'Back to Library',
          onPressed: () {
            n.setCurrentIndex(0);
            n.setSelectedIndex(0);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        isTablet(context) ? const ScoreLinks() : const SizedBox(),
        Opacity(
          opacity: a.appState == AppState.offline ? 0.4 : 1,
          child: Stack(alignment: AlignmentDirectional.center, children: [
            Positioned(
              top: 4,
              left: 4,
              child: SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  color: Theme.of(context).highlightColor,
                  strokeCap: StrokeCap.round,
                  value: s.progressDownload,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                    iconSize: iconSizeXs,
                    padding: const EdgeInsets.all(paddingMd),
                    tooltip: a.appState == AppState.offline
                        ? 'Unable to download in offline mode'
                        : 'Download',
                    onPressed: () => a.appState == AppState.offline
                        ? null
                        : s.saveAudioFiles(s.currentSections),
                    icon: const Icon(Icons.download_outlined)),
                !s.scoreIsUptoDate && s.currentScore != null
                    ? IconButton(
                        iconSize: iconSizeXs,
                        padding: const EdgeInsets.all(paddingMd),
                        tooltip: 'Score update available, press to update',
                        onPressed: () async {
                          await s.updateCurrentScore();
                          _controller.stop();
                          _controller.reset();
                        },
                        icon: AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) => Transform.rotate(
                                  angle: _animation.value,
                                  child: Icon(Icons.refresh, color: redColor),
                                )))
                    : IconButton(
                        iconSize: iconSizeMd,
                        padding: const EdgeInsets.all(paddingMd),
                        tooltip: a.appState == AppState.offline
                            ? 'If you delete the score, it wont be accessible until app is online again'
                            : 'Delete score',
                        onPressed: () async => a.appState == AppState.offline
                            ? null
                            : await persistentController
                                .deleteScore(s.currentScore!.id),
                        icon: const Icon(
                          size: iconSizeXs,
                          Icons.delete,
                        )),
              ],
            ),
          ]),
        ),
      ],
    );
  }
}
