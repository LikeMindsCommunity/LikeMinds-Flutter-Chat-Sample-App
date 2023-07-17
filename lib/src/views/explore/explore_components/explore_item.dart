import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
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
  User user = UserLocalPreference.instance.fetchUserData();

  @override
  Widget build(BuildContext context) {
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
              SizedBox(
                height: 64,
                width: 64,
                child: PictureOrInitial(
                    fallbackText: widget.chatroom.header,
                    imageUrl: widget.chatroom.chatroomImageUrl),
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
                                widget.chatroom.header,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    color: Colors.grey[600],
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.chatroom.participantCount.toString(),
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.message_outlined,
                                    color: Colors.grey[600],
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.chatroom.totalResponseCount
                                            ?.toString() ??
                                        '0',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[600],
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
                                chatroom: widget.chatroom,
                                onTap: () async {
                                  if (widget.chatroom.followStatus == true) {
                                    LMResponse response;
                                    if (widget.chatroom.isSecret == null ||
                                        widget.chatroom.isSecret! == false) {
                                      response = await locator<
                                              LikeMindsService>()
                                          .followChatroom(
                                              (FollowChatroomRequestBuilder()
                                                    ..chatroomId(
                                                        widget.chatroom.id)
                                                    ..memberId(user.id)
                                                    ..value(false))
                                                  .build());
                                    } else {
                                      response = await locator<
                                              LikeMindsService>()
                                          .deleteParticipant(
                                              (DeleteParticipantRequestBuilder()
                                                    ..chatroomId(
                                                        widget.chatroom.id)
                                                    ..memberId(
                                                        user.userUniqueId)
                                                    ..isSecret(true))
                                                  .build());
                                    }
                                    widget.chatroom.followStatus = false;
                                    isJoinedNotifier.value =
                                        !isJoinedNotifier.value;
                                    if (!response.success) {
                                      widget.chatroom.followStatus = true;
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
                                                      ..chatroomId(
                                                          widget.chatroom.id)
                                                      ..memberId(user.id)
                                                      ..value(true))
                                                    .build());
                                    widget.chatroom.followStatus = true;
                                    isJoinedNotifier.value =
                                        !isJoinedNotifier.value;
                                    if (!response.success) {
                                      widget.chatroom.followStatus = false;
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
                      widget.chatroom.title,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
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
