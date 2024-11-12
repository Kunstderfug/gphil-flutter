import 'package:flutter/material.dart';
import 'package:gphil/components/standart_button.dart';
import 'package:gphil/providers/navigation_provider.dart';
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
      setState(() {
        _errorText = 'A session with this name already exists';
      });
      return;
    }

    if (widget.onSave != null) widget.onSave!(name, _selectedType);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Color color(SessionType type) {
    return type == SessionType.practice ? greenColor : redColor;
  }

  Widget _buildSessionList() {
    final n = Provider.of<NavigationProvider>(context);

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
          if (!n.isPerformanceScreen)
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
              Expanded(
                child: InkWell(
                  onTap: () {
                    widget.onLoad(session);
                    widget.scoreName != null
                        ? Navigator.of(context).pop()
                        : n.setNavigationIndex(1);
                  },
                  child: Row(
                    children: [
                      Text(session.name, style: TextStyles().textMd),
                      const SizedBox(width: paddingSm),
                      Chip(
                        label: Text(
                          session.type.displayName,
                          style: TextStyles()
                              .textSm
                              .copyWith(color: color(session.type)),
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: BorderSide(color: color(session.type)),
                      ),
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
              IconButton(
                tooltip: 'Load Session',
                icon: const Icon(Icons.play_arrow),
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
                icon: const Icon(Icons.delete),
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
              if (widget.scoreName != null && _nameController.text.isNotEmpty) {
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
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
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
                    TextField(
                      showCursor: true,
                      // cursorColor: Colors.white,
                      selectionControls: DesktopTextSelectionControls(),
                      controller: _nameController,
                      style: TextStyles().textMd,
                      decoration: InputDecoration(
                        hoverColor: highlightColor,
                        fillColor: highlightColor,
                        focusColor: greenColor,
                        labelText: 'New Session Name',
                        floatingLabelStyle: TextStyles().textMd,
                        errorText: _errorText,
                        border: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(width: 1, color: greenColor),
                        ),
                      ),
                      autofocus: true,
                    ),
                  if (widget.scoreName != null)
                    const SizedBox(height: paddingLg),
                  if (widget.scoreName != null)
                    Row(
                      children: [
                        Text('Session Type:', style: TextStyles().textMd),
                        const SizedBox(width: paddingMd),
                        ...SessionType.values.map((type) => Padding(
                              padding: const EdgeInsets.only(right: paddingMd),
                              child: ChipTheme(
                                data: ChipThemeData(
                                  selectedColor: Colors.transparent,
                                  checkmarkColor: color(type),
                                  side: _selectedType == type
                                      ? BorderSide(color: color(type))
                                      : BorderSide(
                                          color: Colors.grey.withOpacity(0.2)),
                                  backgroundColor: Colors.transparent,
                                  showCheckmark: true,
                                  labelStyle: TextStyles()
                                      .textSm
                                      .copyWith(color: Colors.white),
                                  brightness: Brightness.dark,
                                ),
                                child: FilterChip(
                                  selected: _selectedType == type,
                                  label: Text(
                                    type.displayName,
                                    style: TextStyles()
                                        .textSm
                                        .copyWith(color: Colors.white),
                                  ),
                                  tooltip:
                                      'When loaded, will set session to the ${type == SessionType.practice ? 'practice (default)' : 'performance'} mode',
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedType = type;
                                    });
                                  },
                                ),
                              ),
                            )),
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
                          borderColor: redColor,
                          callback: () => Navigator.of(context).pop(),
                          label: 'Cancel',
                        ),
                        const SizedBox(width: paddingMd),
                        StandartButton(
                          icon: Icons.save,
                          iconColor: greenColor,
                          borderColor: greenColor,
                          callback: _validateAndSave,
                          label: 'Save New',
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
