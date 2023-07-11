import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_portal/flutter_portal.dart';
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
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chat_action_bloc/chat_action_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/helper/reaction_helper.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/document/document_preview_factory.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/widget/media_helper_widget.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/bubble_triangle.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/picture_or_initial.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/spinner.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:swipe_to_action/swipe_to_action.dart';
import '../../media/media_utils.dart';

class ChatBubble extends StatefulWidget {
  final Conversation conversation;
  final Conversation? replyToConversation;
  final ChatRoom chatroom;
  final User sender;
  final Map<int, User?> userMeta;
  final Map<String, List<Media>> mediaFiles;
  final List<Media>? conversationAttachments;
  final List<Media>? replyConversationAttachments;
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
  late final EmojiParser emojiParser;
  late final CustomPopupMenuController _controller;
  late final CustomPopupMenuController _reactionController;
  Map<int, User?>? userMeta;
  bool? isSent;
  Conversation? conversation;
  Conversation? replyToConversation;
  Map<String, List<Media>>? mediaFiles;
  List<Media>? conversationAttachments;
  List<Media>? replyConversationAttachments;
  ValueNotifier<bool> rebuildReactionsBar = ValueNotifier(false);
  bool isSelected = false;
  bool isDeleted = false;
  bool isEdited = false;
  final ValueNotifier<bool> _isSelected = ValueNotifier(false);
  final User loggedInUser = UserLocalPreference.instance.fetchUserData();
  Map<String, List<Reaction>> mappedReactions = {};
  final MemberStateResponse isCm =
      UserLocalPreference.instance.fetchMemberRights();
  ChatActionBloc? chatActionBloc;
  bool showReaction = false;

  @override
  void initState() {
    super.initState();
    emojiParser = EmojiParser();

    _controller = CustomPopupMenuController();
    _reactionController = CustomPopupMenuController();
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
    conversationAttachments = widget.conversationAttachments;
    replyConversationAttachments = widget.replyConversationAttachments;
    if (conversation!.conversationReactions != null) {
      mappedReactions =
          convertListToMapReaction(conversation!.conversationReactions!);
    }
    _reactionController.addListener(() {
      if (!_reactionController.menuIsShowing) {
        chatActionBloc?.add(RemoveConversationToolBar());
      }
    });
  }

  void addReaction(Reaction reaction) {
    if (conversation!.hasReactions == false ||
        conversation!.conversationReactions == null) {
      conversation!.hasReactions = true;
      conversation!.conversationReactions = [reaction];
      mappedReactions =
          convertListToMapReaction(conversation!.conversationReactions!);
      setState(() {});
    } else {
      Reaction oldReaction = conversation!.conversationReactions!
          .firstWhere((element) => element.userId == loggedInUser.id);
      if (mappedReactions.containsKey(oldReaction.reaction)) {
        mappedReactions[oldReaction.reaction]!.remove(oldReaction);
        if (mappedReactions[oldReaction.reaction]!.isEmpty) {
          mappedReactions.remove(oldReaction.reaction);
        }
      }
      conversation!.conversationReactions!.remove(oldReaction);
      conversation!.conversationReactions!.add(reaction);
      if (mappedReactions.containsKey(reaction.reaction)) {
        mappedReactions[reaction.reaction]?.add(reaction);
      } else {
        mappedReactions[reaction.reaction] = [reaction];
      }
    }
    rebuildReactionsBar.value = !rebuildReactionsBar.value;
  }

  void removeReaction() {}

