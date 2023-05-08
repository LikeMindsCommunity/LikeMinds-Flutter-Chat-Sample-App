import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/likeminds_chat_mm_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/analytics/analytics.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/ui_utils.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/participants_bloc/participants_bloc.dart';

import 'package:likeminds_chat_mm_fl/src/widgets/back_button.dart' as BB;
import 'package:likeminds_chat_mm_fl/src/widgets/picture_or_initial.dart';

class ChatroomParticipantsPage extends StatefulWidget {
  final ChatRoom chatroom;
  const ChatroomParticipantsPage({super.key, required this.chatroom});

  @override
  State<ChatroomParticipantsPage> createState() =>
      _ChatroomParticipantsPageState();
}

class _ChatroomParticipantsPageState extends State<ChatroomParticipantsPage> {
  ParticipantsBloc? participantsBloc;
  final PagingController<int, User> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    participantsBloc = ParticipantsBloc();
    participantsBloc!.add(
      GetParticipants(
        getParticipantsRequest: (GetParticipantsRequestBuilder()
              ..chatroomId(widget.chatroom.id)
              ..page(1)
              ..pageSize(10)
              ..isSecret(widget.chatroom.isSecret ?? false))
            .build(),
      ),
    );
    _addPaginationListener();
  }

  int _page = 1;

  _addPaginationListener() {
    _pagingController.addPageRequestListener((pageKey) {
      participantsBloc!.add(
        GetParticipants(
          getParticipantsRequest: (GetParticipantsRequestBuilder()
                ..chatroomId(widget.chatroom.id)
                ..page(pageKey)
                ..pageSize(10)
                ..isSecret(widget.chatroom.isSecret ?? false))
              .build(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer(
            bloc: participantsBloc,
            listener: (context, state) {
              if (state is ParticipantsLoaded) {
                _page++;
                if (state.getParticipantsResponse.participants!.isEmpty) {
                  _pagingController.appendLastPage(
                    state.getParticipantsResponse.participants!,
                  );
                } else {
                  _pagingController.appendPage(
                    state.getParticipantsResponse.participants!,
                    _page,
                  );
                }
              } else if (state is ParticipantsError) {
                _pagingController.error = state.message;
              }
            },
            buildWhen: (prev, curr) {
              if (curr is ParticipantsPaginationLoading) {
                return false;
              }
              return true;
            },
            builder: (context, state) {
              if (state is ParticipantsLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ParticipantsLoaded) {
                LMAnalytics.get()
                    .logEvent(AnalyticsKeys.viewChatroomParticipants, {
                  'chatroom_id': widget.chatroom.id,
                  'community_id': widget.chatroom.communityId,
                  'source': 'chatroom_overflow_menu',
                });
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const BB.BackButton(),
                          kHorizontalPaddingXLarge,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Participants",
                                style: LMFonts.instance.bold.copyWith(
                                  fontSize: 12.sp,
                                ),
                              ),
                              kVerticalPaddingSmall,
                              Text(
                                "${widget.chatroom.participantCount ?? '--'} participants",
                                style: LMFonts.instance.regular,
                              ),
                            ],
                          ),
                          const SizedBox(width: 32),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(child: _buildParticipantsList()),
                  ],
                );
              } else if (state is ParticipantsError) {
                return Center(
                  child: Text(state.message),
                );
              }
              return const SizedBox();
            }),
      ),
    );
  }

  Widget _buildParticipantsList() {
    return PagedListView(
      padding: EdgeInsets.zero,
      pagingController: _pagingController,
      physics: const ClampingScrollPhysics(),
      builderDelegate: PagedChildBuilderDelegate<User>(
        itemBuilder: (context, item, index) {
          return ParticipantItem(
            participant: item,
          );
        },
      ),
    );
  }
}

class ParticipantItem extends StatelessWidget {
  final User participant;
  final LMBranding lmBranding = LMBranding.instance;

  ParticipantItem({super.key, required this.participant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: getWidth(context),
        height: 8.h,
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            PictureOrInitial(
              fallbackText: participant.name,
              imageUrl: participant.imageUrl,
              size: 32.sp,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                participant.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LMTheme.medium.copyWith(
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
