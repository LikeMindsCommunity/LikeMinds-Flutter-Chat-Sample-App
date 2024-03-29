import 'package:flutter/material.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';

class PageSkeleton extends StatelessWidget {
  final List<Widget> appBarChildren;
  final List<Widget> bodyChildren;
  final Color? backgroundColor;
  final bool isListView;

  const PageSkeleton({
    super.key,
    required this.appBarChildren,
    required this.bodyChildren,
    this.backgroundColor,
    this.isListView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      body: SafeArea(
        child: Padding(
          padding: isListView
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              kVerticalPaddingLarge,
              Padding(
                padding: isListView
                    ? const EdgeInsets.symmetric(horizontal: 24)
                    : EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: appBarChildren,
                ),
              ),
              const SizedBox(height: 16),
              isListView
                  ? Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: bodyChildren,
                      ),
                    )
                  : Expanded(
                      child: Column(
                        children: bodyChildren,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
