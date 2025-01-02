import 'package:flutter/material.dart';
import 'package:gphil/components/performance/switch.dart';
import 'package:gphil/components/performance/tooltip_toggle.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class SectionManagementState {
  final bool performanceMode;
  final Section? currentSection;
  final String? currentSectionKey;

  const SectionManagementState({
    required this.performanceMode,
    required this.currentSection,
    required this.currentSectionKey,
  });

  bool get isSectionMuted => currentSection?.muted ?? false;
  bool get isSectionLooped => currentSection?.looped ?? false;
  bool get hasAutoContinueMarker => currentSection?.autoContinueMarker != null;
  bool get isAutoContinueEnabled =>
      hasAutoContinueMarker &&
      currentSection?.autoContinue != null &&
      currentSection!.autoContinue!;
}

class SectionManagement extends StatelessWidget {
  const SectionManagement({super.key});

  static const int items = 3;
  static const double opacity = 0.4;

  Widget _buildSkipSwitch(BuildContext context, SectionManagementState state) {
    return TooltipToggle(
      message:
          'If enabled, will skip this section in Practice mode.\n Will be ignored in Performance mode.\nKeyboard shortcut [S]',
      child: AutoSwitch(
        onToggle: (value) => !state.performanceMode
            ? Provider.of<PlaylistProvider>(context, listen: false)
                .toggleSectionSkipped(state.currentSectionKey!)
            : null,
        label: 'Section skipped',
        value: state.isSectionMuted,
        opacity: !state.performanceMode ? 1 : opacity,
      ),
    );
  }

  Widget _buildLoopSwitch(BuildContext context, SectionManagementState state) {
    return TooltipToggle(
      message:
          'If enabled, section will repeatedly play in Practice Mode.\nWhen Performance Mode is enabled, this setting will be ignored.\nKeyboard shortcut [L]',
      child: AutoSwitch(
        onToggle: (value) => !state.performanceMode
            ? Provider.of<PlaylistProvider>(context, listen: false)
                .toggleSectionLooped()
            : null,
        label: 'Section looped',
        value: state.isSectionLooped,
        opacity: !state.performanceMode ? 1 : opacity,
      ),
    );
  }

  Widget _buildAutoContinueSwitch(
      BuildContext context, SectionManagementState state) {
    return TooltipToggle(
      message:
          'Set current section auto-continue on/off.\nKeyboard shortcut [A]',
      child: AutoSwitch(
        onToggle: (value) => state.currentSection?.autoContinue != null
            ? Provider.of<PlaylistProvider>(context, listen: false)
                .setCurrentSectionAutoContinue()
            : null,
        label: 'Section auto-continue',
        value: state.isAutoContinueEnabled,
        opacity: state.hasAutoContinueMarker ? 1 : opacity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistProvider, SectionManagementState>(
      selector: (_, provider) => SectionManagementState(
        performanceMode: provider.performanceMode,
        currentSection: provider.currentSection,
        currentSectionKey: provider.currentSectionKey,
      ),
      builder: (context, state, _) {
        return Padding(
          padding: const EdgeInsets.only(left: paddingMd),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSkipSwitch(context, state),
              _buildLoopSwitch(context, state),
              _buildAutoContinueSwitch(context, state),
            ],
          ),
        );
      },
    );
  }
}
