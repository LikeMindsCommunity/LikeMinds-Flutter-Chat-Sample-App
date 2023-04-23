import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/lm_branding.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/ui_constants.dart';

class BackButton extends StatelessWidget {
  const BackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: LMBranding.instance.buttonColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          Icons.arrow_back,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}
