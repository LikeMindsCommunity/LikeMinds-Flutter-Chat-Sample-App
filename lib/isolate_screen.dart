import 'package:flutter/material.dart';
import 'package:group_chat_example/views/chatroom/chatroom_components/chat_bubble.dart';

class IsolatePage extends StatefulWidget {
  const IsolatePage({super.key});

  @override
  State<IsolatePage> createState() => _IsolatePageState();
}

class _IsolatePageState extends State<IsolatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.8),
      body: Center(
        child: ChatBubble(
          key: UniqueKey(),
          message: "Hello",
          isSent: false,
        ),
      ),
    );
  }
}
