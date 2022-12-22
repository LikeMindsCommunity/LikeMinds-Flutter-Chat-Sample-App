import 'package:flutter/material.dart';

class ReactionChip extends StatelessWidget {
  final String text;
  final Widget iconWidget;

  const ReactionChip({
    super.key,
    required this.text,
    required this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Chip(
        label: Text(text),
        avatar: Padding(
          padding: const EdgeInsets.all(2),
          child: iconWidget,
        ),
      ),
    );
  }
}
