import 'package:flutter/material.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/services/app_update_service.dart';
import 'package:provider/provider.dart';

AppUpdateService au(BuildContext context) =>
    Provider.of<AppUpdateService>(context);
AppConnection ac(BuildContext context) => Provider.of<AppConnection>(context);
NavigationProvider n(BuildContext context) =>
    Provider.of<NavigationProvider>(context);
ThemeProvider t(BuildContext context) => Provider.of<ThemeProvider>(context);
LibraryProvider l(BuildContext context) =>
    Provider.of<LibraryProvider>(context);
ScoreProvider s(BuildContext context) => Provider.of<ScoreProvider>(context);
PlaylistProvider p(BuildContext context) =>
    Provider.of<PlaylistProvider>(context);
