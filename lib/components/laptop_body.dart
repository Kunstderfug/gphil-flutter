import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gphil/components/performance/floating_info.dart';
import 'package:gphil/components/performance/layers_error.dart';
import 'package:gphil/components/performance/main_area.dart';
import 'package:gphil/components/performance/mixer_info.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class LaptopBody extends StatelessWidget {
  const LaptopBody({super.key});

  @override
  Widget build(BuildContext context) {
    return MainArea();
  }
}
