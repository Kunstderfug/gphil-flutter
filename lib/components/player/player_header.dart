import 'package:flutter/material.dart';
import 'package:gphil/components/performance/performance_mode.dart';
import 'package:gphil/components/performance/save_session_dialog.dart';
import 'package:gphil/providers/library_provider.dart';
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
      ScoreProvider s, NavigationProvider n, LibraryProvider l) {
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
              _navigateBack(p, s, n, l); // Navigate back
            },
          ),
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyles()
                  .textMd
                  .copyWith(color: Colors.white.withValues(alpha: 0.5)),
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
                        _navigateBack(p, s, n, l); // Navigate back after saving
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

  void _handleBackNavigation(BuildContext context, PlaylistProvider p,
      ScoreProvider s, NavigationProvider n, LibraryProvider l) {
    if (p.sessionChanged) {
      // Show save dialog only if there are changes
      _showSaveConfirmationDialog(context, p, s, n, l);
    } else {
      // Navigate back directly if no changes
      _navigateBack(p, s, n, l);
    }
  }

  void _navigateBack(PlaylistProvider p, ScoreProvider s, NavigationProvider n,
      LibraryProvider l) async {
    if (p.isPlaying) {
      await p.stop();
    }
    if (s.currentScore != null || s.currentScore?.id != p.sessionScore!.id) {
      l.setScoreId(p.sessionScore!.id);
      await s.getScore(p.sessionScore!.id);
    }
    //set plyalist section image to null to avoid showing the same image again in score view
    // p.currentSectionImage = null;
    s.setSections(p.currentMovementKey!, p.currentSection!.key);
    s.setCurrentSectionByKey(p.currentMovementKey!, p.currentSection!.key);
    n.setScoreScreen();
  }

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context, listen: false);
    final p = Provider.of<PlaylistProvider>(context);
    final s = Provider.of<ScoreProvider>(context, listen: false);
    final l = Provider.of<LibraryProvider>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          iconSize: iconSizeXs,
          padding: const EdgeInsets.all(paddingSm),
          tooltip: 'Back to Score',
          onPressed: () => _handleBackNavigation(context, p, s, n, l),
          icon: const Icon(Icons.arrow_back),
        ),
        const PerformanceMode(),
      ],
    );
  }
}
