import 'package:flutter/material.dart';
import 'package:gphil/components/social_button.dart';
import 'package:gphil/providers/navigation_provider.dart';
// import 'package:gphil/theme/constants.dart';
// import 'package:gphil/theme/dark_mode.dart';
import 'package:gphil/layout/navigation_item.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/services/app_update_service.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';
import 'package:gphil/services/sanity_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Navigation extends StatelessWidget {
  const Navigation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Nav()),
          Flexible(flex: 1, child: AppUpdate()),
        ]);
  }
}

class AppUpdate extends StatelessWidget {
  const AppUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppUpdateService(),
      child: const AppUpdateProgress(),
    );
  }
}

class AppUpdateProgress extends StatelessWidget {
  const AppUpdateProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final au = Provider.of<AppUpdateService>(context);
    final ac = Provider.of<AppConnection>(context);
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      AppUpdateCol1(au: au, ac: ac),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: AppCurrentVersion(buildNumber: au.currentVersion),
      ),
    ]);
  }
}

class AppUpdateCol1 extends StatelessWidget {
  const AppUpdateCol1({super.key, required this.au, required this.ac});
  final AppUpdateService au;
  final AppConnection ac;

  @override
  Widget build(BuildContext context) {
    return ac.appState == AppState.offline
        ? Column(
            children: [
              Text('App is offline',
                  textAlign: TextAlign.center, style: TextStyles().textLg),
              const Text('Check your internet connection')
            ],
          )
        : au.appState == AppState.connecting
            ? const Text('Checking for updates')
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: au.updateAvailable
                    ? Column(
                        children: [
                          Text('Update is available',
                              style: TextStyles().textMd),
                          Text('Version: ${au.onlineVersion}'),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Release notes:',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        decoration: TextDecoration.underline,
                                        decorationStyle:
                                            TextDecorationStyle.solid,
                                        decorationThickness: 2,
                                      )),
                                  for (final String change
                                      in au.appVersionInfo?.changes ?? [])
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(change),
                                    ),
                                  const SizedBox(height: 16),
                                ]),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: !au.updateDownloaded
                                ? TextButton.icon(
                                    icon: const Icon(Icons.download_rounded),
                                    onPressed: () {
                                      au.progress == null
                                          ? au.updateApp().then((filePath) {
                                              if (filePath != null) {
                                                // ignore: use_build_context_synchronously
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'File downloaded to: $filePath')),
                                                );
                                              }
                                            })
                                          : au.cancelUpdate();
                                    },
                                    style: ButtonStyle(
                                      iconColor:
                                          WidgetStatePropertyAll(greenColor),
                                      side: WidgetStatePropertyAll(
                                        BorderSide(
                                          color: greenColor,
                                        ),
                                      ),
                                      backgroundColor: WidgetStateProperty
                                          .resolveWith<Color?>(
                                        (Set<WidgetState> states) {
                                          if (states
                                              .contains(WidgetState.hovered)) {
                                            return greenColor.withOpacity(
                                                0.2); // Set the background color on hover
                                          }
                                          return null; // Use the default button background color
                                        },
                                      ),
                                      foregroundColor:
                                          const WidgetStatePropertyAll(
                                        Colors.white,
                                      ),
                                    ),
                                    label: au.progress == null
                                        ? const Text('Download update')
                                        : const Text('Cancel update'))
                                : const SizedBox(),
                          ),
                          const SizedBox(height: 16),
                          if (au.progress != null)
                            Text(
                                'Downloaded ${au.progress?.toStringAsFixed(0)} MB',
                                style: TextStyles().textMd),
                          if (au.updateDownloaded)
                            Column(
                              children: [
                                Text('File downloaded!',
                                    textAlign: TextAlign.center,
                                    style: TextStyles().textMd),
                                Text(
                                  'Launch the installer from ${au.downloadPath}. Then restart the app.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w200,
                                  ),
                                )
                              ],
                            ),
                          if (au.updateAbortedByUser)
                            Text('Update aborted', style: TextStyles().textMd),
                          const SizedBox(height: 16),
                        ],
                      )
                    : const Text('App is online and up to date'),
              );
  }
}

class Nav extends StatelessWidget {
  const Nav({super.key});

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context);
    final nScreens = n.navigationScreens;
    return Column(children: [
      //logo
      SizedBox(
        height: 145,
        child: DrawerHeader(
            child: Center(
          child: ClipOval(
            child: Image.asset(
              'assets/images/gphil_icon.png',
              width: 100,
              height: 100,
            ),
          ),
        )),
      ),

      //NAVIGATION
      ...nScreens.getRange(0, 2).map((screen) => NavigationItem(
            title: screen['title'] as String,
            icon: screen['icon'] as IconData,
            index: nScreens.indexOf(screen),
          )),

      //DARK MODE
      // const Padding(
      //   padding:
      //       EdgeInsets.symmetric(horizontal: paddingMd, vertical: paddingXs),
      //   child: DarkModeSlider(),
      // ),
    ]);
  }
}

class AppCurrentVersion extends StatelessWidget {
  const AppCurrentVersion({super.key, required this.buildNumber});
  final String buildNumber;

  void callback(String url) async {
    await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SocialButton(
            label: 'Support Project',
            icon: Icons.favorite,
            url: 'https://donate.stripe.com/eVa7tYccjd0a8488ww',
            iconColor: highlightColor,
            borderColor: highlightColor),
        const SizedBox(height: 16),
        SocialButton(
            label: 'Feedback',
            icon: Icons.discord,
            url: 'https://discord.gg/Gkn2jKk6VR',
            iconColor: Colors.blue.shade800,
            borderColor: greenColor),
        const SizedBox(height: 16),
        SocialButton(
            label: 'Report a bug',
            icon: Icons.bug_report,
            url: 'https://discord.gg/DMDvB6NFJu',
            iconColor: Colors.red.shade900,
            borderColor: Colors.red.shade900),
        const SeparatorLine(),
        const Text('GPhil Project'),
        Text('Version: $buildNumber'),
      ],
    );
  }
}

class AppUpdateInfo extends StatelessWidget {
  final AppVersionInfo appVersionInfo;
  const AppUpdateInfo({super.key, required this.appVersionInfo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(appVersionInfo.build),
      ],
    );
  }
}
