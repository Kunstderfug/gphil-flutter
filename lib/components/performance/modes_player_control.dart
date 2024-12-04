import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gphil/components/performance/all_sections_tempo_switch.dart';
import 'package:gphil/components/performance/one_pedal_mode_switch.dart';
import 'package:gphil/components/performance/save_session_dialog.dart';
import 'package:gphil/components/performance/section_volume.dart';
import 'package:gphil/components/player/player_control.dart';
import 'package:gphil/components/score/section_tempos.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/library.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/services/session_service.dart';
import 'package:gphil/theme/constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final pc = PersistentDataController();

class OpenSessionDialogIntent extends Intent {
  const OpenSessionDialogIntent();
}

class ModesAndPlayerControl extends StatelessWidget {
  final double separatorWidth;
  final double height;
  const ModesAndPlayerControl(
      {super.key, required this.separatorWidth, required this.height});

  void _showSaveSessionDialog(BuildContext context, PlaylistProvider p,
      ScoreProvider s, LibraryProvider l) {
    showDialog(
      context: context,
      builder: (context) => SaveLoadSessionDialog(
        sessionService: SessionService(s),
        scoreName: '${p.sessionScore?.pathName}',
        movementIndices: p.playlist
            .map((section) => section.movementIndex)
            .toSet()
            .toList(), // Convert to unique list of movement indices
        onSave: (String name, SessionType type) async {
          try {
            await SessionService(s)
                .saveSession(name, p.sessionScore!.id, type, p.playlist, p);
            // Show success message
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: greenColor,
                content: Text('Session saved successfully',
                    style: TextStyles().textMd.copyWith(color: Colors.white)),
              ));
            }
          } catch (e) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  backgroundColor: Colors.black,
                  content: Text('Session save failed')),
            );
            return;
          }
        },
        onLoad: (UserSession session) async {
          p.isLoading = true;
          final formattedDate =
              DateFormat('MMM d, y HH:mm').format(session.timestamp);
          try {
            final result = await SessionService(s).loadSession(
              '${session.name}_$formattedDate'.replaceAll(
                RegExp(r'[/\\<>:"|?*\s]'),
                '_',
              ),
              session.type,
            );

            if (result.score != null && result.movements != null) {
              s.setCurrentScoreIdAndRevision(
                  result.score!.id, result.score!.rev);
              l.setScoreId(result.score!.id);
              await s.getScore(result.score!.id);
              // Add to recently accessed
              final LibraryItem libraryItem =
                  LibraryItem.fromScore(result.score!);
              l.addToRecentlyAccessed(libraryItem);
              await p.loadNewSession(
                  result.score!, result.movements!, session.type);
            }

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    backgroundColor: greenColor,
                    content:
                        Text('Session loaded successfully, ${session.name}')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load session: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);
    final s = Provider.of<ScoreProvider>(context);
    final n = Provider.of<NavigationProvider>(context);
    final l = Provider.of<LibraryProvider>(context);

    return Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.keyO):
              const OpenSessionDialogIntent(),
        },
        child: Actions(
          actions: {
            OpenSessionDialogIntent: CallbackAction<OpenSessionDialogIntent>(
              onInvoke: (OpenSessionDialogIntent intent) {
                _showSaveSessionDialog(context, p, s, l);
                return null;
              },
            ),
          },
          child: Focus(
            // Add Focus widget to capture keyboard events
            // autofocus: true,
            child: Stack(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //RIGHT SIDE, MODES and section tempos
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: paddingMd),
                                  child: OnePedalMode(p: p),
                                ),
                                if (n.isPerformanceScreen &&
                                    p.areAllTempoRangesEqual)
                                  AllSectionsTempoSwitch(p: p),
                                IconButton(
                                  tooltip: "Save/Load session",
                                  icon: Icon(Icons.settings),
                                  onPressed: () =>
                                      _showSaveSessionDialog(context, p, s, l),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 26,
                            ),
                            if (p.currentSection != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0),
                                child:
                                    SectionTempos(section: p.currentSection!),
                              ),
                          ],
                        ),
                      ),
                      //Separator
                      SizedBox(
                        width: separatorWidth,
                      ),

                      //SECTIOn VOLUME, RIGHT SIDE, PLAYER CONTROLS
                      Expanded(
                        child: Column(
                          children: [
                            Opacity(
                                opacity:
                                    p.appState == AppState.loading ? 0.5 : 1,
                                child: const PlayerControl()),
                          ],
                        ),
                      )
                    ]),
                Align(
                  child: SectionVolume(
                      section: p.currentSection!,
                      sectionVolume:
                          p.currentSection!.sectionVolume ?? p.playerVolume),
                ),
              ],
            ),
          ),
        ));
  }
}
