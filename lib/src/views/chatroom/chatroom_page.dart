import 'package:flutter/gestures.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/chatroom/conversation_utils.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/utils/simple_bloc_observer.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chat_action_bloc/chat_action_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/chat_bar.dart';
import 'package:likeminds_chat_mm_fl/src/views/conversation/bloc/conversation_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/picture_or_initial.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/spinner.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/back_button.dart' as BB;

import 'bloc/chatroom_bloc.dart';
import 'chatroom_components/chat_bubble.dart';
import 'chatroom_components/chatroom_menu.dart';

class ChatroomPage extends StatefulWidget {
  final int chatroomId;
  const ChatroomPage({super.key, required this.chatroomId});

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  ChatActionBloc? chatActionBloc;
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  ValueNotifier rebuildConversationList = ValueNotifier(false);
  ConversationBloc? conversationBloc;
  Map<int, User> userMeta = <int, User>{};
  ChatRoom? chatroom;
  User currentUser = UserLocalPreference.instance.fetchUserData();

  PagingController<int, Conversation> pagedListController =
      PagingController<int, Conversation>(firstPageKey: 1);

  int _page = 1;

  _addPaginationListener() {
    pagedListController.addPageRequestListener(
      (pageKey) {
        conversationBloc!.add(
          GetConversation(
            getConversationRequest: (GetConversationRequestBuilder()
                  ..chatroomId(widget.chatroomId)
                  ..page(pageKey)
                  ..pageSize(500)
                  ..minTimestamp(0)
                  ..maxTimestamp(currentTime))
                .build(),
          ),
        );
      },
    );
  }

  void addConversationToPagedList(Conversation conversation) {
    List<Conversation> conversationList =
        pagedListController.itemList ?? <Conversation>[];

    if (conversationList.isNotEmpty) {
      if (conversationList.first.date != conversation.date) {
        conversationList.add(Conversation(
          isTimeStamp: true,
          id: 1,
          answer: conversation.date!,
          communityId: chatroom!.communityId!,
          createdAt: conversation.date!,
          header: conversation.date,
        ));
      }
    }
    conversationList.insert(0, conversation);
    if (!userMeta.containsKey(currentUser.id)) {
      userMeta[currentUser.id] = currentUser;
    }
    pagedListController.itemList = conversationList;
    rebuildConversationList.value = !rebuildConversationList.value;
  }

  @override
  void initState() {
    super.initState();
    Bloc.observer = SimpleBlocObserver();
    _addPaginationListener();
    conversationBloc = ConversationBloc()
      ..add(
        MarkReadChatroomEvent(chatroomId: widget.chatroomId),
      );
  }

  @override
  void dispose() {
    pagedListController.dispose();
    super.dispose();
  }

  void updatePagingControllers(Object? state) {
    if (state is ConversationLoaded) {
      _page++;

      if (state.getConversationResponse.userMeta != null) {
        userMeta.addAll(state.getConversationResponse.userMeta!);
      }
      List<Conversation>? conversationData =
          state.getConversationResponse.conversationData;
      conversationData = addTimeStampInConversationList(
          conversationData, chatroom!.communityId!);
      if (state.getConversationResponse.conversationData == null ||
          state.getConversationResponse.conversationData!.isEmpty ||
          state.getConversationResponse.conversationData!.length < 500) {
        pagedListController.appendLastPage(conversationData ?? []);
      } else {
        pagedListController.appendPage(conversationData!, _page);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // conversationBloc = BlocProvider.of<ConversationBloc>(context);
    chatActionBloc = BlocProvider.of<ChatActionBloc>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<ChatroomBloc, ChatroomState>(
        listener: (context, state) {
          if (state is ChatroomLoaded) {
            Fluttertoast.showToast(msg: "Chatroom loaded");
          }
        },
        builder: (context, state) {
          if (state is ChatroomLoading) {
            return const Spinner();
          }

          if (state is ChatroomLoaded) {
            chatroom = state.getChatroomResponse.chatroom!;

            var pagedListView = ValueListenableBuilder(
                valueListenable: rebuildConversationList,
                builder: (context, _, __) {
                  return BlocConsumer<ConversationBloc, ConversationState>(
                    bloc: conversationBloc,
                    listener: (context, state) =>
                        updatePagingControllers(state),
                    builder: (context, state) => PagedListView(
                      pagingController: pagedListController,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      reverse: true,
                      scrollDirection: Axis.vertical,
                      builderDelegate: PagedChildBuilderDelegate<Conversation>(
                        noItemsFoundIndicatorBuilder: (context) =>
                            const SizedBox(
                          height: 10,
                        ),
                        itemBuilder: (context, item, index) {
                          if (item.isTimeStamp != null && item.isTimeStamp!) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kWhiteColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    item.answer,
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            );
                          }
                          // item.
                          return ChatBubble(
                            key: Key(item.id.toString()),
                            message: item.answer,
                            time: item.createdAt,
                            isSent: item.userId == null
                                ? item.memberId == currentUser.id
                                : item.userId == currentUser.id,
                            user: userMeta[item.userId ?? item.memberId]!,
                            showReactions: true,
                            // onTap: () => print("Tapped $i"),
                          );
                        },
                      ),
                    ),
                  );
                });

            return Column(
              children: [
                const SizedBox(height: 64),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const BB.BackButton(),
                      const SizedBox(width: 18),
                      PictureOrInitial(
                        fallbackText: chatroom!.header,
                        imageUrl: chatroom?.chatroomImageUrl,
                        size: 28.sp,
                        fontSize: 14.sp,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        chatroom!.header,
                        style: LMTheme.medium.copyWith(
                          fontSize: 14.sp,
                        ),
                      ),
                      const Spacer(),
                      ChatroomMenu(
                        chatroom: chatroom!,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Container(
                    color: LMBranding.instance.headerColor.withOpacity(0.2),
                    child: pagedListView,
                  ),
                ),
                BlocConsumer(
                    bloc: chatActionBloc,
                    listener: (context, state) {
                      if (state is ConversationPosted) {
                        addConversationToPagedList(
                          state.postConversationResponse.conversation!,
                        );
                      }
                    },
                    builder: (context, state) {
                      return ChatBar(chatroomId: widget.chatroomId);
                    }),
              ],
            );
          }

          return Container(color: Colors.red);
        },
      ),
    );
  }
}

// List<Widget> getChats(BuildContext context) {
//   List<Widget> chats = [];

//   for (int i = 0; i < 10; i++) {
//     chats.add(
//       ChatBubble(
//         key: Key(i.toString()),
//         isSent: i % 2 == 0,
//         message:
//             "Lorem ipsum message $i dolor sit amet, consectetur adipiscing elit.",
//         time: "11:1$i",
//         profileImageUrl: "https://picsum.photos/200/300",
//         showReactions: false,
//         // onTap: () => print("Tapped $i"),
//       ),
//     );
//   }

//   chats.add(
//     ChatBubble(
//       key: UniqueKey(),
//       isSent: false,
//       message: "https://picsum.photos/700/600",
//       time: "12:34",
//       profileImageUrl: "https://picsum.photos/600/600",
//       showReactions: false,
//       contentType: ContentType.image,
//       // onTap: () => print("Tapped $i"),
//     ),
//   );

//   chats.add(
//     ChatBubble(
//       key: UniqueKey(),
//       isSent: true,
//       message:
//           "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
//       time: "12:34",
//       profileImageUrl: "https://picsum.photos/600/600",
//       showReactions: false,
//       contentType: ContentType.video,
//       // onTap: () => print("Tapped $i"),
//     ),
//   );

//   return chats;
// }
