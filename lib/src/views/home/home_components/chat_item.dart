// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/realtime/realtime.dart';
import 'package:likeminds_chat_mm_fl/src/utils/tagging/helpers/tagging_helper.dart';
import 'package:likeminds_chat_mm_fl/src/utils/ui_utils.dart';
import 'package:intl/intl.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/picture_or_initial.dart';
import 'package:swipe_to_action/swipe_to_action.dart';

class ChatItem extends StatefulWidget {
  final ChatRoom chatroom;
  final Conversation conversation;

  const ChatItem({
    super.key,
    required this.chatroom,
    required this.conversation,
  });

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  late ChatRoom chatroom;
  late bool _muteStatus;
  int? _unreadCount;

  @override
  void initState() {
    super.initState();
    chatroom = widget.chatroom;
    _unreadCount = chatroom.unseenCount;
    _muteStatus = chatroom.muteStatus ?? false;
  }

  @override
  Widget build(BuildContext context) {
    Conversation conversation = widget.conversation;
    String _name = chatroom.header;
    String _message = TaggingHelper.convertRouteToTag(conversation.answer);
    String _time = conversation.lastUpdated.toString();
    bool _isSecret = chatroom.isSecret ?? false;
    bool? hasAttachments = conversation.hasFiles;
    String? _avatarUrl = chatroom.chatroomImageUrl;

    return Swipeable(
      key: ValueKey(chatroom.id),
      onSwipe: (direction) {
        if (direction == SwipeDirection.startToEnd) {
          markRead(toast: true);
        } else if (direction == SwipeDirection.endToStart) {
          muteChatroom();
        }
      },
      allowedPointerKinds: const {
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.mouse,
        PointerDeviceKind.unknown,
      },
      background: Container(
        color: kGreyColor.withAlpha(60),
        child: Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.mark_chat_read,
                size: 18.sp,
                color: LMTheme.buttonColor,
              ),
              const SizedBox(height: 4),
              Text(
                "Mark as read",
                style: LMBranding.instance.fonts.regular.copyWith(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
      secondaryBackground: Container(
        color: kGreyColor.withAlpha(60),
        child: Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                _muteStatus ? Icons.notifications_off : Icons.notifications,
                size: 18.sp,
                color: LMTheme.buttonColor,
              ),
              const SizedBox(height: 4),
              Text(
                _muteStatus ? "Unmute notifications" : "Mute notifications",
                style: LMBranding.instance.fonts.regular.copyWith(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          LMRealtime.instance.chatroomId = chatroom.id;
          context.push("/chatroom/${chatroom.id}");
          markRead(toast: false);
        },
        child: Padding(
          padding: EdgeInsets.only(
            left: 5.w,
            right: 5.w,
            // top: 1.h,
          ),
          child: Container(
            width: getWidth(context),
            height: 10.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PictureOrInitial(
                  fallbackText: _name,
                  imageUrl: _avatarUrl,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _name,
                          style: LMBranding.instance.fonts.medium.copyWith(
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        (_message.isEmpty && (hasAttachments ?? false))
                            ? Row(children: [
                                Icon(
                                  Icons.attachment_outlined,
                                  color: kGreyColor,
                                  size: 12.sp,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Attachment",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: LMBranding.instance.fonts.regular
                                      .copyWith(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ])
                            : (_message.isNotEmpty && (hasAttachments ?? false))
                                ? Row(children: [
                                    Icon(
                                      Icons.attachment_outlined,
                                      color: kGreyColor,
                                      size: 12.sp,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _message,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: LMBranding.instance.fonts.regular
                                          .copyWith(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ])
                                : Text(
                                    _message,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: LMBranding.instance.fonts.regular
                                        .copyWith(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: _muteStatus,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Icon(
                      Icons.volume_off_outlined,
                      color: kGreyColor,
                      size: 16.sp,
                    ),
                  ),
                ),
                Visibility(
                  visible: _isSecret,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Icon(
                      Icons.lock_outline,
                      color: kGreyColor,
                      size: 16.sp,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      getTime(_time),
                      style: LMBranding.instance.fonts.regular.copyWith(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Visibility(
                      visible: _unreadCount != 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: LMTheme.buttonColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _unreadCount.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void markRead({bool toast = false}) async {
    final response = await locator<LikeMindsService>().markReadChatroom(
      MarkReadChatroomRequest(chatroomId: chatroom.id),
    );
    if (response.success) {
      setState(() {
        _unreadCount = 0;
      });
      if (toast) Fluttertoast.showToast(msg: "Chatroom marked as read");
    } else {
      Fluttertoast.showToast(msg: response.errorMessage!);
    }
  }

  void muteChatroom() async {
    final response =
        await locator<LikeMindsService>().muteChatroom(MuteChatroomRequest(
      chatroomId: chatroom.id,
      value: !_muteStatus,
    ));
    if (response.success) {
      setState(() {
        _muteStatus = !_muteStatus;
      });
      Fluttertoast.showToast(msg: "Mute status changed");
    } else {
      Fluttertoast.showToast(msg: response.errorMessage!);
    }
  }

  void leaveChatroom() async {
    if (chatroom.isSecret ?? false) {
      final response = await locator<LikeMindsService>()
          .followChatroom(FollowChatroomRequest(
        chatroomId: chatroom.id,
        value: false,
      ));
      if (response.success) {
        Fluttertoast.showToast(msg: "Chatroom left");
      } else {
        Fluttertoast.showToast(msg: response.errorMessage!);
      }
    } else {
      final response = await locator<LikeMindsService>()
          .deleteParticipant((DeleteParticipantRequestBuilder()
                ..chatroomId(chatroom.id)
                ..isSecret(true))
              .build());
      if (response.success) {
        Fluttertoast.showToast(msg: "Chatroom left");
      } else {
        Fluttertoast.showToast(msg: response.errorMessage!);
      }
    }
  }

  String getTime(String time) {
    final int _time = int.tryParse(time) ?? 0;
    final DateTime now = DateTime.now();
    final DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(_time);
    final Duration difference = now.difference(messageTime);
    if (difference.inDays > 0) {
      return DateFormat('dd/MM/yyyy').format(messageTime);
    }
    return DateFormat('kk:mm').format(messageTime);
  }
}
