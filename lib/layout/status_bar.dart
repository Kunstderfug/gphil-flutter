import 'package:flutter/material.dart';
// import 'package:gphil/providers/library_provider.dart';
// import 'package:gphil/providers/navigation_provider.dart';
// import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/services/app_state.dart';
// import 'package:gphil/services/app_update_service.dart';
// import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  final int itemCount = 4;

  @override
  Widget build(BuildContext context) {
    // final n = Provider.of<NavigationProvider>(context);
    // final l = Provider.of<LibraryProvider>(context);
    final s = Provider.of<ScoreProvider>(context);
    // final p = Provider.of<PlaylistProvider>(context);
    // final au = Provider.of<AppUpdateService>(context);
    final ac = Provider.of<AppConnection>(context);

    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width / itemCount,
                child:
                    StatusBarItem(text: 'App status', value: ac.appState.name)),
            SizedBox(
              width: MediaQuery.of(context).size.width / itemCount,
              child: StatusBarItem(
                  text: 'Current score',
                  value: s.currentScore != null
                      ? '${s.currentScore!.shortTitle} - ${s.currentScore!.composer}'
                      : 'Not selected'),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width / itemCount,
                child: const StatusBarItem(
                    text: 'Current section and tempo', value: '')),
          ],
        ),
      ),
    );
  }
}

class StatusBarItem extends StatelessWidget {
  const StatusBarItem({
    super.key,
    required this.text,
    required this.value,
    this.icon,
  });

  final String text;
  final String value;
  final IconData? icon;

  final TextStyle textStyle = const TextStyle(
    color: Colors.white,
    fontSize: 12,
    // fontWeight: FontWeight.w100,
  );

  @override
  Widget build(BuildContext context) {
    return Text('$text: $value', style: textStyle);
  }
}
