import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat_example/constants.dart';

class BigButton extends StatelessWidget {
  final String text;
  final double width;
  final Function()? onTap;
  final Color? color;

  const BigButton({
    super.key,
    required this.text,
    required this.width,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: 48,
        decoration: BoxDecoration(
          color: color ?? primaryColor,
          borderRadius: BorderRadius.circular(width / 16),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.montserrat(
              color: Colors.white,
            ),
          ),
        ));
  }
}
