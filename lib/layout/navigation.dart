import 'package:flutter/material.dart';
import 'package:gphil/providers/navigation_provider.dart';
// import 'package:gphil/theme/constants.dart';
// import 'package:gphil/theme/dark_mode.dart';
import 'package:gphil/layout/navigation_item.dart';
import 'package:gphil/services/app_update_service.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';
import 'package:gphil/services/sanity_service.dart';

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
    return Consumer(builder: (context, AppUpdateService a, child) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppUpdateCol1(a: a),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppCurrentVersion(buildNumber: a.currentVersion),
            ),
          ]);
    });
  }
}

class AppUpdateCol1 extends StatelessWidget {
  const AppUpdateCol1({super.key, required this.a});
  final AppUpdateService a;

  @override
  Widget build(BuildContext context) {
    return a.loading == true && a.updateAvailable == false
        ? const Text('Checking for updates')
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: a.updateAvailable
                ? Column(
                    children: [
                      Text('Update is available', style: TextStyles().textMd),
                      Text('Version: ${a.onlineVersion}'),
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
                                    decorationStyle: TextDecorationStyle.solid,
                                    decorationThickness: 2,
                                  )),
                              for (final String change
                                  in a.appVersionInfo?.changes ?? [])
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(change),
                                ),
                              const SizedBox(height: 16),
                            ]),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                            onPressed: () {
                              a.progress == null
                                  ? a.updateApp().then((filePath) {
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
                                  : a.cancelUpdate();
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                greenColor,
                              ),
                              foregroundColor: const WidgetStatePropertyAll(
                                Colors.white,
                              ),
                            ),
                            child: a.progress == null
                                ? const Text('Download update')
                                : const Text('Cancel update')),
                      ),
                      const SizedBox(height: 16),
                      if (a.progress != null)
                        Text('Downloaded ${a.progress?.toStringAsFixed(0)} MB',
                            style: TextStyles().textMd),
                      if (a.updateDownloaded)
                        Text('File downloaded!', style: TextStyles().textMd),
                      if (a.updateAbortedByUser)
                        Text('Update aborted', style: TextStyles().textMd),
                      const SizedBox(height: 16),
                    ],
                  )
                : const SizedBox.shrink(),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [const Text('GPhil Project'), Text('Version: $buildNumber')],
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
