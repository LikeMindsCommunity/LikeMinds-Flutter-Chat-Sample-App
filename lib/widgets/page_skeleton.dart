import 'package:flutter/material.dart';

class PageSkeleton extends StatelessWidget {
  final List<Widget> appBarChildren;
  final List<Widget> bodyChildren;
  final Color? backgroundColor;

  const PageSkeleton({
    super.key,
    required this.appBarChildren,
    required this.bodyChildren,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 72),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: appBarChildren,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: bodyChildren,
            ),
          ),
        ],
      ),
    );
  }
}
