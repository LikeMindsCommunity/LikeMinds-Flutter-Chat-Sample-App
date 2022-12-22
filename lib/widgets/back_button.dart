import 'package:flutter/material.dart';
import 'package:group_chat_example/constants.dart';

class BackButton extends StatelessWidget {
  const BackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: primaryColor,
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
