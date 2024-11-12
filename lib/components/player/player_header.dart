import 'package:flutter/material.dart';
import 'package:gphil/components/performance/performance_mode.dart';
import 'package:gphil/components/performance/save_session_dialog.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/services/session_service.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PlayerHeader extends StatelessWidget {
  final String sectionName;
  const PlayerHeader({super.key, required this.sectionName});

  void _showSaveConfirmationDialog(BuildContext context, PlaylistProvider p,
      ScoreProvider s, NavigationProvider n) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Save Session?', style: TextStyles().textLg),
        content: Text(
          'Would you like to save your current session before leaving?',
          style: TextStyles().textMd,
        ),
        actions: [
          TextButton(
            child: Text('Don\'t Save',
                style: TextStyles().textMd.copyWith(color: redColor)),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _navigateBack(p, s, n); // Navigate back
            },
          ),
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyles()
                  .textMd
                  .copyWith(color: Colors.white.withOpacity(0.5)),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Just close dialog
            },
          ),
          TextButton(
            child: Text('Save',
                style: TextStyles().textMd.copyWith(color: greenColor)),
            onPressed: () {
              Navigator.of(context).pop(); // Close confirmation dialog
              // Show save session dialog
              showDialog(
                context: context,
                builder: (context) => SaveLoadSessionDialog(
                  sessionService: SessionService(s),
                  scoreName: '${p.sessionScore?.pathName}',
                  movementIndices: p.playlist
                      .map((section) => section.movementIndex)
                      .toSet()
                      .toList(),
                  onSave: (String name, SessionType type) async {
                    try {
                      await SessionService(s).saveSession(
                          name, p.sessionScore!.id, type, p.playlist, p);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: greenColor,
                          content: Text('Session saved successfully',
                              style: TextStyles()
                                  .textMd
                                  .copyWith(color: Colors.white)),
                        ));
                        _navigateBack(p, s, n); // Navigate back after saving
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.black,
                            content: Text('Session save failed',
                                style: TextStyles().textMd),
                          ),
                        );
                      }
                    }
                  },
                  onLoad: (UserSession session) {}, // Not needed for this case
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _hasTempoChanges(PlaylistProvider p, ScoreProvider s) {
    final originalSection = s.allSections
        .firstWhere((section) => section.key == p.currentSectionKey);

    if (originalSection.userTempo != null &&
        originalSection.userTempo != p.currentSection?.userTempo) {
      return true;
    }
    if (originalSection.defaultTempo != p.currentSection?.userTempo) {
      return true;
    }
    return false;
  }

  void _handleBackNavigation(BuildContext context, PlaylistProvider p,
      ScoreProvider s, NavigationProvider n) {
    if (_hasTempoChanges(p, s) || p.sessionChanged) {
      // Show save dialog only if there are changes
      _showSaveConfirmationDialog(context, p, s, n);
    } else {
      // Navigate back directly if no changes
      _navigateBack(p, s, n);
    }
  }

  void _navigateBack(
      PlaylistProvider p, ScoreProvider s, NavigationProvider n) async {
    if (p.isPlaying) {
      p.stop();
    }
    if (s.currentScore != null || s.currentScore?.id != p.sessionScore!.id) {
      await s.getScore(p.sessionScore!.id);
    }
    s.setSections(p.currentMovementKey!, p.currentSection!.key);
    s.setCurrentSectionByKey(p.currentMovementKey!, p.currentSection!.key);
    n.setScoreScreen();
  }

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context, listen: false);
    final p = Provider.of<PlaylistProvider>(context);
    final s = Provider.of<ScoreProvider>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          iconSize: iconSizeXs,
          padding: const EdgeInsets.all(paddingSm),
          tooltip: 'Back to Score',
          onPressed: () => _handleBackNavigation(context, p, s, n),
          icon: const Icon(Icons.arrow_back),
        ),
        PerformanceMode(p: p),
      ],
    );
  }
}
