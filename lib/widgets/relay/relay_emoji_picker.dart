/// Curated emoji picker overlay for the Relay messaging module.
///
/// Displays a compact grid of ~30 commonly used emojis plus a
/// "Recently Used" row sourced from [recentEmojisProvider]. Tapping
/// an emoji fires [onEmojiSelected] and records the emoji in recents.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/relay_providers.dart';
import '../../theme/colors.dart';

/// Curated set of commonly used reaction emojis.
const curatedEmojis = [
  '\u{1F44D}', // 👍
  '\u{1F44E}', // 👎
  '\u{2764}', // ❤️
  '\u{1F602}', // 😂
  '\u{1F62E}', // 😮
  '\u{1F622}', // 😢
  '\u{1F621}', // 😡
  '\u{1F525}', // 🔥
  '\u{1F389}', // 🎉
  '\u{1F44F}', // 👏
  '\u{1F64F}', // 🙏
  '\u{1F680}', // 🚀
  '\u{2705}', // ✅
  '\u{274C}', // ❌
  '\u{1F440}', // 👀
  '\u{1F4AF}', // 💯
  '\u{1F914}', // 🤔
  '\u{1F60D}', // 😍
  '\u{1F60E}', // 😎
  '\u{1F609}', // 😉
  '\u{1F4A1}', // 💡
  '\u{1F4AC}', // 💬
  '\u{2B50}', // ⭐
  '\u{1F6A8}', // 🚨
  '\u{1F3AF}', // 🎯
  '\u{1F52C}', // 🔬
  '\u{1F41B}', // 🐛
  '\u{2699}', // ⚙️
  '\u{1F512}', // 🔒
  '\u{1F4DD}', // 📝
];

/// Compact emoji picker for message reactions.
///
/// Shows a "Recently Used" row (if any recents exist) followed by a
/// grid of [curatedEmojis]. Tapping an emoji calls [onEmojiSelected]
/// and records the selection in [recentEmojisProvider].
class RelayEmojiPicker extends ConsumerWidget {
  /// Called when the user selects an emoji.
  final ValueChanged<String> onEmojiSelected;

  /// Creates a [RelayEmojiPicker].
  const RelayEmojiPicker({required this.onEmojiSelected, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recents = ref.watch(recentEmojisProvider);

    return Container(
      width: 280,
      constraints: const BoxConstraints(maxHeight: 340),
      decoration: BoxDecoration(
        color: CodeOpsColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CodeOpsColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 0),
            child: Row(
              children: [
                const Icon(Icons.emoji_emotions_outlined,
                    size: 16, color: CodeOpsColors.textTertiary),
                const SizedBox(width: 6),
                const Text(
                  'Pick a reaction',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: CodeOpsColors.textSecondary,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 14),
                    color: CodeOpsColors.textTertiary,
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 12, color: CodeOpsColors.border),

          // Recently used
          if (recents.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                'RECENTLY USED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: CodeOpsColors.textTertiary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                spacing: 2,
                children: recents
                    .map((emoji) => _EmojiButton(
                          emoji: emoji,
                          onTap: () => _selectEmoji(ref, context, emoji),
                        ))
                    .toList(),
              ),
            ),
            const Divider(height: 12, color: CodeOpsColors.border),
          ],

          // Curated grid
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemCount: curatedEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = curatedEmojis[index];
                  return _EmojiButton(
                    emoji: emoji,
                    onTap: () => _selectEmoji(ref, context, emoji),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fires the callback, records the emoji in recents, and closes.
  void _selectEmoji(WidgetRef ref, BuildContext context, String emoji) {
    ref.read(recentEmojisProvider.notifier).add(emoji);
    onEmojiSelected(emoji);
    Navigator.of(context).pop();
  }
}

/// Individual emoji button in the picker grid.
class _EmojiButton extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;

  const _EmojiButton({required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
