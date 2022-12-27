import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat_example/utils/ui_utils.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:group_chat_example/widgets/spinner.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

import '../../video_player_screen.dart';
import '../enums/reaction_enum.dart';
import '../enums/content_enum.dart';
import 'reaction_bar.dart';
import 'reaction_chip.dart';

class ChatBubble extends StatefulWidget {
  final bool? isSent;
  final String? message;
  final String? time;
  final String? profileImageUrl;
  final bool showReactions;
  final ContentType contentType;

  const ChatBubble({
    super.key,
    this.isSent = true,
    this.message,
    this.time,
    this.profileImageUrl,
    this.showReactions = false,
    this.contentType = ContentType.text,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _showReactions = false;
  List reactions = [];
  final EmojiParser emojiParser = EmojiParser();
  final CustomPopupMenuController _controller = CustomPopupMenuController();

  printReactions() =>
      print("List contains: ${reactions.map((e) => e.toString()).join(", ")}");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool _isSent = widget.isSent!;
    ContentType _contentType = widget.contentType;
    String _message = widget.message ?? "Test message";
    String _time = widget.time ?? "12:00";
    String _profileImageUrl =
        widget.profileImageUrl ?? "https://picsum.photos/200/300";

    return Column(
      crossAxisAlignment:
          _isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showReactions)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0),
            child: ReactionBar(
              refresh: refresh,
              reactions: reactions,
            ),
          ),
        const SizedBox(height: 8),
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
              CustomPopupMenu(
                controller: _controller,
                pressType: PressType.longPress,
                showArrow: false,
                verticalMargin: 12,
                menuBuilder: () => ClipRRect(
                  child: Container(
                    width: getWidth(context) * 0.4,
                    color: Colors.white,
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            onTap: () {
                              Fluttertoast.showToast(msg: "Reply to message");
                              _controller.hideMenu();
                            },
                            leading: const Icon(
                              Icons.reply_outlined,
                              size: 18,
                            ),
                            title: Text(
                              "Reply",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              _controller.hideMenu();
                              Clipboard.setData(ClipboardData(text: _message))
                                  .then((value) {
                                Fluttertoast.showToast(
                                    msg: "Copied to clipboard");
                              });
                            },
                            leading: const Icon(
                              Icons.copy,
                              size: 18,
                            ),
                            title: Text(
                              "Copy text",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              _controller.hideMenu();
                              Fluttertoast.showToast(msg: "Add report screen");
                            },
                            leading: const Icon(
                              Icons.report_outlined,
                              size: 18,
                              color: Colors.red,
                            ),
                            title: Text(
                              "Report",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              _controller.hideMenu();
                              Fluttertoast.showToast(
                                  msg: "Add select all functionality");
                            },
                            leading: const Icon(
                              Icons.select_all,
                              size: 18,
                            ),
                            title: Text(
                              "Logout",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                child: GestureDetector(
                  onLongPress: () {
                    _controller.showMenu();
                  },
                  onTap: () {
                    Fluttertoast.showToast(msg: "Tapped");
                    setState(() {
                      _showReactions = !_showReactions;
                    });
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
                            FutureBuilder(
                                builder: ((context, snapshot) {
                                  if (snapshot.hasData) {
                                    return snapshot.data!;
                                  } else {
                                    return const Spinner();
                                  }
                                }),
                                future: getContent(
                                    _contentType, _message, _isSent)),
                            const SizedBox(height: 8),
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
      ],
    );
  }

  void refresh() {
    setState(() {});
  }

  void selectMessage(String messageId) {}

  Future<Widget> getContent(
    ContentType contentType,
    String message,
    bool isSent,
  ) async {
    switch (contentType) {
      case ContentType.text:
        return Text(
          message,
          textAlign: isSent ? TextAlign.end : TextAlign.start,
          style: GoogleFonts.roboto(),
        );
      case ContentType.image:
        return Image.network(message);
      case ContentType.video:
        final uint8list = await VideoThumbnail.thumbnailData(
          video: message,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 600,
          quality: 25,
        );

        return Stack(
          alignment: Alignment.center,
          children: [
            Image.memory(uint8list!),
            GestureDetector(
              onTap: (() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(
                      videoUrl: message,
                    ),
                  ),
                );
              }),
              child: const Icon(
                Icons.play_circle_outline,
                size: 48,
                color: Colors.white,
              ),
            ),
          ],
        );
      default:
        return Text(message);
    }
  }
}
