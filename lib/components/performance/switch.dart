import 'package:flutter/cupertino.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';

class AutoSwitch extends StatelessWidget {
  const AutoSwitch(
      {super.key,
      required this.p,
      required this.onToggle,
      required this.value,
      this.isLarge = false,
      required this.label,
      required this.opacity,
      this.scale = 0.5,
      this.spacing = 0});

  final PlaylistProvider p;
  final void Function(bool value) onToggle;
  final bool value;
  final bool isLarge;
  final String label;
  final double opacity;
  final double scale;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Wrap(
          spacing: spacing,
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              label,
              style: !isLarge ? TextStyles().textSm : TextStyles().textMd,
            ),
            Transform.scale(
              scale: !isLarge ? scale : 0.7,
              child: CupertinoSwitch(
                activeColor: p.setColor(),
                value: value,
                onChanged: (value) {
                  onToggle(value);
                },
              ),
            ),
          ]),
    );
  }
}
