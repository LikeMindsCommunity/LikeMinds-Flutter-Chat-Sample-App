import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:group_chat_example/utils/ui_utils.dart';

import 'reaction_enum.dart';
import 'reaction_button.dart';

class ReactionBar extends StatelessWidget {
  final List reactions;
  final Function() refresh;
  final EmojiParser emojiParser = EmojiParser();

  ReactionBar({
    super.key,
    required this.refresh,
    required this.reactions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: getWidth(context) * 0.48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ReactionButton(
            icon: emojiParser.emojify(":thumbsup:"),
            onTap: () {
              if (!reactions.contains(Reactions.like)) {
                reactions.add(Reactions.like);
                refresh();
              } else {
                reactions.remove(Reactions.like);
                refresh();
              }
            },
          ),
          ReactionButton(
            icon: emojiParser.emojify(":thumbsdown:"),
            onTap: () {
              if (!reactions.contains(Reactions.dislike)) {
                reactions.add(Reactions.dislike);
                refresh();
              } else {
                reactions.remove(Reactions.dislike);
                refresh();
              }
            },
          ),
          ReactionButton(
            icon: emojiParser.emojify(":heart:"),
            onTap: () {
              if (!reactions.contains(Reactions.love)) {
                reactions.add(Reactions.love);
                refresh();
              } else {
                reactions.remove(Reactions.love);
                refresh();
              }
            },
          ),
          ReactionButton(
            icon: emojiParser.emojify(":joy:"),
            onTap: () {
              if (!reactions.contains(Reactions.happy)) {
                reactions.add(Reactions.happy);
                refresh();
              } else {
                reactions.remove(Reactions.happy);
                refresh();
              }
            },
          ),
          ReactionButton(
            icon: emojiParser.emojify(":cry:"),
            onTap: () {
              if (!reactions.contains(Reactions.sad)) {
                reactions.add(Reactions.sad);
                refresh();
              } else {
                reactions.remove(Reactions.sad);
                refresh();
              }
            },
          ),
        ],
      ),
    );
  }
}
