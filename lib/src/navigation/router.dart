// GoRouter configuration
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/likeminds_chat_mm_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/media/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chat_action_bloc/chat_action_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chatroom_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_page.dart';
import 'package:likeminds_chat_mm_fl/src/views/conversation/bloc/conversation_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/conversation/media/media_forwarding.dart';
import 'package:likeminds_chat_mm_fl/src/views/explore/bloc/explore_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/explore/explore_page.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/bloc/home_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/home_page.dart';
import 'package:likeminds_chat_mm_fl/src/views/profile/bloc/profile_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/profile/profile_page.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/spinner.dart';

const startRoute = '/';
const homeRoute = '/home';
const chatRoute = '/chatroom/:id';
const participantsRoute = '/participants';
const exploreRoute = '/explore';
const profileRoute = '/profile';
const moderationRoute = '/moderation';
const mediaForwardRoute = '/media_forward/:mediaType';

final router = GoRouter(
  // initialLocation: homeRoute,
  routes: [
    GoRoute(
      path: startRoute,
      builder: (context, state) => BlocProvider(
        create: (context) => HomeBloc()
          ..add(
            InitHomeEvent(),
          ),
        child: const HomePage(),
      ),
    ),
    GoRoute(
      path: chatRoute,
      builder: (context, state) => MultiBlocProvider(
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
        ),
      ),
    ),
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
      path: mediaForwardRoute,
      name: "media_forward",
      builder: (context, state) => MediaForward(
        mediaFile: state.extra as File,
        mediaType:
            mapIntToMediaType(int.parse(state.params['mediaType'] ?? "1")),
      ),
    ),
  ],
);
