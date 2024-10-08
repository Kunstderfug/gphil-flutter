import 'package:flutter/material.dart';
import 'package:gphil/components/social_buttons.dart';

Widget footer = Positioned(
  bottom: 0,
  left: 0,
  child: SizedBox(
    width: 360,
    height: 30,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.start,
        // spacing: sizeXs,
        // runSpacing: sizeXs,
        crossAxisAlignment: WrapCrossAlignment.start,
        direction: Axis.horizontal,
        children: socialButtons,
      ),
    ),
  ),
);
