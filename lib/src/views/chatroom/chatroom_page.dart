import 'package:cached_network_image/cached_network_image.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/chat_bar.dart';
import 'package:likeminds_chat_mm_fl/src/views/conversation/bloc/conversation_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/spinner.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/back_button.dart' as BB;

import 'bloc/chatroom_bloc.dart';
import 'chatroom_components/chat_bubble.dart';
import 'chatroom_components/chatroom_menu.dart';
import 'enums/content_enum.dart';

class ChatroomPage extends StatefulWidget {
  final int chatroomId;
  const ChatroomPage({super.key, required this.chatroomId});

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  late final ConversationBloc conversationBloc;
  ScrollController listScrollController = ScrollController();
  PagingController<int, Conversation> pagedListController =
      PagingController<int, Conversation>(firstPageKey: 1);

  int _page = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // chatroomBloc = BlocProvider.of<ChatroomBloc>(context);
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
            final ChatRoom chatroom = state.getChatroomResponse.chatroom!;
            var pagedListView = BlocConsumer<ConversationBloc,
                    ConversationState>(
                listener: (context, state) {
                  if (state is ConversationLoaded) {
                    _page++;
                    pagedListController.appendPage(
                        state.getConversationResponse.conversationData!, _page);
                  }
                },
                builder: (context, state) => PagedListView(
                    pagingController: pagedListController,
                    scrollDirection: Axis.vertical,
                    reverse: true,
                    builderDelegate: PagedChildBuilderDelegate<Conversation>(
                      noItemsFoundIndicatorBuilder: (context) =>
                          const SizedBox(),
                      itemBuilder: (context, item, index) {
                        return ChatBubble(
                          key: Key(item.id.toString()),

                          message: item.answer,
                          time: "11:1$index",
                          profileImageUrl: "https://picsum.photos/200/300",
                          showReactions: false,
                          // onTap: () => print("Tapped $i"),
                        );
                      },
                    )));

            if (listScrollController.hasClients) {
              listScrollController
                  .jumpTo(listScrollController.position.maxScrollExtent);
            }

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
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: LMBranding.instance.headerColor,
                          borderRadius: BorderRadius.circular(21),
                        ),
                        child: Center(
                          child: chatroom.chatroomImageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: chatroom.chatroomImageUrl!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      color: LMBranding.instance.headerColor,
                                      borderRadius: BorderRadius.circular(21),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => const Center(
                                      child: Spinner(color: kWhiteColor)),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                )
                              : Text(
                                  "C${state.getChatroomResponse.chatroom?.id}",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        chatroom.header,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      ChatroomMenu(),
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
                const ChatBar(),
              ],
            );
          }

          return Container(color: Colors.red);
        },
      ),
    );
  }
}

List<Widget> getChats(BuildContext context) {
  List<Widget> chats = [];

  for (int i = 0; i < 10; i++) {
    chats.add(
      ChatBubble(
        key: Key(i.toString()),
        isSent: i % 2 == 0,
        message:
            "Lorem ipsum message $i dolor sit amet, consectetur adipiscing elit.",
        time: "11:1$i",
        profileImageUrl: "https://picsum.photos/200/300",
        showReactions: false,
        // onTap: () => print("Tapped $i"),
      ),
    );
  }

  chats.add(
    ChatBubble(
      key: UniqueKey(),
      isSent: false,
      message: "https://picsum.photos/700/600",
      time: "12:34",
      profileImageUrl: "https://picsum.photos/600/600",
      showReactions: false,
      contentType: ContentType.image,
      // onTap: () => print("Tapped $i"),
    ),
  );

  chats.add(
    ChatBubble(
      key: UniqueKey(),
      isSent: true,
      message:
          "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
      time: "12:34",
      profileImageUrl: "https://picsum.photos/600/600",
      showReactions: false,
      contentType: ContentType.video,
      // onTap: () => print("Tapped $i"),
    ),
  );

  return chats;
}
