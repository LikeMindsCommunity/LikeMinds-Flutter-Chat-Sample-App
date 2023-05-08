import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/lm_branding.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/ui_constants.dart';

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
          color: isJoined ? kGreyColor : LMBranding.instance.headerColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              Icon(
                isJoined ? Icons.check : Icons.add,
                size: 24,
                color: isJoined ? LMBranding.instance.headerColor : kWhiteColor,
              ),
              const SizedBox(width: 4),
              Text(
                isJoined ? "Joined" : "Join",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      isJoined ? LMBranding.instance.headerColor : kWhiteColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
