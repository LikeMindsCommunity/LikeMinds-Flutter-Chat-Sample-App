import 'package:flutter/services.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/likeminds_chat_mm_fl.dart';
import 'package:likeminds_chat_mm_fl/packages/expandable_text/expandable_text.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/service/media_service.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:likeminds_chat_mm_fl/src/utils/tagging/helpers/tagging_helper.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/document/document_preview_factory.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/bubble_triangle.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/picture_or_initial.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/spinner.dart';
import 'package:swipe_to_action/swipe_to_action.dart';
import '../../media/media_utils.dart';

class ChatBubble extends StatefulWidget {
  final Conversation conversation;
  final Conversation? replyToConversation;
  final ChatRoom chatroom;
  final User sender;
  final Map<int, User?> userMeta;
  final Map<String, List<Media>> mediaFiles;
  final List<dynamic>? conversationAttachments;
  final List<dynamic>? replyConversationAttachments;
  final Function(Conversation replyingTo) onReply;
  final Function(Conversation editConversation) onEdit;
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
    this.replyConversationAttachments,
    required this.onReply,
    required this.onLongPress,
    required this.isSelected,
    required this.userMeta,
    required this.onEdit,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  List reactions = [];
  late final EmojiParser emojiParser;
  late final CustomPopupMenuController _controller;
  Map<int, User?>? userMeta;
  bool? isSent;
  Conversation? conversation;
  Conversation? replyToConversation;
  Map<String, List<Media>>? mediaFiles;
  List<Media>? conversationAttachments;
  List<Media>? replyConversationAttachments;
  bool isSelected = false;
  bool isDeleted = false;
  bool isEdited = false;
  final ValueNotifier<bool> _isSelected = ValueNotifier(false);
  final User loggedInUser = UserLocalPreference.instance.fetchUserData();
  final MemberStateResponse isCm =
      UserLocalPreference.instance.fetchMemberRights();

  printReactions() => debugPrint(
      "List contains: ${reactions.map((e) => e.toString()).join(", ")}");

  @override
  void initState() {
    super.initState();
    emojiParser = EmojiParser();
    // user = UserLocalPreference.instance.fetchUserData();
    _controller = CustomPopupMenuController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _isSelected.dispose();
    super.dispose();
  }

  bool checkDeletePermissions() {
    if (isCm.member?.state == 1 && conversation!.deletedByUserId == null) {
      return true;
    } else if (loggedInUser.id == widget.sender.id &&
        conversation!.deletedByUserId == null) {
      return true;
    } else {
      return false;
    }
  }

  bool checkEditPermissions() {
    if (conversation!.answer.isEmpty) {
      return false;
    } else if (loggedInUser.id == widget.sender.id &&
        conversation!.deletedByUserId == null) {
      return true;
    }
    return false;
  }

