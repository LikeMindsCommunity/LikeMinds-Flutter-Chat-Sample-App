import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/lm_branding.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/asset_constants.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/custom_dialog.dart';

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
    bool isJoined = chatroom.followStatus!;
    return chatroom.isSecret != null && chatroom.isSecret!
        ? const SizedBox()
        : GestureDetector(
            onTap: () {
              isJoined
                  ? showDialog(
                      context: context,
                      builder: (context) => LMCustomDialog(
                          title: "Leave chatroom",
                          content: chatroom.isSecret != null &&
                                  chatroom.isSecret!
                              ? 'Are you sure you want to leave this private group? To join back, you\'ll need to reach out to the admin'
                              : 'Are you sure you want to leave this group?',
                          actionText: 'Confirm',
                          onActionPressed: onTap),
                    )
                  : onTap();
            },
            child: Container(
              decoration: BoxDecoration(
                color: isJoined ? null : LMBranding.instance.headerColor,
                border: isJoined
                    ? Border.all(color: LMTheme.buttonColor, width: 1.2)
                    : null,
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
                    const SizedBox(width: 6),
                    Text(
                      isJoined ? "Joined" : "Join",
                      style: GoogleFonts.roboto(
                        fontSize: 11.sp,
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
          );
  }
}
