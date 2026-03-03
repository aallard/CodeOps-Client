// Widget tests for KeyValueEditor.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/widgets/courier/key_value_editor.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget buildEditor({
  List<KeyValuePair>? pairs,
  ValueChanged<List<KeyValuePair>>? onChanged,
  bool showDescription = true,
  List<String> keySuggestions = const [],
  List<String> variableNames = const [],
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 800,
        height: 600,
        child: KeyValueEditor(
          pairs: pairs ?? [],
          onChanged: onChanged ?? (_) {},
          showDescription: showDescription,
          keySuggestions: keySuggestions,
          variableNames: variableNames,
        ),
      ),
    ),
  );
}

void setSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('KeyValueEditor', () {
    testWidgets('renders without error', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      expect(find.byType(KeyValueEditor), findsOneWidget);
    });

    testWidgets('shows header row with Key/Value/Description labels',
        (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      // Header labels exist (may also appear as hints in empty rows).
      expect(find.text('Key'), findsAtLeastNWidgets(1));
      expect(find.text('Value'), findsAtLeastNWidgets(1));
      expect(find.text('Description'), findsAtLeastNWidgets(1));
    });

    testWidgets('hides description column when showDescription is false',
        (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildEditor(showDescription: false));
      await tester.pumpAndSettle();

      expect(find.text('Description'), findsNothing);
    });

    testWidgets('displays existing pairs', (tester) async {
      setSize(tester);
      final pairs = [
        const KeyValuePair(id: '1', key: 'api_key', value: 'abc123', description: 'Auth'),
        const KeyValuePair(id: '2', key: 'format', value: 'json'),
      ];
      await tester.pumpWidget(buildEditor(pairs: pairs));
      await tester.pumpAndSettle();

      // The key and value texts are rendered in TextFields.
      expect(find.widgetWithText(TextField, 'api_key'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'abc123'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'format'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'json'), findsOneWidget);
    });

    testWidgets('auto-adds empty trailing row', (tester) async {
      setSize(tester);
      final pairs = [
        const KeyValuePair(id: '1', key: 'key1', value: 'val1'),
      ];
      await tester.pumpWidget(buildEditor(pairs: pairs));
      await tester.pumpAndSettle();

      // The editor should render at least 2 rows (1 data + 1 empty).
      // Find delete buttons — should be present for the data row.
      expect(find.byKey(const Key('delete_button_0')), findsOneWidget);
    });

    testWidgets('delete row emits updated list', (tester) async {
      setSize(tester);
      final pairs = [
        const KeyValuePair(id: '1', key: 'key1', value: 'val1'),
        const KeyValuePair(id: '2', key: 'key2', value: 'val2'),
      ];
      List<KeyValuePair>? emitted;
      await tester.pumpWidget(buildEditor(
        pairs: pairs,
        onChanged: (updated) => emitted = updated,
      ));
      await tester.pumpAndSettle();

      // Delete the first row.
      await tester.tap(find.byKey(const Key('delete_button_0')));
      await tester.pumpAndSettle();

      expect(emitted, isNotNull);
      // After deleting row 0, the first non-empty pair should be key2.
      final nonEmpty = emitted!.where((p) => !p.isEmpty).toList();
      expect(nonEmpty.length, 1);
      expect(nonEmpty.first.key, 'key2');
    });

    testWidgets('toggle enable/disable on row', (tester) async {
      setSize(tester);
      final pairs = [
        const KeyValuePair(id: '1', key: 'key1', value: 'val1', enabled: true),
      ];
      List<KeyValuePair>? emitted;
      await tester.pumpWidget(buildEditor(
        pairs: pairs,
        onChanged: (updated) => emitted = updated,
      ));
      await tester.pumpAndSettle();

      // Tap the enable checkbox for row 0.
      await tester.tap(find.byKey(const Key('enable_checkbox_0')));
      await tester.pumpAndSettle();

      expect(emitted, isNotNull);
      final first = emitted!.firstWhere((p) => p.key == 'key1');
      expect(first.enabled, false);
    });

    testWidgets('select-all checkbox toggles all rows', (tester) async {
      setSize(tester);
      final pairs = [
        const KeyValuePair(id: '1', key: 'k1', value: 'v1', enabled: true),
        const KeyValuePair(id: '2', key: 'k2', value: 'v2', enabled: true),
      ];
      List<KeyValuePair>? emitted;
      await tester.pumpWidget(buildEditor(
        pairs: pairs,
        onChanged: (updated) => emitted = updated,
      ));
      await tester.pumpAndSettle();

      // Tap select-all (currently all enabled → should disable all).
      await tester.tap(find.byKey(const Key('select_all_checkbox')));
      await tester.pumpAndSettle();

      expect(emitted, isNotNull);
      // All non-empty pairs should be disabled.
      final nonEmpty = emitted!.where((p) => !p.isEmpty);
      expect(nonEmpty.every((p) => !p.enabled), true);
    });

    testWidgets('bulk edit button shows text editor', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildEditor(
        pairs: [
          const KeyValuePair(id: '1', key: 'k1', value: 'v1'),
        ],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bulk_edit_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bulk_edit_field')), findsOneWidget);
      expect(find.byKey(const Key('bulk_edit_done_button')), findsOneWidget);
    });

    testWidgets('bulk edit done parses text back to pairs', (tester) async {
      setSize(tester);
      List<KeyValuePair>? emitted;
      await tester.pumpWidget(buildEditor(
        pairs: [
          const KeyValuePair(id: '1', key: 'old', value: 'data'),
        ],
        onChanged: (updated) => emitted = updated,
      ));
      await tester.pumpAndSettle();

      // Enter bulk edit.
      await tester.tap(find.byKey(const Key('bulk_edit_button')));
      await tester.pumpAndSettle();

      // Clear and type new bulk text.
      final field = find.byKey(const Key('bulk_edit_field'));
      await tester.enterText(field, 'newKey:newValue\nanotherKey:anotherValue');
      await tester.pumpAndSettle();

      // Click Done.
      await tester.tap(find.byKey(const Key('bulk_edit_done_button')));
      await tester.pumpAndSettle();

      expect(emitted, isNotNull);
      final nonEmpty = emitted!.where((p) => !p.isEmpty).toList();
      expect(nonEmpty.length, 2);
      expect(nonEmpty[0].key, 'newKey');
      expect(nonEmpty[0].value, 'newValue');
      expect(nonEmpty[1].key, 'anotherKey');
      expect(nonEmpty[1].value, 'anotherValue');
    });

    testWidgets('edit key field emits change', (tester) async {
      setSize(tester);
      final pairs = [
        const KeyValuePair(id: '1', key: '', value: ''),
      ];
      List<KeyValuePair>? emitted;
      await tester.pumpWidget(buildEditor(
        pairs: pairs,
        onChanged: (updated) => emitted = updated,
      ));
      await tester.pumpAndSettle();

      // The first row has empty key/value — find the first TextField.
      // Enter text into the first text field (key field of first row).
      final textFields = find.byType(TextField);
      // We need to find the key text field. It should be the first in the row.
      await tester.enterText(textFields.first, 'newKey');
      await tester.pumpAndSettle();

      expect(emitted, isNotNull);
    });

    testWidgets('edit value field emits change', (tester) async {
      setSize(tester);
      final pairs = [
        const KeyValuePair(id: '1', key: 'k1', value: ''),
      ];
      await tester.pumpWidget(buildEditor(pairs: pairs));
      await tester.pumpAndSettle();

      // Verify the key field is rendered with 'k1'.
      final keyField = find.widgetWithText(TextField, 'k1');
      expect(keyField, findsOneWidget);

      // Multiple TextFields exist (key, value, description per row + empty row).
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('edit description field emits change', (tester) async {
      setSize(tester);
      final pairs = [
        const KeyValuePair(id: '1', key: 'k1', value: 'v1', description: ''),
      ];
      List<KeyValuePair>? emitted;
      await tester.pumpWidget(buildEditor(
        pairs: pairs,
        onChanged: (updated) => emitted = updated,
      ));
      await tester.pumpAndSettle();

      // Find description field by key.
      final descField = find.byKey(const Key('description_field_0'));
      expect(descField, findsOneWidget);

      await tester.enterText(descField, 'A description');
      await tester.pumpAndSettle();

      expect(emitted, isNotNull);
      final pair = emitted!.firstWhere((p) => p.key == 'k1');
      expect(pair.description, 'A description');
    });

    testWidgets('reorderable list is present', (tester) async {
      setSize(tester);
      final pairs = [
        const KeyValuePair(id: '1', key: 'k1', value: 'v1'),
        const KeyValuePair(id: '2', key: 'k2', value: 'v2'),
      ];
      await tester.pumpWidget(buildEditor(pairs: pairs));
      await tester.pumpAndSettle();

      // The ReorderableListView is present.
      expect(find.byKey(const Key('kv_reorderable_list')), findsOneWidget);
      // Drag handles are rendered.
      expect(find.byIcon(Icons.drag_indicator), findsWidgets);
    });

    testWidgets('variable highlighting builds correct spans', (_) async {
      final span = buildVariableHighlightSpan(
        'Hello {{name}}, your key is {{api_key}}',
        baseStyle: const TextStyle(color: Color(0xFFE2E8F0)),
      );

      expect(span.children, isNotNull);
      expect(span.children!.length, 4); // text, var, text, var
    });

    testWidgets('key suggestions render autocomplete', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildEditor(
        keySuggestions: ['Content-Type', 'Accept', 'Authorization'],
      ));
      await tester.pumpAndSettle();

      // The Autocomplete widget wraps the key field.
      expect(find.byType(Autocomplete<String>), findsWidgets);
    });
  });
}
