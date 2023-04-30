import 'package:likeminds_chat_mm_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/skeleton_chat_box.dart';

class SkeletonChatList extends StatelessWidget {
  const SkeletonChatList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Column(
    //   children: [
    //   Container(
    //     width: 100.w,
    //     color: LMBranding.instance.headerColor,
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(
    //         horizontal: 24,
    //         vertical: 18,
    //       ),
    //       child: SafeArea(
    //         bottom: false,
    //         child: Row(
    //           crossAxisAlignment: CrossAxisAlignment.end,
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Shimmer.fromColors(
    //               baseColor: Colors.grey.shade200,
    //               highlightColor: Colors.grey.shade300,
    //               period: const Duration(seconds: 2),
    //               direction: ShimmerDirection.ltr,
    //               child: Padding(
    //                 padding: const EdgeInsets.only(
    //                   bottom: 12,
    //                 ),
    //                 child: Container(
    //                   height: 16,
    //                   width: 32.w,
    //                   color: kWhiteColor,
    //                 ),
    //               ),
    //             ),
    //             Shimmer.fromColors(
    //               baseColor: Colors.grey.shade200,
    //               highlightColor: Colors.grey.shade300,
    //               period: const Duration(seconds: 2),
    //               direction: ShimmerDirection.ltr,
    //               child: Container(
    //                 height: 42,
    //                 width: 42,
    //                 decoration: BoxDecoration(
    //                   color: kWhiteColor,
    //                   borderRadius: BorderRadius.circular(21),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    //   const SizedBox(height: 18),
    return ListView.builder(
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
    );
    //   ],
    // );
  }
}