  @override
  Widget build(BuildContext context) {
    chatActionBloc = BlocProvider.of<ChatActionBloc>(context);
    setupConversation();
    if (!isSent! &&
        conversation?.hasFiles != null &&
        conversation!.hasFiles! &&
        conversation?.attachmentsUploaded != null &&
        !conversation!.attachmentsUploaded!) {
      return const SizedBox.shrink();
    }
    userMeta = widget.userMeta;
    return BlocListener(
      bloc: chatActionBloc,
      listener: (context, state) {
        if (state is ConversationToolBarState) {
          if (state.conversation.id == conversation!.id) {
            setState(() {
              showReaction = true;
            });
          } else if (state.conversation.id != conversation!.id &&
              showReaction) {
            setState(() {
              showReaction = false;
            });
          }
        } else if (showReaction) {
          setState(() {
            showReaction = false;
          });
        }
      },
      child: PortalTarget(
        visible: showReaction,
        anchor: const Aligned(
          follower: Alignment.topCenter,
          target: Alignment.bottomCenter,
        ),
        portalFollower: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                width: 90.w,
                height: 50,
                child: getListOfReactions(
                  onTap: (String reaction) async {
                    _reactionController.hideMenu();
                    if (reaction == 'Add') {
                      // TODO: Open Emoji Keyboard
                    } else {
                      PutReactionRequest request = (PutReactionRequestBuilder()
                            ..conversationId(conversation!.id)
                            ..reaction(reaction))
                          .build();
                      LMResponse response = await locator<LikeMindsService>()
                          .putReaction(request);
                      if (response.success) {
                        Reaction addedReaction = Reaction(
                          chatroomId: widget.chatroom.id,
                          conversationId: conversation!.id,
                          reaction: reaction,
                          userId: loggedInUser.id,
                        );
                        addReaction(addedReaction);
                      } else {
                        toast('An error occured');
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment:
              isSent! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: () {
                setState(() {
                  showReaction = true;
                  // _reactionController.showMenu();
                  chatActionBloc!.add(
                    ConversationToolBar(
                      conversation: conversation!,
                      replyConversation: replyToConversation,
                    ),
                  );
                  // widget.isSelected(isSelected);
                });
              },
              onLongPress: () {
                _isSelected.value = true;
                debugPrint("Long Pressed");
                widget.onLongPress(conversation!);
                setState(() {
                  _controller.showMenu();
                  chatActionBloc!.add(
                    ConversationToolBar(
                      conversation: conversation!,
                      replyConversation: replyToConversation,
                    ),
                  );
                  widget.isSelected(isSelected);
                });
              },
              onTap: () {
                // _isSelected.value = false;
                // debugPrint("Tapped");
                // setState(() {
                //   _controller.hideMenu();
                //   _reactionController.hideMenu();
                //   chatActionBloc!.add(RemoveConversationToolBar());
                //   widget.isSelected(isSelected);
                // });
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
                    dismissThresholds: const {SwipeDirection.startToEnd: 0.2},
                    movementDuration: const Duration(milliseconds: 50),
                    key: ValueKey(conversation!.id),
                    onSwipe: (direction) {
                      int userId =
                          conversation!.userId ?? conversation!.memberId!;
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
                                // Only show the delete option if the user is the owner of the message
                                // or if the user is a Community Manager
                                Visibility(
                                  visible: checkDeletePermissions(),
                                  child: ListTile(
                                    onTap: () async {
                                      final response = await locator<
                                              LikeMindsService>()
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
                                        Fluttertoast.showToast(
                                          msg: "Message deleted",
                                        );
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
                                        visible: replyToConversation != null &&
                                            !isDeleted,
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
                                              style: LMFonts.instance.medium
                                                  .copyWith(
                                                fontSize: 10.sp,
                                                color: isSent!
                                                    ? Colors.black
                                                        .withOpacity(0.6)
                                                    : LMTheme.headerColor,
                                              ),
                                            ),
                                      isSent!
                                          ? const SizedBox()
                                          : const SizedBox(height: 6),
                                      isDeleted
                                          ? conversation!.deletedByUserId ==
                                                  conversation!.userId
                                              ? Text(
                                                  conversation!.userId ==
                                                          loggedInUser.id
                                                      ? 'You deleted this message'
                                                      : "This message was deleted",
                                                  style: LMFonts
                                                      .instance.regular
                                                      .copyWith(
                                                    fontSize: 9.sp,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                )
                                              : Text(
                                                  "This message was deleted by the Community Manager",
                                                  style: LMFonts
                                                      .instance.regular
                                                      .copyWith(
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
                                                  !widget.conversation
                                                      .hasFiles!) ||
                                              (widget.conversation
                                                          .attachmentsUploaded !=
                                                      null &&
                                                  widget.conversation
                                                      .attachmentsUploaded!))
                                          ? Text(
                                              "${isEdited ? 'Edited  ' : ''}${widget.conversation.createdAt}",
                                              style: LMFonts.instance.regular
                                                  .copyWith(
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
            (conversation!.hasReactions ?? false)
                ? ValueListenableBuilder(
                    valueListenable: rebuildReactionsBar,
                    builder: (context, _, __) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Text(
                                    '${conversation!.conversationReactions![0].reaction} ${mappedReactions[conversation!.conversationReactions![0].reaction]!.length}'),
                              ),
                            ),
                            conversation!.conversationReactions!.length >= 2
                                ? GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 4.0),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: Text(
                                          '${conversation!.conversationReactions![1].reaction} ${mappedReactions[conversation!.conversationReactions![1].reaction]!.length}'),
                                    ),
                                  )
                                : const SizedBox(),
                            kHorizontalPaddingSmall,
                            conversation!.conversationReactions!.length > 2
                                ? GestureDetector(
                                    onTap: () {
                                      String selectedKey = 'All';
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        elevation: 5,
                                        useSafeArea: true,
                                        builder: (context) => Container(
                                          clipBehavior: Clip.none,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          height: 60.h,
                                          decoration: const BoxDecoration(
                                            color: kWhiteColor,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12.0),
                                              topRight: Radius.circular(12.0),
                                            ),
                                          ),
                                          child: StatefulBuilder(
                                            builder: (context, setChildState) =>
                                                Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                kVerticalPaddingXLarge,
                                                kVerticalPaddingLarge,
                                                Text(
                                                  'Reactions',
                                                  style: LMTheme.bold,
                                                ),
                                                kVerticalPaddingXLarge,
                                                SizedBox(
                                                  height: 30,
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border(
                                                            bottom: BorderSide(
                                                                color: kGrey3Color
                                                                    .withOpacity(
                                                                        0.2),
                                                                width: 1),
                                                          ),
                                                        ),
                                                        width: 100.w - 40,
                                                        height: 30,
                                                        child: ListView.builder(
                                                          itemCount:
                                                              mappedReactions
                                                                  .keys.length,
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemBuilder: (context,
                                                                  reactionIndex) =>
                                                              GestureDetector(
                                                            onTap: () {
                                                              setChildState(() {
                                                                selectedKey =
                                                                    mappedReactions
                                                                        .keys
                                                                        .elementAt(
                                                                            reactionIndex);
                                                              });
                                                            },
                                                            child: Container(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      8.0,
                                                                  vertical:
                                                                      5.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border: selectedKey ==
                                                                              mappedReactions.keys.elementAt(reactionIndex)
                                                                          ? Border(
                                                                              bottom: BorderSide(
                                                                                color: LMTheme.buttonColor,
                                                                                width: 1,
                                                                              ),
                                                                            )
                                                                          : null),
                                                              child: Text(
                                                                '${mappedReactions.keys.elementAt(reactionIndex)} (${mappedReactions.values.elementAt(reactionIndex)!.length})',
                                                                style: selectedKey ==
                                                                        mappedReactions
                                                                            .keys
                                                                            .elementAt(
                                                                                reactionIndex)
                                                                    ? LMTheme
                                                                        .medium
                                                                        .copyWith(
                                                                            color: LMTheme
                                                                                .buttonColor)
                                                                    : LMTheme
                                                                        .medium,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                kVerticalPaddingLarge,
                                                Expanded(
                                                  child: ListView.builder(
                                                    itemCount: mappedReactions[
                                                            selectedKey]!
                                                        .length,
                                                    itemBuilder:
                                                        (context, itemIndex) =>
                                                            Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              PictureOrInitial(
                                                                  imageUrl:
                                                                      userMeta![mappedReactions[selectedKey]![itemIndex].userId]
                                                                              ?.imageUrl ??
                                                                          '',
                                                                  fallbackText:
                                                                      userMeta![mappedReactions[selectedKey]![itemIndex].userId]
                                                                              ?.name ??
                                                                          ''),
                                                              kHorizontalPaddingLarge,
                                                              Text(
                                                                userMeta![mappedReactions[selectedKey]![itemIndex]
                                                                            .userId]
                                                                        ?.name ??
                                                                    '',
                                                                style: LMTheme
                                                                    .bold,
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            mappedReactions[
                                                                        selectedKey]![
                                                                    itemIndex]
                                                                .reaction,
                                                            style: LMTheme.bold
                                                                .copyWith(
                                                                    fontSize:
                                                                        20.sp),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                      ),
                                      child: const Text('...'),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      );
                    })
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Container _getReplyConversation() {
    if (replyToConversation == null) {
      return Container();
    }
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
                  child: getChatItemAttachmentTile(
                      replyConversationAttachments ?? [], replyToConversation!),
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
