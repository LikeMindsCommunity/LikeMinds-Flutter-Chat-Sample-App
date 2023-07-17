import 'package:flutter/material.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';

class LMCustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final String actionText;
  final Function() onActionPressed;

  const LMCustomDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.actionText,
    required this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: LMTheme.bold,
      ),
      content: Text(
        content,
        style: LMTheme.medium,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            "Cancel",
            style: LMTheme.bold.copyWith(color: kGrey3Color),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            onActionPressed();
          },
          child: Text(
            actionText,
            style: LMTheme.bold.copyWith(
              color: LMTheme.buttonColor,
            ),
          ),
        ),
      ],
    );
  }
}
