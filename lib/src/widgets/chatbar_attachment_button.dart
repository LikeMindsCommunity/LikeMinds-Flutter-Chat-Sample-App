import 'package:flutter/material.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';

Widget getChatBarAttachmentButton(
    Color backgroundColor, String title, IconData? icon) {
  return SizedBox(
    width: 25.w,
    height: 12.h,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40.sp,
          height: 40.sp,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
          ),
          child: icon == null
              ? const SizedBox()
              : Icon(icon, color: kWhiteColor, size: 25.sp),
        ),
        kVerticalPaddingMedium,
        Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: LMTheme.medium,
        ),
      ],
    ),
  );
}
