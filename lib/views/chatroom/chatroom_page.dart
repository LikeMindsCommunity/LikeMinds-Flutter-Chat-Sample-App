import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat_example/constants.dart';
import 'package:group_chat_example/utils/ui_utils.dart';
import 'package:group_chat_example/widgets/spinner.dart';
import 'package:group_chat_example/widgets/back_button.dart' as BB;

import 'bloc/chatroom_bloc.dart';
import 'chatroom_components/chat_bubble.dart';

class ChatroomPage extends StatefulWidget {
  const ChatroomPage({super.key});

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  bool _isBlur = false;

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
              changeBlur,
            );

            return Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 64),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          BB.BackButton(),
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
                          Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.menu,
                              size: 24,
                              color: primaryColor,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        color: Colors.blue.withOpacity(0.2),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
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
                          horizontal: 24, vertical: 12),
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
                                        padding: EdgeInsets.all(4),
                                        onPressed: () {},
                                        icon:
                                            Icon(Icons.emoji_emotions_outlined),
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
                                        padding: EdgeInsets.all(4),
                                        onPressed: () {},
                                        icon: Icon(Icons.attach_file),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.send,
                                    color: Colors.white,
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
                ),
                Visibility(
                  visible: false,
                  child: Container(
                    height: getHeight(context),
                    width: getWidth(context),
                    color: Colors.red,
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

  void changeBlur() {
    setState(() {
      _isBlur = !_isBlur;
    });
  }
}

List<Widget> getChats(BuildContext context, void Function() changeBlur) {
  List<Widget> chats = [];

  for (int i = 0; i < 20; i++) {
    chats.add(
      ChatBubble(
        key: Key(i.toString()),
        makeBlur: changeBlur,
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

  return chats;
}
