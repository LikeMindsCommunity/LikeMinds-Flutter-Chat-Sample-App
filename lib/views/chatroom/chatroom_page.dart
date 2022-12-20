import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bloc/chatroom_bloc.dart';

class ChatroomPage extends StatefulWidget {
  const ChatroomPage({super.key});

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        const SizedBox(height: 72),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Chatroom",
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // GestureDetector(
              //   onTap: () {
              //     Fluttertoast.showToast(msg: "Add profile screen");
              //   },
              //   child: Container(
              //     height: 42,
              //     width: 42,
              //     decoration: BoxDecoration(
              //       color: const Color.fromARGB(255, 74, 0, 201),
              //       borderRadius: BorderRadius.circular(21),
              //     ),
              //     child: Center(
              //       child: Text(
              //         "KA",
              //         style: GoogleFonts.montserrat(
              //           fontSize: 16,
              //           fontWeight: FontWeight.bold,
              //           color: Colors.white,
              //         ),
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
        BlocConsumer<ChatroomBloc, ChatroomState>(
          listener: (context, state) {
            // TODO: implement listener
          },
          builder: (context, state) {
            return Container();
          },
        )
      ],
    ));
  }
}
