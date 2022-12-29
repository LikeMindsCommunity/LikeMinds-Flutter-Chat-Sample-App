import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat_example/utils/ui_utils.dart';

import 'package:group_chat_example/widgets/back_button.dart' as BB;

class ChatroomParticipantsPage extends StatefulWidget {
  const ChatroomParticipantsPage({super.key});

  @override
  State<ChatroomParticipantsPage> createState() =>
      _ChatroomParticipantsPageState();
}

class _ChatroomParticipantsPageState extends State<ChatroomParticipantsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 72),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BB.BackButton(),
                Text(
                  "Chatroom Participants",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 32),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "10 participants",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w300,
            ),
          ),
          Expanded(child: _buildParticipantsList()),
        ],
      ),
    );
  }

  Widget _buildParticipantsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return const ParticipantItem(
          name: "John Doe",
          profilePic: "https://picsum.photos/200/300",
          role: "Admin",
        );
      },
    );
  }
}

class ParticipantItem extends StatelessWidget {
  final String name;
  final String profilePic;
  final String role;

  const ParticipantItem({
    super.key,
    required this.name,
    required this.profilePic,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getWidth(context),
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(profilePic),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            name,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            role,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          // GestureDetector(
          //   onTap: () {
          //     Fluttertoast.showToast(
          //       msg: "You can't remove yourself",
          //       toastLength: Toast.LENGTH_SHORT,
          //       gravity: ToastGravity.BOTTOM,
          //       timeInSecForIosWeb: 1,
          //       backgroundColor: Colors.grey[800],
          //       textColor: Colors.white,
          //       fontSize: 16.0,
          //     );
          //   },
          //   child: Container(
          //     width: 24,
          //     height: 24,
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       color: Colors.red,
          //     ),
          //     child: const Icon(
          //       Icons.close,
          //       color: Colors.white,
          //       size: 16,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
