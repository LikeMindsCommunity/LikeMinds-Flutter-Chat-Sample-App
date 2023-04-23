// GoRouter configuration
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/likeminds_chat_mm_fl.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chatroom_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_page.dart';
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

final router = GoRouter(
  // initialLocation: homeRoute,
  routes: [
    // GoRoute(
    //     path: startRoute,
    //     builder: (context, state) => Spinner(
    //           color: LMBranding.instance.headerColor,
    //         )),
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
      builder: (context, state) => BlocProvider(
        create: (context) => ChatroomBloc()
          ..add(
            InitChatroomEvent(
              GetChatroomRequest(
                chatroomId: int.parse(state.params['id'] ?? "0"),
              ),
            ),
          ),
        child: ChatroomPage(chatroomId: int.parse(state.params['id'] ?? "0")),
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
  ],
);
