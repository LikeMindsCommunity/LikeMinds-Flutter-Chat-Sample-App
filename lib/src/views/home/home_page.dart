import 'package:go_router/go_router.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/utils/tagging/helpers/tagging_helper.dart';
// import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chatroom_bloc.dart';
// import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_page.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/bloc/home_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/home_components/chat_item.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/home_components/skeleton_list.dart';
import 'package:likeminds_chat_mm_fl/src/views/profile/bloc/profile_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/profile/profile_page.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/picture_or_initial.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? communityName;
  String? userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeLoaded) {
            Fluttertoast.showToast(msg: "Chats loaded");
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return const SkeletonChatList();
          }

          if (state is HomeLoaded) {
            UserLocalPreference userLocalPreference =
                UserLocalPreference.instance;
            final user = userLocalPreference.fetchUserData();
            final GetHomeFeedResponse response = state.response;
            communityName = response.communityMeta?.values.first.name;
            userName = response.userMeta?[user.id.toString()]?.name;
            List<ChatItem> chatItems = getChats(context, state.response);
            return Column(
              children: [
                // const SizedBox(height: 72),
                Container(
                  height: 16.h,
                  width: 100.w,
                  color: LMBranding.instance.headerColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            communityName ?? "Chatrooms",
                            style: LMBranding.instance.fonts.bold
                                .copyWith(fontSize: 16.sp, color: kWhiteColor),
                          ),
                        ),
                        GestureDetector(
                            onTap: () {
                              Route route = MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    BlocProvider<ProfileBloc>(
                                  create: (BuildContext context) =>
                                      ProfileBloc()..add(InitProfileEvent()),
                                  child: const ProfilePage(
                                    isSelf: true,
                                  ),
                                ),
                              );
                              Navigator.push(context, route);
                            },
                            child: PictureOrInitial(
                              fallbackText: userName ?? "..",
                              size: 30.sp,
                              imageUrl: user.imageUrl,
                              backgroundColor: LMTheme.buttonColor,
                            )),
                      ],
                    ),
                  ),
                ),
                // const SizedBox(height: 18),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    itemCount: chatItems.length,
                    itemBuilder: (context, index) {
                      // if (index == 0) {
                      //   return const ExploreSpacesBar();
                      // }
                      return chatItems[index];
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text(""),
          );
        },
      ),
    );
  }
}

List<ChatItem> getChats(BuildContext context, GetHomeFeedResponse response) {
  List<ChatItem> chats = [];
  final List<ChatRoom> chatrooms = response.chatroomsData ?? [];
  final Map<String, Conversation> lastConversations =
      response.conversationMeta ?? {};

  for (int i = 0; i < chatrooms.length; i++) {
    chats.add(ChatItem(
      name: chatrooms[i].header,
      message: TaggingHelper.convertRouteToTag(
          lastConversations[chatrooms[i].lastConversationId.toString()]
                  ?.answer ??
              "..."),
      time: lastConversations[chatrooms[i].lastConversationId.toString()]
              ?.lastUpdated
              .toString() ??
          "...",
      avatarUrl: chatrooms[i].chatroomImageUrl,
      unreadCount: chatrooms[i].unseenCount ?? 0,
      onTap: () {
        context.push("/chatroom/${chatrooms[i].id}");
      },
    ));
  }

  return chats;
}
