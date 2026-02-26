/// Tests for [RelayEmojiPicker] — curated emoji picker overlay.
///
/// Verifies grid rendering, recently used section, emoji selection
/// callback, close button behavior, and header content.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/providers/relay_providers.dart';
import 'package:codeops/widgets/relay/relay_emoji_picker.dart';

Widget _createPicker({
  required ValueChanged<String> onEmojiSelected,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: RelayEmojiPicker(onEmojiSelected: onEmojiSelected),
              ),
            ),
            child: const Text('Open Picker'),
          ),
        ),
      ),
    ),
  );
}

/// Opens the picker by tapping the trigger button.
Future<void> _openPicker(WidgetTester tester,
    {required ValueChanged<String> onEmojiSelected,
    List<Override> overrides = const []}) async {
  await tester.pumpWidget(
      _createPicker(onEmojiSelected: onEmojiSelected, overrides: overrides));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Open Picker'));
  await tester.pumpAndSettle();
}

void main() {
  group('RelayEmojiPicker', () {
    testWidgets('renders header with title', (tester) async {
      await _openPicker(tester, onEmojiSelected: (_) {});

      expect(find.text('Pick a reaction'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_emotions_outlined), findsOneWidget);
    });

    testWidgets('renders curated emoji grid', (tester) async {
      await _openPicker(tester, onEmojiSelected: (_) {});

      // Check a sample of curated emojis are present
      expect(find.text('\u{1F44D}'), findsOneWidget); // 👍
      expect(find.text('\u{2764}'), findsOneWidget); // ❤️
      expect(find.text('\u{1F680}'), findsOneWidget); // 🚀
      expect(find.text('\u{1F525}'), findsOneWidget); // 🔥
    });

    testWidgets('renders all 30 curated emojis', (tester) async {
      await _openPicker(tester, onEmojiSelected: (_) {});

      // Each curated emoji should appear exactly once
      for (final emoji in curatedEmojis) {
        expect(find.text(emoji), findsOneWidget,
            reason: 'Expected curated emoji $emoji to appear once');
      }
    });

    testWidgets('tapping emoji fires callback and closes picker',
        (tester) async {
      String? selected;
      await _openPicker(tester, onEmojiSelected: (e) => selected = e);

      await tester.tap(find.text('\u{1F44D}')); // 👍
      await tester.pumpAndSettle();

      expect(selected, '\u{1F44D}');
      // Picker should be closed
      expect(find.text('Pick a reaction'), findsNothing);
    });

    testWidgets('close button dismisses picker', (tester) async {
      await _openPicker(tester, onEmojiSelected: (_) {});

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Pick a reaction'), findsNothing);
    });

    testWidgets('shows recently used section when recents exist',
        (tester) async {
      await _openPicker(
        tester,
        onEmojiSelected: (_) {},
        overrides: [
          recentEmojisProvider
              .overrideWith((ref) => RecentEmojisNotifier()..add('\u{1F525}')),
        ],
      );

      expect(find.text('RECENTLY USED'), findsOneWidget);
      // The fire emoji should appear twice: once in recents, once in grid
      expect(find.text('\u{1F525}'), findsNWidgets(2));
    });

    testWidgets('hides recently used section when no recents', (tester) async {
      await _openPicker(tester, onEmojiSelected: (_) {});

      expect(find.text('RECENTLY USED'), findsNothing);
    });

    testWidgets('selecting emoji records it in recents', (tester) async {
      late ProviderContainer container;
      await tester.pumpWidget(
        ProviderScope(
          child: Builder(builder: (context) {
            return MaterialApp(
              home: Consumer(builder: (context, ref, _) {
                container = ProviderScope.containerOf(context);
                return Scaffold(
                  body: Builder(
                    builder: (innerContext) => ElevatedButton(
                      onPressed: () => showDialog<void>(
                        context: innerContext,
                        builder: (_) => ProviderScope(
                          parent: container,
                          child: Dialog(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            child: RelayEmojiPicker(
                                onEmojiSelected: (_) {}),
                          ),
                        ),
                      ),
                      child: const Text('Open Picker'),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('\u{1F680}')); // 🚀
      await tester.pumpAndSettle();

      final recents = container.read(recentEmojisProvider);
      expect(recents, contains('\u{1F680}'));
    });
  });
}
