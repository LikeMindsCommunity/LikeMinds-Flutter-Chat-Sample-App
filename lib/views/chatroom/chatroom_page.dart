import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat_example/constants.dart';
import 'package:group_chat_example/utils/ui_utils.dart';
import 'package:group_chat_example/widgets/spinner.dart';
import 'package:group_chat_example/widgets/back_button.dart' as BB;
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';

import 'bloc/chatroom_bloc.dart';
import 'chatroom_components/chat_bubble.dart';
import 'chatroom_components/chatroom_menu.dart';
import 'enums/content_enum.dart';

class ChatroomPage extends StatefulWidget {
  const ChatroomPage({super.key});

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  ScrollController listScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
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
            List<Widget> chatBubbles = [];
            chatBubbles = getChats(
              context,
            );

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
                      GestureDetector(
                        onTap: () {
                          Fluttertoast.showToast(msg: "Add profile screen");
                        },
                        child: Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(21),
                          ),
                          child: Center(
                            child: Text(
                              "Pa",
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Chatroom ${state.chatroomId}",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      ChatroomMenu(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    color: Colors.blue.withOpacity(0.2),
                    child: ListView.builder(
                      controller: listScrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: chatBubbles.length,
                      itemBuilder: (context, index) {
                        return chatBubbles[index];
                      },
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    padding: const EdgeInsets.all(4),
                                    onPressed: () {},
                                    icon: Icon(Icons.emoji_emotions_outlined),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Type a message",
                                        hintStyle: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    padding: const EdgeInsets.all(4),
                                    onPressed: () {},
                                    icon: const Icon(Icons.attach_file),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              Fluttertoast.showToast(msg: "Send message");
                            },
                            child: Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
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

  return chats;
}
