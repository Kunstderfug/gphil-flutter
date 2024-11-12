import 'package:flutter/material.dart';
import 'package:gphil/components/performance/save_session_dialog.dart';
import 'package:gphil/models/library.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/services/session_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PlaylistIsEmpty extends StatelessWidget {
  const PlaylistIsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);
    final s = Provider.of<ScoreProvider>(context);
    final l = Provider.of<LibraryProvider>(context);

    return SaveLoadSessionDialog(
      sessionService: SessionService(s),
      onLoad: (UserSession session) async {
        p.isLoading = true;
        //TODO Handle loading the selected session
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
            s.setCurrentScoreIdAndRevision(result.score!.id, result.score!.rev);
            l.setScoreId(result.score!.id);
            await s.getScore(result.score!.id);
            // Add to recently accessed
            final LibraryItem libraryItem =
                LibraryItem.fromScore(result.score!);
            l.addToRecentlyAccessed(libraryItem);
            await p.loadNewSession(
                result.score!, result.movements!, session.type);
            //set mode to practice or performance
            if (session.type == SessionType.performance) {
              p.setPerformanceMode = true;
            }
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
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
    );
  }
}
