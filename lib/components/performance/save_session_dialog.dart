import 'package:flutter/material.dart';
import 'package:gphil/components/standart_button.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/services/session_service.dart';
import 'package:gphil/theme/constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class SaveSessionIntent extends Intent {
  const SaveSessionIntent();
}

class SaveLoadSessionDialog extends StatefulWidget {
  final Function(String, SessionType)? onSave;
  final Function(UserSession) onLoad;
  final SessionService sessionService;
  final String? scoreName;
  final List<int>? movementIndices;

  const SaveLoadSessionDialog({
    super.key,
    this.onSave,
    required this.onLoad,
    required this.sessionService,
    this.scoreName,
    this.movementIndices,
  });

  @override
  State<SaveLoadSessionDialog> createState() => _SaveLoadSessionDialogState();
}

class _SaveLoadSessionDialogState extends State<SaveLoadSessionDialog> {
  final TextEditingController _nameController = TextEditingController();
  String? _errorText;
  List<UserSession> _sessions = [];
  bool _isLoading = true;
  SessionType _selectedType = SessionType.practice;

  @override
  void initState() {
    super.initState();
    // Format movement indices
    if (widget.movementIndices != null && widget.scoreName != null) {
      final movementText = '(Mov. ${widget.movementIndices!.join(', ')})';
      _nameController.text = '${widget.scoreName}_$movementText';
    }

    // Get PlaylistProvider and set initial session type
    final p = Provider.of<PlaylistProvider>(context, listen: false);
    _selectedType =
        p.performanceMode ? SessionType.performance : SessionType.practice;

    // Select all text
    _nameController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _nameController.text.length,
    );
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final sessions = await widget.sessionService.getSessions();
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _validateAndSave() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorText = 'Please enter a session name';
      });
      return;
    }

    if (_sessions.any(
        (session) => session.name == name && session.type == _selectedType)) {
      // Show confirmation dialog
      final shouldOverwrite = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Overwrite Session?'),
            content: Text(
                'A session named "$name" already exists. Do you want to overwrite it?'),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Overwrite'),
              ),
            ],
          );
        },
      );

      if (shouldOverwrite != true) {
        return; // User cancelled or pressed No
      }
    }

    if (widget.onSave != null) widget.onSave!(name, _selectedType);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Color _typeColor(SessionType type) {
    return type == SessionType.practice ? greenColor : redColor;
  }

  Widget _buildSessionList() {
    final n = Provider.of<NavigationProvider>(context);
    final p = Provider.of<PlaylistProvider>(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sessions.isEmpty) {
      return Column(
        children: [
          Text(
            'No saved sessions',
            style: TextStyles().textMd,
          ),
          const SizedBox(height: sizeLg),
          if (p.playlist.isEmpty)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('1. Select a score from the library'),
                      SizedBox(height: 16),
                      Text('2. Add movement/movements to the playlist'),
                      SizedBox(height: 16),
                      Text('3. Press Start Session'),
                      SizedBox(height: 16),
                    ]),
                const SizedBox(width: 300, child: SeparatorLine()),
                const SizedBox(height: sizeLg),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: paddingLg, vertical: paddingSm),
                    child: Text('back to Library'),
                  ),
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(highlightColor),
                    foregroundColor: WidgetStatePropertyAll(Colors.white70),
                  ),
                  onPressed: () => n.setNavigationIndex(0),
                )
              ],
            ),
        ],
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        final formattedDate =
            DateFormat('MMM d, y HH:mm').format(session.timestamp);

        return ListTile(
          title: Row(
            children: [
              //Session name and date
              Expanded(
                child: InkWell(
                  hoverColor: Colors.transparent,
                  onTap: () {
                    widget.onLoad(session);
                    widget.scoreName != null
                        ? Navigator.of(context).pop()
                        : n.setNavigationIndex(1);
                  },
                  child: Row(
                    children: [
                      Text(session.name, style: TextStyles().textMd),
                      // const SizedBox(width: paddingSm),
                    ],
                  ),
                ),
              ),
            ],
          ),
          subtitle: Text(formattedDate, style: TextStyles().textSm),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              //Session type
              Chip(
                label: Text(
                  session.type.displayName,
                  style: TextStyles()
                      .textSm
                      .copyWith(color: _typeColor(session.type)),
                ),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(color: _typeColor(session.type)),
              ),
              SizedBox(width: paddingSm),
              IconButton(
                iconSize: sizeLg,
                tooltip: 'Load Session',
                icon: const Icon(
                  Icons.play_arrow_outlined,
                ),
                color: greenColor,
                onPressed: () {
                  widget.onLoad(session);
                  widget.scoreName != null
                      ? Navigator.of(context).pop()
                      : n.setNavigationIndex(1);
                },
              ),
              IconButton(
                tooltip: 'Delete Session',
                icon: const Icon(
                  Icons.delete_outline_rounded,
                ),
                color: redColor,
                onPressed: () async {
                  final formattedDate =
                      DateFormat('MMM d, y HH:mm').format(session.timestamp);
                  final sessionName =
                      '${session.name}_$formattedDate'.replaceAll(
                    RegExp(r'[/\\<>:"|?*\s]'),
                    '_',
                  );
                  await widget.sessionService
                      .deleteSession(sessionName, session.type);
                  _loadSessions();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget sessions() {
    return Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.enter): const SaveSessionIntent(),
        },
        child: Actions(
            actions: {
              SaveSessionIntent: CallbackAction<SaveSessionIntent>(
                onInvoke: (SaveSessionIntent intent) {
                  if (widget.scoreName != null &&
                      _nameController.text.isNotEmpty) {
                    _validateAndSave();
                  }
                  return null;
                },
              ),
            },
            child: DefaultSelectionStyle(
              cursorColor: greenColor,
              selectionColor: Colors.grey.shade600,
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 700, maxHeight: 800),
                child: Padding(
                  padding: const EdgeInsets.all(paddingLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: sizeXl),
                      Text(
                        'Sessions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: paddingMd),
                      Expanded(
                        child: _buildSessionList(),
                      ),
                      if (widget.scoreName != null)
                        const Divider(height: paddingLg),
                      if (widget.scoreName != null)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFF3F3F46)), // zinc-700
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'New Session Name',
                                style: TextStyle(
                                  color: Color(0xFFA1A1AA), // zinc-400
                                  fontSize: fontSizeMd,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                showCursor: true,
                                // initialValue: sessionName,
                                selectionControls:
                                    DesktopTextSelectionControls(),
                                controller: _nameController,
                                style:
                                    const TextStyle(color: Color(0xFFF4F4F5)),

                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  floatingLabelStyle: TextStyles().textMd,
                                  errorText: _errorText,
                                ),
                                autofocus: true,
                              ),
                            ],
                          ),
                        ),
                      if (widget.scoreName != null)
                        const SizedBox(height: paddingLg),
                      if (widget.scoreName != null)
                        Row(
                          children: [
                            const Text(
                              'Session Type:',
                              style: TextStyle(
                                color: Color(0xFFA1A1AA), // zinc-400
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: paddingMd),
                            ...SessionType.values.map(
                              (type) => Row(
                                children: [
                                  _SessionTypeButton(
                                    label: type.name,
                                    isSelected: type == _selectedType,
                                    activeColor: type == SessionType.practice
                                        ? Color(0xFF132E1A)
                                        : const Color(
                                            0xFF451524), // green-950/50
                                    activeBorderColor: type ==
                                            SessionType.practice
                                        ? const Color(0xFF22C55E)
                                        : const Color(0xFFF87171), // green-400
                                    activeTextColor: type ==
                                            SessionType.practice
                                        ? const Color(0xFF22C55E)
                                        : const Color(0xFFF87171), // green-400
                                    onTap: () => setState(() {
                                      _selectedType = type;
                                    }),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: paddingLg),
                      if (widget.scoreName != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            StandartButton(
                              icon: Icons.close,
                              iconColor: redColor,
                              label: 'Cancel',
                              borderColor: redColor, // red-400
                              callback: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: paddingMd),
                            StandartButton(
                              label: 'Save New',
                              icon: Icons.save,
                              iconColor: greenColor,
                              borderColor: greenColor,
                              callback: _validateAndSave,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return widget.scoreName != null
        ? Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 24,
            ),
            child: sessions(),
          )
        : Center(child: sessions());
  }
}

class _SessionTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final Color activeBorderColor;
  final Color activeTextColor;
  final VoidCallback onTap;

  const _SessionTypeButton({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.activeBorderColor,
    required this.activeTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected ? activeColor : const Color(0xFF27272A), // zinc-800
            border: Border.all(
              color: isSelected
                  ? activeBorderColor.withOpacity(0.3)
                  : const Color(0xFF3F3F46), // zinc-700
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? activeTextColor
                  : const Color(0xFFA1A1AA), // zinc-400
            ),
          ),
        ),
      ),
    );
  }
}
