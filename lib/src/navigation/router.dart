// GoRouter configuration
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/media/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/ui_utils.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chatroom_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/participants_bloc/participants_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_page.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/views/chatroom_participants_page.dart';
import 'package:likeminds_chat_mm_fl/src/views/conversation/bloc/conversation_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/media_forwarding.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/media_preview.dart';
import 'package:likeminds_chat_mm_fl/src/views/explore/bloc/explore_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/explore/explore_page.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/bloc/home_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/home_page.dart';
import 'package:likeminds_chat_mm_fl/src/views/profile/bloc/profile_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/profile/profile_page.dart';
import 'package:sizer/sizer.dart';

const startRoute = '/';
const homeRoute = '/home';
const chatRoute = '/chatroom/:id';
const participantsRoute = '/participants';
const exploreRoute = '/explore';
const profileRoute = '/profile';
const moderationRoute = '/moderation';
const mediaForwardRoute = '/media_forward/:chatroomId';
const mediaPreviewRoute = '/media_preview/:messageId';

final router = GoRouter(
  routes: [
    GoRoute(
        path: startRoute,
        builder: (context, state) {
          return const HomePage();
        }),
    GoRoute(
        path: chatRoute,
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<ChatroomBloc>(
                create: (context) => ChatroomBloc()
                  ..add(
                    InitChatroomEvent(
                      GetChatroomRequest(
                        chatroomId: int.parse(state.params['id'] ?? "0"),
                      ),
                    ),
                  ),
              ),
              BlocProvider<ConversationBloc>(
                create: (context) => ConversationBloc(),
              ),
            ],
            child: ChatroomPage(
              chatroomId: int.parse(state.params['id'] ?? "0"),
              isRoot: state.queryParams['isRoot']?.toBoolean() ?? false,
            ),
          );
        }),
    GoRoute(
      path: exploreRoute,
      builder: (context, state) => BlocProvider(
        create: (context) => ExploreBloc()..add(InitExploreEvent()),
        child: const ExplorePage(),
      ),
    ),
    GoRoute(
      path: profileRoute,
      builder: (context, state) => BlocProvider(
        create: (context) => ProfileBloc()..add(InitProfileEvent()),
        child: const ProfilePage(),
      ),
    ),
    GoRoute(
      path: participantsRoute,
      builder: (context, state) => BlocProvider<ParticipantsBloc>(
        create: (context) => ParticipantsBloc(),
        child: ChatroomParticipantsPage(
          chatroom: state.extra as ChatRoom,
        ),
      ),
    ),
    GoRoute(
      path: mediaForwardRoute,
      name: "media_forward",
      builder: (context, state) => MediaForward(
        media: state.extra as List<Media>,
        chatroomId: int.parse(state.params['chatroomId']!),
      ),
    ),
    GoRoute(
      path: mediaPreviewRoute,
      name: "media_preview",
      builder: (context, state) => MediaPreview(
        conversationAttachments:
            (state.extra as List<dynamic>)[0] as List<dynamic>,
        chatroom: (state.extra as List<dynamic>)[1],
        messageId: int.parse(state.params['messageId']!),
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: LMTheme.headerColor,
    body: Center(
      child: Text(
        "An error occurred\nTry again later",
        style: LMTheme.medium.copyWith(
          color: Colors.white,
          fontSize: 24.sp,
        ),
      ),
    ),
  ),
);
