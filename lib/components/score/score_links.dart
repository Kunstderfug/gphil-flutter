import 'package:flutter/material.dart';
import 'package:gphil/theme/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ScoreLinks extends StatelessWidget {
  final String? fullScoreUrl;
  final String? pianoScoreUrl;

  const ScoreLinks({
    super.key,
    this.fullScoreUrl,
    this.pianoScoreUrl,
  });

  Future<void> openUrl(String url) async {
    if (await launchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        fullScoreUrl != null
            ? TextButton(
                onPressed: () => openUrl(fullScoreUrl ?? ''),
                child: Text('Full Score',
                    style: TextStyle(
                      fontSize: fontSizeSm,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    )),
              )
            : const Text(''),
        const SizedBox(width: 16),
        const Text('|'),
        const SizedBox(width: 16),
        pianoScoreUrl != null
            ? TextButton(
                onPressed: () => openUrl(pianoScoreUrl ?? ''),
                child: Text('Piano Score',
                    style: TextStyle(
                      fontSize: fontSizeSm,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    )),
              )
            : const Text(''),
      ],
    );
  }
}
