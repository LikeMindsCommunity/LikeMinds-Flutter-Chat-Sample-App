import 'package:flutter/material.dart';

class ReactionButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const ReactionButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              icon,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
