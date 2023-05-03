import 'package:flutter/services.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/likeminds_chat_mm_fl.dart';
import 'package:likeminds_chat_mm_fl/packages/expandable_text/expandable_text.dart';
import 'package:likeminds_chat_mm_fl/src/utils/analytics/analytics.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/utils/media/media_service.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:likeminds_chat_mm_fl/src/utils/tagging/helpers/tagging_helper.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/bubble_triangle.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/picture_or_initial.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/spinner.dart';
import 'package:swipe_to_action/swipe_to_action.dart';
import '../../conversation/media/media_utils.dart';

class ChatBubble extends StatefulWidget {
  final Conversation conversation;
  final Conversation? replyToConversation;
  final ChatRoom chatroom;
  final User sender;
  final Map<String, List<Media>> mediaFiles;
  final List<dynamic>? conversationAttachments;
  final Function(Conversation replyingTo) onReply;
  final Function(Conversation conversation) onLongPress;
  final ValueChanged<bool> isSelected;

  const ChatBubble({
    super.key,
    required this.chatroom,
    required this.conversation,
    this.replyToConversation,
    required this.sender,
    required this.mediaFiles,
    this.conversationAttachments,
    required this.onReply,
    required this.onLongPress,
    required this.isSelected,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  List reactions = [];
  late User user;
  late final EmojiParser emojiParser;
  late final CustomPopupMenuController _controller;
  late bool isSent;
  late Conversation conversation;
  late Conversation? replyToConversation;
  bool isSelected = false;
  final ValueNotifier<bool> _isSelected = ValueNotifier(false);

  printReactions() =>
      print("List contains: ${reactions.map((e) => e.toString()).join(", ")}");

  @override
  void initState() {
    super.initState();
    emojiParser = EmojiParser();
    user = UserLocalPreference.instance.fetchUserData();
    isSent = widget.sender.id == user.id;
    _controller = CustomPopupMenuController();
    conversation = widget.conversation;
    replyToConversation = widget.replyToConversation;
    LMAnalytics.get().track(AnalyticsKeys.imageViewed, {
      'chatroom_id': widget.chatroom.id,
      'community_id': widget.chatroom.communityId,
      'chatroom_type': widget.chatroom.type,
      'message_id': widget.conversation.id,
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _isSelected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isSent &&
        widget.conversation.hasFiles != null &&
        widget.conversation.hasFiles! &&
        widget.conversation.attachmentsUploaded != null &&
        !widget.conversation.attachmentsUploaded!) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        _isSelected.value = true;
        debugPrint("Long Pressed");
        widget.onLongPress(conversation);
        setState(() {
          _controller.showMenu();
          widget.isSelected(isSelected);
        });
      },
      onTap: () {
        _isSelected.value = false;
        debugPrint("Tapped");
        setState(() {
          _controller.hideMenu();
          widget.isSelected(isSelected);
        });
      },
      child: ValueListenableBuilder(
        valueListenable: _isSelected,
        builder: (BuildContext context, dynamic value, Widget? child) {
          return Container(
            color: value
                ? LMTheme.buttonColor.withOpacity(0.2)
                : Colors.transparent,
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Swipeable(
            key: ValueKey(conversation.id),
            onSwipe: (direction) {
              widget.onReply(conversation);
            },
            background: Container(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 2.w,
                  right: 2.w,
                  top: 0.2.h,
                  bottom: 0.2.h,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.reply_outlined,
                      color: LMTheme.buttonColor,
                      size: 18.sp,
                    ),
                  ],
                ),
              ),
            ),
            direction: SwipeDirection.startToEnd,
            child: CustomPopupMenu(
              controller: _controller,
              pressType: PressType.longPress,
              showArrow: false,
              verticalMargin: 1.h,
              menuBuilder: () => ClipRRect(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  width: 42.w,
                  // color: Colors.white,
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          onTap: () {
                            widget.onReply(conversation);
                            _controller.hideMenu();
                          },
                          leading: Icon(
                            Icons.reply_outlined,
                            color: LMTheme.buttonColor,
                            size: 16.sp,
                          ),
                          title: Text(
                            "Reply",
                            style: LMTheme.regular.copyWith(
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            _controller.hideMenu();
                            Clipboard.setData(
                              ClipboardData(
                                text: TaggingHelper.convertRouteToTag(
                                    widget.conversation.answer),
                              ),
                            ).then((value) {
                              Fluttertoast.showToast(
                                  msg: "Copied to clipboard");
                            });
                          },
                          leading: Icon(
                            Icons.copy,
                            color: LMTheme.buttonColor,
                            size: 16.sp,
                          ),
                          title: Text(
                            "Copy text",
                            style: LMTheme.regular.copyWith(
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                        kVerticalPaddingMedium
                        // ListTile(
                        //   onTap: () {
                        //     _controller.hideMenu();
                        //     Fluttertoast.showToast(
                        //         msg: "Add report screen");
                        //   },
                        //   leading: const Icon(
                        //     Icons.report_outlined,
                        //     size: 18,
                        //     color: Colors.red,
                        //   ),
                        //   title: Text(
                        //     "Report",
                        //     style: GoogleFonts.roboto(
                        //       fontSize: 16,
                        //       color: Colors.red,
                        //     ),
                        //   ),
                        // ),
                        // ListTile(
                        //   onTap: () {
                        //     _controller.hideMenu();
                        //     Fluttertoast.showToast(
                        //         msg: "Add select all functionality");
                        //   },
                        //   leading: const Icon(
                        //     Icons.select_all,
                        //     size: 18,
                        //   ),
                        //   title: Text(
                        //     "Select",
                        //     style: GoogleFonts.roboto(
                        //       fontSize: 16,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        right: isSent ? 2.5.w : 0,
                        // vertical: 0.5..h,
                      ),
                      child: Row(
                        mainAxisAlignment: isSent
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          !isSent
                              ? PictureOrInitial(
                                  fallbackText: widget.sender.name,
                                  imageUrl: widget.sender.imageUrl,
                                  size: 32.sp,
                                  fontSize: 14.sp,
                                )
                              : const SizedBox(),
                          const SizedBox(width: 6),
                          !isSent
                              ? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(3.14),
                                  child: CustomPaint(
                                    painter: BubbleTriangle(),
                                  ),
                                )
                              : const SizedBox(),
                          Container(
                            constraints: BoxConstraints(
                              minHeight: 4.h,
                              minWidth: 10.w,
                              maxWidth: 60.w,
                            ),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: isSent
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: replyToConversation != null,
                                  maintainState: true,
                                  maintainSize: false,
                                  child: Container(
                                    color: kGreyColor.withOpacity(0.1),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: 6.h,
                                          width: 1.w,
                                          color: LMTheme.buttonColor,
                                        ),
                                        kHorizontalPaddingMedium,
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 6),
                                            Text(
                                              replyToConversation
                                                      ?.member?.name ??
                                                  "",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: LMTheme.medium.copyWith(
                                                color: kPrimaryColor,
                                                fontSize: 9.sp,
                                              ),
                                            ),
                                            kVerticalPaddingXSmall,
                                            Text(
                                              TaggingHelper.convertRouteToTag(
                                                      replyToConversation
                                                          ?.answer) ??
                                                  "",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: LMTheme.regular.copyWith(
                                                fontSize: 8.sp,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                          ],
                                        ),
                                        kHorizontalPaddingMedium,
                                      ],
                                    ),
                                  ),
                                ),
                                replyToConversation != null
                                    ? const SizedBox(height: 8)
                                    : const SizedBox(),
                                isSent
                                    ? const SizedBox()
                                    : Text(
                                        widget.sender.name,
                                        style: LMFonts.instance.medium.copyWith(
                                          fontSize: 10.sp,
                                          color: isSent
                                              ? Colors.black.withOpacity(0.6)
                                              : LMTheme.headerColor,
                                        ),
                                      ),
                                isSent
                                    ? const SizedBox()
                                    : const SizedBox(height: 6),
                                getContent(),
                                const SizedBox(height: 8),
                                ((widget.conversation.hasFiles == null ||
                                            !widget.conversation.hasFiles!) ||
                                        (widget.conversation
                                                    .attachmentsUploaded !=
                                                null &&
                                            widget.conversation
                                                .attachmentsUploaded!))
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              widget.conversation.createdAt,
                                              style: LMFonts.instance.regular
                                                  .copyWith(
                                                fontSize: 8.sp,
                                                color: kGreyColor,
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    : Icon(
                                        Icons.timer_outlined,
                                        size: 8.sp,
                                      ),
                              ],
                            ),
                          ),
                          isSent
                              ? CustomPaint(
                                  painter: BubbleTriangle(),
                                )
                              : const SizedBox(),
                          // const SizedBox(width: 6),
                          // isSent
                          //     ? PictureOrInitial(
                          //         fallbackText: widget.sender.name,
                          //         imageUrl: widget.sender.imageUrl,
                          //         size: 28.sp,
                          //         fontSize: 14.sp,
                          //       )
                          //     : const SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }

  void selectMessage(String messageId) {}

  Widget getContent() {
    Widget expandableText = ExpandableText(
      widget.conversation.answer,
      expandText: "",
      linkStyle: LMTheme.regular.copyWith(
        color: LMTheme.textLinkColor,
        fontSize: 9.sp,
      ),
      textAlign: TextAlign.left,
      style: LMFonts.instance.regular.copyWith(
        fontSize: 9.sp,
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
              getImageFileMessage(
                  context, widget.mediaFiles[widget.conversation.temporaryId]!),
              const Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Spinner(),
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
            getImageMessage(context, widget.conversationAttachments!),
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


/// Code or conversation actions
