import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat_example/constants.dart';

class JoinButton extends StatelessWidget {
  final Function() onTap;
  final bool isJoined;

  const JoinButton({
    Key? key,
    required this.onTap,
    required this.isJoined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isJoined ? Colors.grey[300] : primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              Icon(
                isJoined ? Icons.check : Icons.add,
                size: 24,
                color: isJoined ? primaryColor : Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                isJoined ? "Joined" : "Join",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isJoined ? primaryColor : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
