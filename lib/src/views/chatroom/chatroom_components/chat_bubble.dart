import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/likeminds_chat_mm_fl.dart';
import 'package:likeminds_chat_mm_fl/packages/expandable_text/expandable_text.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/utils/ui_utils.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:likeminds_chat_mm_fl/src/views/video_player_screen.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/picture_or_initial.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/spinner.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/reaction_bar.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/enums/content_enum.dart'
    as content;
import '../../conversation/media/media_utils.dart';

class ChatBubble extends StatefulWidget {
  final Conversation conversation;
  final ChatRoom chatroom;
  final User sender;
  final Map<String, List<File>> mediaFiles;
  final List<dynamic>? conversationAttachments;

  const ChatBubble({
    super.key,
    required this.chatroom,
    required this.conversation,
    required this.sender,
    required this.mediaFiles,
    this.conversationAttachments,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _showReactions = false;
  List reactions = [];
  late User user;
  LMBranding lmBranding = LMBranding.instance;
  late final EmojiParser emojiParser;
  late final CustomPopupMenuController _controller;
  bool? isSent;

  printReactions() =>
      print("List contains: ${reactions.map((e) => e.toString()).join(", ")}");

  @override
  void initState() {
    emojiParser = EmojiParser();
    user = UserLocalPreference.instance.fetchUserData();
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
    isSent = widget.sender.id == user.id;
    return Column(
      crossAxisAlignment:
          isSent! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                isSent! ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              !isSent!
                  ? PictureOrInitial(
                      fallbackText: widget.sender.name,
                      imageUrl: widget.sender.imageUrl,
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
                              Clipboard.setData(
                                ClipboardData(
                                  text: widget.conversation.answer,
                                ),
                              ).then((value) {
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
                  onTap: () {},
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 42,
                      maxWidth: 60.w,
                    ),
                    decoration: BoxDecoration(
                      color: isSent!
                          ? Colors.white.withOpacity(0.8)
                          : lmBranding.buttonColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: isSent!
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          isSent!
                              ? const SizedBox()
                              : Text(
                                  widget.sender.name,
                                  style: LMFonts.instance.medium.copyWith(
                                    fontSize: 10.sp,
                                    color: isSent!
                                        ? Colors.black.withOpacity(0.6)
                                        : lmBranding.headerColor,
                                  ),
                                ),
                          const SizedBox(height: 6),
                          FutureBuilder(
                              builder: ((context, snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!;
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                              future: getContent()),
                          const SizedBox(height: 8),
                          ((widget.conversation.hasFiles == null ||
                                      !widget.conversation.hasFiles!) ||
                                  (widget.conversation.attachmentsUploaded !=
                                          null &&
                                      widget.conversation.attachmentsUploaded!))
                              ? Text(
                                  widget.conversation.createdAt,
                                  style: LMFonts.instance.regular.copyWith(
                                    fontSize: 8.sp,
                                    color: kGreyColor,
                                  ),
                                )
                              : Icon(
                                  Icons.timer_outlined,
                                  size: 8.sp,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              isSent!
                  ? PictureOrInitial(
                      fallbackText: widget.sender.name,
                      imageUrl: widget.sender.imageUrl,
                      size: 28.sp,
                      fontSize: 14.sp,
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }

  void refresh() {
    setState(() {});
  }

  void selectMessage(String messageId) {}

  Future<Widget> getContent() async {
    Widget expandableText = ExpandableText(
      widget.conversation.answer,
      expandText: "",
      linkStyle:
          lmBranding.fonts.regular.copyWith(color: lmBranding.textLinkColor),
      textAlign: TextAlign.start,
      style: LMFonts.instance.regular.copyWith(
        fontSize: 10.sp,
      ),
    );
    if (widget.conversation.hasFiles == null ||
        !widget.conversation.hasFiles!) {
      return expandableText;
    } else if (widget.conversation.attachmentsUploaded == null ||
        !widget.conversation.attachmentsUploaded!) {
      if (widget.mediaFiles[widget.conversation.temporaryId] == null) {
        return expandableText;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                height: 60.w,
                width: 60.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                ),
                child: Image.file(
                  widget.mediaFiles[widget.conversation.temporaryId]!.first,
                  fit: BoxFit.cover,
                  height: 60.w,
                  width: 60.w,
                ),
              ),
              SizedBox(
                height: 60.w,
                width: 60.w,
                child: const Center(
                  child: Spinner(),
                ),
              )
            ],
          ),
          widget.conversation.answer.isEmpty
              ? const SizedBox.shrink()
              : kVerticalPaddingMedium,
          widget.conversation.answer.isEmpty
              ? const SizedBox.shrink()
              : expandableText,
        ],
      );
    } else if (widget.conversation.attachmentsUploaded != null ||
        widget.conversation.attachmentsUploaded!) {
      if (widget.conversationAttachments == null) {
        return expandableText;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.conversationAttachments!.first['type'] == 'image')
            Container(
              height: 60.w,
              width: 60.w,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: CachedNetworkImage(
                imageUrl: widget.conversationAttachments!.first['file_url'] ??
                    widget.conversationAttachments!.first['url'],
                fit: BoxFit.cover,
                height: 60.w,
                width: 60.w,
                errorWidget: (context, url, error) => mediaErrorWidget(),
                progressIndicatorBuilder: (context, url, progress) =>
                    mediaShimmer(),
              ),
            ),
          widget.conversation.answer.isEmpty
              ? const SizedBox.shrink()
              : kVerticalPaddingMedium,
          widget.conversation.answer.isEmpty
              ? const SizedBox.shrink()
              : expandableText,
        ],
      );
    }
    return const SizedBox();

    // final uint8list = await VideoThumbnail.thumbnailData(
    //   video: message,
    //   imageFormat: ImageFormat.JPEG,
    //   maxWidth: 600,
    //   quality: 25,
    // );

    // return Stack(
    //   alignment: Alignment.center,
    //   children: [
    //     Image.memory(uint8list!),
    //     GestureDetector(
    //       onTap: (() {
    //         Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //             builder: (context) => VideoPlayerScreen(
    //               videoUrl: message,
    //             ),
    //           ),
    //         );
    //       }),
    //       child: const Icon(
    //         Icons.play_circle_outline,
    //         size: 48,
    //         color: Colors.white,
    //       ),
    //     ),
    //   ],
    // );
  }
}
