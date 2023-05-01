import 'dart:async';

import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/bloc/home_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/home_components/chat_item.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/home_components/skeleton_list.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/picture_or_initial.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? communityName;
  String? userName;
  User? user;
  HomeBloc? homeBloc;

  @override
  void initState() {
    super.initState();
    UserLocalPreference userLocalPreference = UserLocalPreference.instance;
    userName = userLocalPreference.fetchUserData().name;
    communityName = userLocalPreference.fetchCommunityData()["community_name"];
  }

  @override
  Widget build(BuildContext context) {
    homeBloc = BlocProvider.of<HomeBloc>(context);
    return Scaffold(
        body: Column(
      children: [
        Container(
          width: 100.w,
          color: LMBranding.instance.headerColor,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 2.h,
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    alignment: Alignment.center,
                    child: Text(
                      communityName ?? "Chatrooms",
                      style: LMBranding.instance.fonts.bold
                          .copyWith(fontSize: 16.sp, color: kWhiteColor),
                    ),
                  ),
                  //   communityName ??
                  // ),
                  PictureOrInitial(
                    fallbackText: userName ?? "..",
                    size: 30.sp,
                    imageUrl: user?.imageUrl,
                    backgroundColor: LMTheme.buttonColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: BlocConsumer<HomeBloc, HomeState>(
            bloc: homeBloc,
            listener: (context, state) {},
            buildWhen: (previous, current) {
              if (previous is HomeLoaded && current is HomeLoading) {
                return false;
              }
              return true;
            },
            builder: (context, state) {
              if (state is HomeLoading) {
                return const SkeletonChatList();
              }

              if (state is HomeLoaded) {
                List<ChatItem> chatItems = getChats(context, state.response);
                return SafeArea(
                  top: false,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: chatItems.length,
                    itemBuilder: (context, index) {
                      return chatItems[index];
                    },
                  ),
                );
              }

              return Center(
                child: Container(),
              );
            },
          ),
        ),
      ],
    ));
  }
}

List<ChatItem> getChats(BuildContext context, GetHomeFeedResponse response) {
  List<ChatItem> chats = [];
  final List<ChatRoom> chatrooms = response.chatroomsData ?? [];
  final Map<String, Conversation> lastConversations =
      response.conversationMeta ?? {};
  final Map<int, User> userMeta = response.userMeta ?? {};

  for (int i = 0; i < chatrooms.length; i++) {
    chats.add(
      ChatItem(
        chatroom: chatrooms[i],
        conversation:
            lastConversations[chatrooms[i].lastConversationId.toString()]!,
        userMeta: userMeta,
      ),
    );
  }

  return chats;
}

Widget getShimmer() => Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade300,
      period: const Duration(seconds: 2),
      direction: ShimmerDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 12,
        ),
        child: Container(
          height: 16,
          width: 32.w,
          color: kWhiteColor,
        ),
      ),
    );