  void setupConversation() {
    isSent = widget.sender.id == loggedInUser.id;
    conversation = widget.conversation;
    replyToConversation = widget.replyToConversation;
    isDeleted = conversation!.deletedByUserId != null;
    isEdited = conversation!.isEdited ?? false;
    mediaFiles = widget.mediaFiles;
    conversationAttachments =
        widget.conversationAttachments?.map((e) => Media.fromJson(e)).toList();
    replyConversationAttachments = widget.replyConversationAttachments
        ?.map((e) => Media.fromJson(e))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    setupConversation();
    if (!isSent! &&
        conversation?.hasFiles != null &&
        conversation!.hasFiles! &&
        conversation?.attachmentsUploaded != null &&
        !conversation!.attachmentsUploaded!) {
      return const SizedBox.shrink();
    }
    userMeta = widget.userMeta;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        _isSelected.value = true;
        debugPrint("Long Pressed");
        widget.onLongPress(conversation!);
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
            key: ValueKey(conversation!.id),
            onSwipe: (direction) {
              int userId = conversation!.userId ?? conversation!.memberId!;
              if (userId == loggedInUser.id) {
                conversation!.member = loggedInUser;
              }
              if (conversation!.deletedByUserId != null) {
                return;
              }
              widget.onReply(conversation!);
            },
            background: Padding(
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
                  width: 48.w,
                  // color: Colors.white,
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          onTap: () {
                            widget.onReply(conversation!);
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
                                        widget.conversation.answer) ??
                                    '',
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
                        kVerticalPaddingMedium,
                        Visibility(
                          visible: checkEditPermissions(),
                          child: ListTile(
                            onTap: () async {
                              widget.onEdit(conversation!);
                              _controller.hideMenu();
                            },
                            leading: Icon(
                              Icons.edit,
                              color: LMTheme.buttonColor,
                              size: 16.sp,
                            ),
                            title: Text(
                              "Edit",
                              style: LMTheme.regular.copyWith(
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ),
                        kVerticalPaddingMedium,
                        Visibility(
                          visible: checkDeletePermissions(),
                          child: ListTile(
                            onTap: () async {
                              final response = await locator<LikeMindsService>()
                                  .deleteConversation(
                                      (DeleteConversationRequestBuilder()
                                            ..conversationIds(
                                                [conversation!.id])
                                            ..reason("Delete"))
                                          .build());
                              if (response.success) {
                                _controller.hideMenu();
                                setState(() {
                                  conversation!.deletedByUserId =
                                      loggedInUser.id;
                                  isDeleted = true;
                                });
                                Fluttertoast.showToast(msg: "Message deleted");
                              }
                            },
                            leading: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 16.sp,
                            ),
                            title: Text(
                              "Delete",
                              style: LMTheme.regular.copyWith(
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ),

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      right: isSent! ? 2.5.w : 0,
                      // vertical: 0.5..h,
                    ),
                    child: Row(
                      mainAxisAlignment: isSent!
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        !isSent!
                            ? PictureOrInitial(
                                fallbackText: widget.sender.name,
                                imageUrl: widget.sender.imageUrl,
                                size: 32.sp,
                                fontSize: 14.sp,
                              )
                            : const SizedBox(),
                        const SizedBox(width: 6),
                        !isSent!
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
                            crossAxisAlignment: isSent!
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Visibility(
                                visible: replyToConversation != null,
                                maintainState: true,
                                maintainSize: false,
                                child: _getReplyConversation(),
                              ),
                              replyToConversation != null
                                  ? const SizedBox(height: 8)
                                  : const SizedBox(),
                              isSent!
                                  ? const SizedBox()
                                  : Text(
                                      widget.sender.name,
                                      style: LMFonts.instance.medium.copyWith(
                                        fontSize: 10.sp,
                                        color: isSent!
                                            ? Colors.black.withOpacity(0.6)
                                            : LMTheme.headerColor,
                                      ),
                                    ),
                              isSent!
                                  ? const SizedBox()
                                  : const SizedBox(height: 6),
                              isDeleted
                                  ? conversation!.deletedByUserId ==
                                          loggedInUser.id
                                      ? Text(
                                          "This message was deleted",
                                          style:
                                              LMFonts.instance.regular.copyWith(
                                            fontSize: 9.sp,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        )
                                      : Text(
                                          "This message was deleted by the Community Manager",
                                          style:
                                              LMFonts.instance.regular.copyWith(
                                            fontSize: 9.sp,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        )
                                  : replyToConversation != null
                                      ? Align(
                                          alignment: Alignment.topLeft,
                                          child: getContent())
                                      : getContent(),
                              const SizedBox(height: 8),
                              ((widget.conversation.hasFiles == null ||
                                          !widget.conversation.hasFiles!) ||
                                      (widget.conversation
                                                  .attachmentsUploaded !=
                                              null &&
                                          widget.conversation
                                              .attachmentsUploaded!))
                                  ? Text(
                                      "${isEdited ? 'Edited  ' : ''}${widget.conversation.createdAt}",
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
                        isSent!
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
    );
  }

  Container _getReplyConversation() {
    return Container(
      color: kGreyColor.withOpacity(0.1),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 6.h,
            width: 1.w,
            color: LMTheme.buttonColor,
          ),
          kHorizontalPaddingMedium,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  replyToConversation?.member?.name ??
                      userMeta?[replyToConversation?.userId]?.name ??
                      '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: LMTheme.medium.copyWith(
                    color: kPrimaryColor,
                    fontSize: 9.sp,
                  ),
                ),
                kVerticalPaddingXSmall,
                SizedBox(
                  width: 35.w,
                  child: Text(
                    _getReplyText(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: LMTheme.regular.copyWith(
                      fontSize: 8.sp,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          kHorizontalPaddingMedium,
        ],
      ),
    );
  }

  String _getReplyText() {
    String attachmentText = "";
    if (replyToConversation?.hasFiles != null &&
        replyToConversation!.hasFiles! &&
        replyConversationAttachments?.first.mediaType == MediaType.document) {
      attachmentText =
          "${replyToConversation!.attachmentCount} ${replyToConversation!.attachmentCount! > 1 ? "Documents" : "Document"}";
    } else if (replyToConversation?.hasFiles != null &&
        replyToConversation!.hasFiles! &&
        replyConversationAttachments?.first.mediaType == MediaType.photo) {
      attachmentText =
          "${replyToConversation!.attachmentCount} ${replyToConversation!.attachmentCount! > 1 ? "Images" : "Image"}";
    }

    return replyToConversation?.answer != null &&
            replyToConversation?.answer.isNotEmpty == true
        ? TaggingHelper.convertRouteToTag(replyToConversation?.answer,
                withTilde: false) ??
            ""
        : attachmentText;
  }

  void refresh() {
    setState(() {});
  }

  void selectMessage(String messageId) {}

  Widget getContent() {
    Widget expandableText = ExpandableText(
      widget.conversation.answer,
      expandText: "see more",
      linkStyle: LMTheme.regular.copyWith(
        color: LMTheme.textLinkColor,
        fontSize: 9.sp,
      ),
      textAlign: TextAlign.left,
      style: LMTheme.regular.copyWith(
        fontSize: 9.sp,
      ),
    );
    // if no media is attached to the conversation
    // return text message
    if (widget.conversation.hasFiles == null ||
        !widget.conversation.hasFiles!) {
      return expandableText;
    } else if (widget.conversation.attachmentsUploaded == null ||
        !widget.conversation.attachmentsUploaded!) {
      // If conversation has media but not uploaded yet
      // show local files
      if (widget.mediaFiles[widget.conversation.temporaryId] == null ||
          widget.mediaFiles[widget.conversation.temporaryId]!.isEmpty) {
        return expandableText;
      }
      Widget mediaWidget;
      if (widget.mediaFiles[widget.conversation.temporaryId]!.first.mediaType ==
              MediaType.photo ||
          widget.mediaFiles[widget.conversation.temporaryId]!.first.mediaType ==
              MediaType.video) {
        mediaWidget = getImageFileMessage(
            context, widget.mediaFiles[widget.conversation.temporaryId]!);
      } else if (widget
              .mediaFiles[widget.conversation.temporaryId]!.first.mediaType ==
          MediaType.document) {
        mediaWidget = documentPreviewFactory(
            widget.mediaFiles[widget.conversation.temporaryId]!);
      } else {
        mediaWidget = const SizedBox();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              mediaWidget,
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
              : kVerticalPaddingXSmall,
          widget.conversation.answer.isEmpty
              ? const SizedBox.shrink()
              : expandableText,
        ],
      );
    } else if (widget.conversation.attachmentsUploaded != null ||
        widget.conversation.attachmentsUploaded!) {
      // If conversation has media and uploaded
      // show uploaded files
      if (conversationAttachments == null) {
        return expandableText;
      }

      Widget mediaWidget;
      if (conversationAttachments!.first.mediaType == MediaType.photo ||
          conversationAttachments!.first.mediaType == MediaType.video) {
        mediaWidget = getImageMessage(
          context,
          conversationAttachments!,
          widget.chatroom,
          conversation!,
          userMeta!,
        );
      } else if (conversationAttachments!.first.mediaType ==
          MediaType.document) {
        mediaWidget = documentPreviewFactory(conversationAttachments!);
      } else {
        mediaWidget = const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          mediaWidget,
          conversation!.answer.isEmpty
              ? const SizedBox.shrink()
              : kVerticalPaddingXSmall,
          conversation!.answer.isEmpty
              ? const SizedBox.shrink()
              : expandableText,
        ],
      );
    }
    return const SizedBox();
  }
}

/// Code or conversation actions
