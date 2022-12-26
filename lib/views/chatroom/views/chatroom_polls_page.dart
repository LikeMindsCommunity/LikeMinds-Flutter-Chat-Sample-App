import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import "../../../widgets/back_button.dart" as BB;

class ChatroomPollsPage extends StatefulWidget {
  const ChatroomPollsPage({super.key});

  @override
  State<ChatroomPollsPage> createState() => _ChatroomPollsPageState();
}

class _ChatroomPollsPageState extends State<ChatroomPollsPage> {
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
                  "Create Poll",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 32),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
