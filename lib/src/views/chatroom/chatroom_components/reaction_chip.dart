import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReactionChip extends StatelessWidget {
  final String text;
  final String icon;

  const ReactionChip({
    super.key,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
