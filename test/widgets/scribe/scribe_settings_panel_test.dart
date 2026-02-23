// Tests for ScribeSettingsPanel.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:codeops/models/scribe_models.dart';
import 'package:codeops/providers/scribe_providers.dart';
import 'package:codeops/services/data/scribe_persistence_service.dart';
import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_settings_panel.dart';

class MockScribePersistenceService extends Mock
    implements ScribePersistenceService {}

void main() {
  late MockScribePersistenceService mockPersistence;

  setUpAll(() {
    registerFallbackValue(<ScribeTab>[]);
    registerFallbackValue(const ScribeSettings());
  });

  setUp(() {
    mockPersistence = MockScribePersistenceService();
    when(() => mockPersistence.saveTabs(any())).thenAnswer((_) async {});
    when(() => mockPersistence.saveSettings(any())).thenAnswer((_) async {});
    when(() => mockPersistence.loadTabs()).thenAnswer((_) async => []);
    when(() => mockPersistence.loadSettings())
        .thenAnswer((_) async => const ScribeSettings());
  });

  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [
        scribePersistenceProvider.overrideWithValue(mockPersistence),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  group('ScribeSettingsPanel', () {
    testWidgets('renders header with title and close button', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeSettingsPanel(onClose: () {}),
      ));

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders all three section headers', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeSettingsPanel(onClose: () {}),
      ));

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Editor'), findsOneWidget);
      expect(find.text('Auto-Save'), findsOneWidget);
    });

    testWidgets('renders all editor toggle labels', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeSettingsPanel(onClose: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Insert Spaces'), findsOneWidget);
      expect(find.text('Word Wrap'), findsOneWidget);
      expect(find.text('Line Numbers'), findsOneWidget);
      expect(find.text('Minimap'), findsOneWidget);
      expect(find.text('Highlight Active Line'), findsOneWidget);
      expect(find.text('Bracket Matching'), findsOneWidget);
      expect(find.text('Auto-Close Brackets'), findsOneWidget);
      expect(find.text('Show Whitespace'), findsOneWidget);
      expect(find.text('Scroll Beyond Last Line'), findsOneWidget);
    });

    testWidgets('renders theme, font family, and font size controls',
        (tester) async {
      await tester.pumpWidget(wrap(
        ScribeSettingsPanel(onClose: () {}),
      ));

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Font Family'), findsOneWidget);
      expect(find.text('Font Size'), findsOneWidget);
    });

    testWidgets('renders tab size control', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeSettingsPanel(onClose: () {}),
      ));

      expect(find.text('Tab Size'), findsOneWidget);
      // The segmented control shows 2, 4, 8.
      expect(find.text('2'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('renders reset to defaults button', (tester) async {
      await tester.pumpWidget(wrap(
        ScribeSettingsPanel(onClose: () {}),
      ));
      await tester.pumpAndSettle();

      // Scroll to bottom to reveal the Reset button.
      await tester.scrollUntilVisible(
        find.text('Reset to Defaults'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      expect(find.text('Reset to Defaults'), findsOneWidget);
    });

    testWidgets('close button fires onClose callback', (tester) async {
      var closed = false;

      await tester.pumpWidget(wrap(
        ScribeSettingsPanel(onClose: () => closed = true),
      ));

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
    });

    testWidgets('tapping Word Wrap toggle changes setting', (tester) async {
      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scribePersistenceProvider.overrideWithValue(mockPersistence),
          ],
          child: Builder(builder: (context) {
            return MaterialApp(
              theme: AppTheme.darkTheme,
              home: Consumer(builder: (ctx, ref, _) {
                container = ProviderScope.containerOf(ctx);
                return Scaffold(
                  body: ScribeSettingsPanel(onClose: () {}),
                );
              }),
            );
          }),
        ),
      );
      await tester.pumpAndSettle();

      // Initially false.
      expect(container.read(scribeSettingsProvider).wordWrap, isFalse);

      // Tap the Word Wrap row.
      await tester.tap(find.text('Word Wrap'));
      await tester.pumpAndSettle();

      expect(container.read(scribeSettingsProvider).wordWrap, isTrue);
    });

    testWidgets('tapping Light theme changes themeMode', (tester) async {
      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scribePersistenceProvider.overrideWithValue(mockPersistence),
          ],
          child: Builder(builder: (context) {
            return MaterialApp(
              theme: AppTheme.darkTheme,
              home: Consumer(builder: (ctx, ref, _) {
                container = ProviderScope.containerOf(ctx);
                return Scaffold(
                  body: ScribeSettingsPanel(onClose: () {}),
                );
              }),
            );
          }),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(scribeSettingsProvider).themeMode, 'dark');

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      expect(container.read(scribeSettingsProvider).themeMode, 'light');
    });

    testWidgets('auto-save interval slider not shown when autoSave off',
        (tester) async {
      await tester.pumpWidget(wrap(
        ScribeSettingsPanel(onClose: () {}),
      ));
      await tester.pumpAndSettle();

      // Auto-save is off by default, so interval row should not appear.
      expect(find.text('Interval'), findsNothing);
    });

    testWidgets('tapping Auto-Save shows interval slider', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scribePersistenceProvider.overrideWithValue(mockPersistence),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: ScribeSettingsPanel(onClose: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Interval'), findsNothing);

      // Scroll to make the Auto-Save toggle visible (use InkWell finder
      // to distinguish from the section header).
      final autoSaveToggle = find.widgetWithText(InkWell, 'Auto-Save');
      await tester.scrollUntilVisible(
        autoSaveToggle,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      await tester.tap(autoSaveToggle);
      await tester.pumpAndSettle();

      // Scroll again to reveal the Interval row.
      await tester.scrollUntilVisible(
        find.text('Interval'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      expect(find.text('Interval'), findsOneWidget);
    });
  });
}
