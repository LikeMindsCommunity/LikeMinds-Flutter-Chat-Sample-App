import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/views/explore/explore_components/join_button.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/picture_or_initial.dart';
import 'package:overlay_support/overlay_support.dart';

class ExploreItem extends StatefulWidget {
  const ExploreItem({
    Key? key,
    required this.chatroom,
    required this.onTap,
    required this.refresh,
  }) : super(key: key);

  final ChatRoom chatroom;
  final Function() onTap;
  final Function() refresh;

  @override
  State<ExploreItem> createState() => _ExploreItemState();
}

class _ExploreItemState extends State<ExploreItem> {
  ValueNotifier<bool> isJoinedNotifier = ValueNotifier(false);
  ChatRoom? chatroom;
  User user = UserLocalPreference.instance.fetchUserData();

  @override
  Widget build(BuildContext context) {
    chatroom = widget.chatroom;
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: SizedBox(
        height: 120,
        // color: Colors.red,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 17.w,
                    width: 17.w,
                    child: PictureOrInitial(
                      fallbackText: chatroom!.header,
                      imageUrl: chatroom!.chatroomImageUrl,
                    ),
                  ),
                  chatroom!.isPinned != null && chatroom!.isPinned!
                      ? Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: kWhiteColor,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: LMTheme.buttonColor,
                              ),
                              child: Icon(
                                Icons.push_pin,
                                color: kWhiteColor,
                                size: 10.sp,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chatroom!.header,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: LMTheme.medium.copyWith(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.people_outline,
                                    color: kGrey3Color,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    chatroom!.participantCount.toString(),
                                    style: LMTheme.medium.copyWith(
                                      color: kGrey3Color,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.message_outlined,
                                    color: kGrey3Color,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    chatroom!.totalResponseCount?.toString() ??
                                        '0',
                                    style: LMTheme.medium.copyWith(
                                      color: kGrey3Color,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ValueListenableBuilder(
                            valueListenable: isJoinedNotifier,
                            builder: (context, _, __) {
                              return JoinButton(
                                chatroom: chatroom!,
                                onTap: () async {
                                  if (chatroom!.followStatus == true) {
                                    LMResponse response;
                                    if (chatroom!.isSecret == null ||
                                        chatroom!.isSecret! == false) {
                                      response = await locator<
                                              LikeMindsService>()
                                          .followChatroom(
                                              (FollowChatroomRequestBuilder()
                                                    ..chatroomId(chatroom!.id)
                                                    ..memberId(user.id)
                                                    ..value(false))
                                                  .build());
                                    } else {
                                      response = await locator<
                                              LikeMindsService>()
                                          .deleteParticipant(
                                              (DeleteParticipantRequestBuilder()
                                                    ..chatroomId(chatroom!.id)
                                                    ..memberId(
                                                        user.userUniqueId)
                                                    ..isSecret(true))
                                                  .build());
                                    }
                                    chatroom!.followStatus = false;
                                    isJoinedNotifier.value =
                                        !isJoinedNotifier.value;
                                    if (!response.success) {
                                      chatroom!.followStatus = true;
                                      isJoinedNotifier.value =
                                          !isJoinedNotifier.value;
                                      toast(response.errorMessage ??
                                          'An error occurred');
                                    }
                                  } else {
                                    LMResponse response =
                                        await locator<LikeMindsService>()
                                            .followChatroom(
                                                (FollowChatroomRequestBuilder()
                                                      ..chatroomId(chatroom!.id)
                                                      ..memberId(user.id)
                                                      ..value(true))
                                                    .build());
                                    chatroom!.followStatus = true;
                                    isJoinedNotifier.value =
                                        !isJoinedNotifier.value;
                                    if (!response.success) {
                                      chatroom!.followStatus = false;
                                      isJoinedNotifier.value =
                                          !isJoinedNotifier.value;
                                      toast(response.errorMessage ??
                                          'An error occurred');
                                    }
                                  }
                                },
                              );
                            }),
                        const SizedBox(width: 4),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      chatroom!.title,
                      style: LMTheme.regular.copyWith(color: kGrey3Color),
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
