import 'package:flutter/material.dart';
import 'package:group_chat_example/utils/ui_utils.dart';

import 'reaction_enum.dart';
import 'reaction_button.dart';

class ReactionBar extends StatelessWidget {
  final List reactions;
  final Function() refresh;

  const ReactionBar({
    super.key,
    required this.refresh,
    required this.reactions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: getWidth(context) * 0.48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ReactionButton(
            icon: Icons.thumb_up,
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
            icon: Icons.thumb_down,
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
            icon: Icons.favorite,
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
            icon: Icons.mood,
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
            icon: Icons.mood_bad,
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
