import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/lm_branding.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/asset_constants.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/ui_constants.dart';

class JoinButton extends StatelessWidget {
  final Function() onTap;
  final ChatRoom chatroom;

  const JoinButton({
    Key? key,
    required this.onTap,
    required this.chatroom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isJoined = chatroom.followStatus ?? false;
    return chatroom.isSecret != null && !chatroom.isSecret!
        ? GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: isJoined
                    ? LMBranding.instance.headerColor.withAlpha(30)
                    : LMBranding.instance.headerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    isJoined
                        ? SvgPicture.asset(
                            kAssetNotificationCheckIcon,
                            height: 26,
                            color: isJoined
                                ? LMBranding.instance.headerColor
                                : kWhiteColor,
                          )
                        : Icon(
                            Icons.notification_add,
                            size: 24,
                            color: isJoined
                                ? LMBranding.instance.headerColor
                                : kWhiteColor,
                          ),
                    const SizedBox(width: 4),
                    Text(
                      isJoined ? "Joined" : "Join",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isJoined
                            ? LMBranding.instance.headerColor
                            : kWhiteColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: LMBranding.instance.headerColor,
                ),
                shape: BoxShape.circle),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.lock,
                size: 24,
                color: isJoined ? LMBranding.instance.headerColor : kWhiteColor,
              ),
            ),
          );
  }
}
