import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gphil/components/performance/save_session_dialog.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/models/score.dart';
import 'package:gphil/models/score_user_prefs.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/services/session_service.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

// Simple mock for SessionService
class MockSessionService implements SessionService {
  final List<UserSession> _sessions = [];

  @override
  Future<List<UserSession>> getSessions() async {
    return _sessions;
  }

  @override
  Future<void> deleteSession(String name, SessionType type) async {
    _sessions.removeWhere((s) => s.name == name && s.type == type);
  }

  void addSession(UserSession session) {
    _sessions.add(session);
  }

  @override
  Future<({List<Movement>? movements, Score? score})> loadSession(
      String name, SessionType type) {
    // TODO: implement loadSession
    throw UnimplementedError();
  }

  @override
  // TODO: implement pc
  PersistentDataController get pc => throw UnimplementedError();

  @override
  Future<({String? error, List<SectionPrefs>? prefs, String? scoreId})>
      readSessionPrefs(String name, SessionType type) {
    // TODO: implement readSessionPrefs
    throw UnimplementedError();
  }

  @override
  // TODO: implement s
  ScoreProvider get s => throw UnimplementedError();

  @override
  Future<void> saveSession(String name, String scoreId, SessionType type,
      List<Section> sections, PlaylistProvider p) {
    // TODO: implement saveSession
    throw UnimplementedError();
  }
}

void main() {
  late MockSessionService mockSessionService;

  setUp(() {
    mockSessionService = MockSessionService();
  });

  Widget createTestWidget({required Widget child}) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => NavigationProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => PlaylistProvider(),
          ),
        ],
        child: Material(child: child),
      ),
    );
  }

  testWidgets('Shows empty state when no sessions exist',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(
        child: SaveLoadSessionDialog(
          onLoad: (_) {},
          sessionService: mockSessionService,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('No saved sessions'), findsOneWidget);
  });

  testWidgets('Shows session input when scoreName is provided',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(
        child: SaveLoadSessionDialog(
          onLoad: (_) {},
          sessionService: mockSessionService,
          scoreName: 'Test Score',
          movementIndices: [1, 2],
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('New Session Name'), findsOneWidget);
    expect(find.text('Session Type:'), findsOneWidget);
  });

  testWidgets('Shows error when trying to save empty session name',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(
        child: SaveLoadSessionDialog(
          onLoad: (_) {},
          sessionService: mockSessionService,
          scoreName: 'Test Score',
          onSave: (_, __) {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Clear the text field
    await tester.enterText(find.byType(TextFormField), '');

    // Tap save button
    await tester.tap(find.text('Save New'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a session name'), findsOneWidget);
  });

  testWidgets('Session type buttons work correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(
        child: SaveLoadSessionDialog(
          onLoad: (_) {},
          sessionService: mockSessionService,
          scoreName: 'Test Score',
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify both session type buttons are present
    expect(find.text('practice'), findsOneWidget);
    expect(find.text('performance'), findsOneWidget);

    // Tap performance button
    await tester.tap(find.text('performance'));
    await tester.pumpAndSettle();

    // You could add more specific assertions here based on the visual state
  });

  testWidgets('Cancel button closes the dialog', (WidgetTester tester) async {
    bool dialogClosed = false;

    await tester.pumpWidget(
      createTestWidget(
        child: Builder(
          builder: (BuildContext context) {
            return TextButton(
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: (_) => SaveLoadSessionDialog(
                    onLoad: (_) {},
                    sessionService: mockSessionService,
                    scoreName: 'Test Score',
                  ),
                );
                dialogClosed = result == null;
              },
              child: const Text('Show Dialog'),
            );
          },
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Tap cancel button
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(dialogClosed, true);
  });
}
