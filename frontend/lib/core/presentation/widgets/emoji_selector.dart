import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:reallystick/core/ui/extensions.dart';

class CustomEmojiSelector extends StatelessWidget {
  final dynamic onEmojiSelected;
  final String userLocale;

  const CustomEmojiSelector({
    this.onEmojiSelected,
    required this.userLocale,
  });

  @override
  Widget build(BuildContext context) {
    return EmojiPicker(
      config: Config(
        locale: Locale(userLocale),
        checkPlatformCompatibility: true,
        viewOrderConfig: const ViewOrderConfig(),
        emojiViewConfig: EmojiViewConfig(
          backgroundColor: context.colors.background,
        ),
        skinToneConfig: const SkinToneConfig(),
        categoryViewConfig: CategoryViewConfig(
          recentTabBehavior: RecentTabBehavior.NONE,
          backgroundColor: context.colors.background,
        ),
        bottomActionBarConfig: BottomActionBarConfig(
            backgroundColor: context.colors.background,
            buttonColor: Colors.transparent),
        searchViewConfig: SearchViewConfig(
          backgroundColor: context.colors.background,
        ),
      ),
      onEmojiSelected: onEmojiSelected,
    );
  }
}
