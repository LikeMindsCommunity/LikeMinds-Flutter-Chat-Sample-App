import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/likeminds_chat_mm_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_chat_mm_fl/src/utils/ui_utils.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/participants_bloc/participants_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/profile/bloc/profile_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/profile/profile_page.dart';

import 'package:likeminds_chat_mm_fl/src/widgets/back_button.dart' as BB;

class ChatroomParticipantsPage extends StatefulWidget {
  final ChatRoom chatroom;
  ChatroomParticipantsPage({super.key, required this.chatroom});

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
      body: BlocConsumer(
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
              return Column(
                children: [
                  const SizedBox(height: 72),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const BB.BackButton(),
                        kHorizontalPaddingMedium,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Participants",
                              style: GoogleFonts.montserrat(
                                fontSize: kFontMedium,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            kVerticalPaddingXSmall,
                            Text(
                              "${widget.chatroom.participantCount ?? '--'} participants",
                              style: GoogleFonts.roboto(
                                fontSize: kFontSmall,
                                fontWeight: FontWeight.w300,
                              ),
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
    );
  }

  Widget _buildParticipantsList() {
    return PagedListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      pagingController: _pagingController,
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
      onTap: () {
        Route route = MaterialPageRoute(
          builder: (BuildContext context) => BlocProvider<ProfileBloc>(
            create: (BuildContext context) =>
                ProfileBloc()..add(InitProfileEvent()),
            child: const ProfilePage(
              isSelf: false,
            ),
          ),
        );
        Navigator.push(context, route);
      },
      child: Container(
        width: getWidth(context),
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lmBranding.headerColor,
              ),
              child: participant.imageUrl == null
                  ? Text(
                      getInitials(participant.name),
                      style: TextStyle(
                        color: kWhiteColor,
                        fontSize: 20,
                      ),
                    )
                  : CircleAvatar(
                      backgroundImage: NetworkImage(participant.imageUrl!),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                participant.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Text(
            //   participant.customTitle ?? "",
            //   style: GoogleFonts.montserrat(
            //     fontSize: 16,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
            // const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
