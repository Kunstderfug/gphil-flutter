import 'package:flutter/cupertino.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';

class AutoSwitch extends StatelessWidget {
  const AutoSwitch({
    super.key,
    required this.p,
    required this.onToggle,
    required this.value,
    required this.label,
    required this.opacity,
  });

  final PlaylistProvider p;
  final void Function(bool value) onToggle;
  final bool value;
  final String label;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Opacity(
        opacity: opacity,
        child: Wrap(
            spacing: 8,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                label,
                style: TextStyles().textSm,
              ),
              Transform.scale(
                scale: isTablet(context) ? 1 : 0.6,
                child: CupertinoSwitch(
                  activeColor: highlightColor,
                  value: value,
                  onChanged: (value) {
                    onToggle(value);
                  },
                ),
              ),
            ]),
      ),
    );
  }
}
