// Widget tests for ParamsTab.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_enums.dart';
import 'package:codeops/providers/courier_ui_providers.dart';
import 'package:codeops/widgets/courier/key_value_editor.dart';
import 'package:codeops/widgets/courier/params_tab.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget buildParamsTab({
  List<Override> overrides = const [],
  String url = 'https://api.example.com/users',
  List<KeyValuePair> initialParams = const [],
}) {
  return ProviderScope(
    overrides: [
      activeRequestStateProvider.overrideWith(
        (ref) => RequestEditNotifier()
          ..load(RequestEditState(
            method: CourierHttpMethod.get,
            url: url,
          )),
      ),
      requestParamsProvider.overrideWith((ref) => initialParams),
      pathVariablesProvider.overrideWith((ref) => {}),
      ...overrides,
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: ParamsTab(),
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
  group('ParamsTab', () {
    testWidgets('renders with KeyValueEditor', (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildParamsTab());
      await tester.pumpAndSettle();

      expect(find.byType(ParamsTab), findsOneWidget);
      expect(find.byKey(const Key('params_editor')), findsOneWidget);
    });

    testWidgets('shows path variables section for URL with :param',
        (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildParamsTab(
        url: 'https://api.example.com/users/:userId/posts/:postId',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Path Variables'), findsOneWidget);
      expect(find.text(':userId'), findsOneWidget);
      expect(find.text(':postId'), findsOneWidget);
    });

    testWidgets('shows path variables section for URL with {param}',
        (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildParamsTab(
        url: 'https://api.example.com/users/{userId}',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Path Variables'), findsOneWidget);
      expect(find.text(':userId'), findsOneWidget);
    });

    testWidgets('hides path variables section when URL has no params',
        (tester) async {
      setSize(tester);
      await tester.pumpWidget(buildParamsTab(
        url: 'https://api.example.com/users',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Path Variables'), findsNothing);
    });

    testWidgets('displays existing params', (tester) async {
      setSize(tester);
      final params = [
        const KeyValuePair(id: '1', key: 'page', value: '1'),
        const KeyValuePair(id: '2', key: 'size', value: '20'),
      ];
      await tester.pumpWidget(buildParamsTab(initialParams: params));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'page'), findsOneWidget);
      expect(find.widgetWithText(TextField, '1'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'size'), findsOneWidget);
      expect(find.widgetWithText(TextField, '20'), findsOneWidget);
    });
  });
}
