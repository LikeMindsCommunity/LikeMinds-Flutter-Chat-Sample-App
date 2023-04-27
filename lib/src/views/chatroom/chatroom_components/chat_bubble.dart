import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/likeminds_chat_mm_fl.dart';
import 'package:likeminds_chat_mm_fl/packages/expandable_text/expandable_text.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/ui_utils.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:likeminds_chat_mm_fl/src/views/video_player_screen.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/picture_or_initial.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/spinner.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/reaction_chip.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/reaction_bar.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/enums/reaction_enum.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/enums/content_enum.dart'
    as content;

class ChatBubble extends StatefulWidget {
  final bool? isSent;
  final User user;
  final String? message;
  final String? time;
  final bool showReactions;
  final content.ContentType contentType;

  const ChatBubble({
    super.key,
    this.isSent = true,
    required this.user,
    this.message,
    this.time,
    this.showReactions = false,
    this.contentType = content.ContentType.text,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _showReactions = false;
  List reactions = [];
  LMBranding lmBranding = LMBranding.instance;
  late final EmojiParser emojiParser;
  late final CustomPopupMenuController _controller;

  printReactions() =>
      print("List contains: ${reactions.map((e) => e.toString()).join(", ")}");

  @override
  void initState() {
    emojiParser = EmojiParser();
    _controller = CustomPopupMenuController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isSent = widget.isSent!;
    content.ContentType contentType = widget.contentType;
    String message = widget.message ?? "Test message";
    String time = widget.time ?? "12:00";
    String profileImageUrl =
        widget.user.imageUrl ?? "https://picsum.photos/200/300";

    return Column(
      crossAxisAlignment:
          isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              !isSent
                  ? PictureOrInitial(
                      fallbackText: widget.user.name,
                      imageUrl: profileImageUrl,
                      size: 28.sp,
                      fontSize: 14.sp,
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
                              Clipboard.setData(ClipboardData(text: message))
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
                              "Select",
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
                    // Fluttertoast.showToast(msg: "Tapped");
                    // setState(() {
                    //   _showReactions = !_showReactions;
                    // });
                  },
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 42,
                      maxWidth: getWidth(context) * 0.6,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSent
                            ? Colors.white.withOpacity(0.8)
                            : LMBranding.instance.buttonColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: isSent
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            isSent
                                ? const SizedBox()
                                : Text(
                                    widget.user.name,
                                    style: LMFonts.instance.medium.copyWith(
                                      fontSize: 10.sp,
                                      color: isSent
                                          ? Colors.black.withOpacity(0.6)
                                          : LMBranding.instance.headerColor,
                                    ),
                                  ),
                            const SizedBox(height: 6),
                            FutureBuilder(
                                builder: ((context, snapshot) {
                                  if (snapshot.hasData) {
                                    return snapshot.data!;
                                  } else {
                                    return const Spinner();
                                  }
                                }),
                                future:
                                    getContent(contentType, message, isSent)),
                            const SizedBox(height: 8),
                            Text(
                              time,
                              style: LMFonts.instance.regular.copyWith(
                                fontSize: 8.sp,
                                color: kGreyColor,
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
              isSent
                  ? Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(21),
                        image: DecorationImage(
                          image: NetworkImage(profileImageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
        // if (reactions.isNotEmpty)
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 64.0),
        //     child: Row(
        //       mainAxisAlignment:
        //           isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        //       children: reactions.map((e) {
        //         switch (e) {
        //           case Reactions.like:
        //             return ReactionChip(
        //               text: "1",
        //               icon: emojiParser.emojify(":thumbsup:"),
        //             );
        //           case Reactions.dislike:
        //             return ReactionChip(
        //               text: "1",
        //               icon: emojiParser.emojify(":thumbsdown:"),
        //             );
        //           case Reactions.love:
        //             return ReactionChip(
        //               text: "1",
        //               icon: emojiParser.emojify(":heart:"),
        //             );
        //           case Reactions.happy:
        //             return ReactionChip(
        //               text: "1",
        //               icon: emojiParser.emojify(":joy:"),
        //             );
        //           case Reactions.sad:
        //             return ReactionChip(
        //               text: "1",
        //               icon: emojiParser.emojify(":cry:"),
        //             );
        //           default:
        //             return const SizedBox();
        //         }
        //       }).toList(),
        //     ),
        //   ),
      ],
    );
  }

  void refresh() {
    setState(() {});
  }

  void selectMessage(String messageId) {}

  Future<Widget> getContent(
    content.ContentType contentType,
    String message,
    bool isSent,
  ) async {
    switch (contentType) {
      case content.ContentType.text:
        return ExpandableText(
          message,
          expandText: "",
          textAlign: TextAlign.start,
          style: LMFonts.instance.regular.copyWith(
            fontSize: 10.sp,
          ),
        );
      case content.ContentType.image:
        return CachedNetworkImage(imageUrl: message);
      case content.ContentType.video:
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
