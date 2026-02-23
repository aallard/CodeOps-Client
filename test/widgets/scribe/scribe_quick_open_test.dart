// Tests for ScribeQuickOpen overlay widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/theme/app_theme.dart';
import 'package:codeops/widgets/scribe/scribe_quick_open.dart';

void main() {
  final testItems = [
    const QuickOpenItem(
      title: 'main.dart',
      subtitle: 'lib/main.dart',
      id: 'tab-1',
      isOpenTab: true,
    ),
    const QuickOpenItem(
      title: 'config.yaml',
      subtitle: '/home/user/config.yaml',
      id: '/home/user/config.yaml',
      isOpenTab: false,
    ),
    const QuickOpenItem(
      title: 'test_utils.dart',
      subtitle: 'test/test_utils.dart',
      id: 'tab-3',
      isOpenTab: true,
    ),
  ];

  Widget createWidget({
    List<QuickOpenItem>? items,
    ValueChanged<QuickOpenItem>? onSelect,
    VoidCallback? onClose,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: ScribeQuickOpen(
          items: items ?? testItems,
          onSelect: onSelect ?? (_) {},
          onClose: onClose ?? () {},
        ),
      ),
    );
  }

  group('ScribeQuickOpen', () {
    testWidgets('renders search field with placeholder', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Type to search files...'), findsOneWidget);
    });

    testWidgets('renders all items initially', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('main.dart'), findsOneWidget);
      expect(find.text('config.yaml'), findsOneWidget);
      expect(find.text('test_utils.dart'), findsOneWidget);
    });

    testWidgets('shows Open badge for open tabs', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Two items are open tabs, so we expect "Open" badges.
      expect(find.text('Open'), findsNWidgets(2));
    });

    testWidgets('shows subtitles', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('lib/main.dart'), findsOneWidget);
      expect(find.text('/home/user/config.yaml'), findsOneWidget);
    });

    testWidgets('shows no results message when nothing matches',
        (tester) async {
      await tester.pumpWidget(createWidget(items: []));
      await tester.pumpAndSettle();

      expect(find.text('No matching files'), findsOneWidget);
    });

    testWidgets('has tab and file icons', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Open tabs get tab icon, file gets description icon.
      expect(find.byIcon(Icons.tab), findsNWidgets(2));
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });
  });
}
