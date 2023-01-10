import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:group_chat_example/widgets/skeleton_chat_box.dart';

class SkeletonChatList extends StatelessWidget {
  const SkeletonChatList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        itemCount: 9,
        itemBuilder: (BuildContext context, int index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade300,
            period: const Duration(seconds: 2),
            direction: ShimmerDirection.ltr,
            child: const SkeletonChatBox(),
          );
        },
      ),
    );
  }
}
