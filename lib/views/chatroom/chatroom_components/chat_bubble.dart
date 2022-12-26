import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat_example/utils/ui_utils.dart';

import './reaction_enum.dart';
import 'reaction_bar.dart';
import 'reaction_chip.dart';

class ChatBubble extends StatefulWidget {
  final bool? isSent;
  final String? message;
  final String? time;
  final String? profileImageUrl;
  final bool showReactions;
  final Function() makeBlur;

  const ChatBubble({
    super.key,
    this.isSent = true,
    this.message,
    this.time,
    this.profileImageUrl,
    this.showReactions = false,
    required this.makeBlur,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _showReactions = false;
  List reactions = [];
  final EmojiParser emojiParser = EmojiParser();

  printReactions() =>
      print("List contains: ${reactions.map((e) => e.toString()).join(", ")}");

  @override
  Widget build(BuildContext context) {
    bool _isSent = widget.isSent!;
    String _message = widget.message ?? "Test message";
    String _time = widget.time ?? "12:00";
    String _profileImageUrl =
        widget.profileImageUrl ?? "https://picsum.photos/200/300";

    return Column(
      crossAxisAlignment:
          _isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 4,
          ),
          child: Row(
            mainAxisAlignment:
                _isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              !_isSent
                  ? Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(21),
                        image: _profileImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_profileImageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(width: 6),
              GestureDetector(
                onLongPress: () {
                  widget.makeBlur();
                  Fluttertoast.showToast(msg: "Long presssssed ${widget.key}");
                  setState(() {
                    _showReactions = !_showReactions;
                  });
                },
                onTap: () {
                  Fluttertoast.showToast(msg: "Tapped");
                },
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 42,
                    maxWidth: getWidth(context) * 0.6,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: _isSent
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            _message,
                            textAlign:
                                _isSent ? TextAlign.end : TextAlign.start,
                            style: GoogleFonts.roboto(),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _time,
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _isSent
                  ? Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(21),
                        image: _profileImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_profileImageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
        if (reactions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0),
            child: Row(
              mainAxisAlignment:
                  _isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: reactions.map((e) {
                switch (e) {
                  case Reactions.like:
                    return ReactionChip(
                      text: "1",
                      icon: emojiParser.emojify(":thumbsup:"),
                    );
                  case Reactions.dislike:
                    return ReactionChip(
                      text: "1",
                      icon: emojiParser.emojify(":thumbsdown:"),
                    );
                  case Reactions.love:
                    return ReactionChip(
                      text: "1",
                      icon: emojiParser.emojify(":heart:"),
                    );
                  case Reactions.happy:
                    return ReactionChip(
                      text: "1",
                      icon: emojiParser.emojify(":joy:"),
                    );
                  case Reactions.sad:
                    return ReactionChip(
                      text: "1",
                      icon: emojiParser.emojify(":cry:"),
                    );
                  default:
                    return const SizedBox();
                }
              }).toList(),
            ),
          ),
        if (_showReactions)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0),
            child: ReactionBar(
              refresh: refresh,
              reactions: reactions,
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  void refresh() {
    setState(() {});
  }
}
