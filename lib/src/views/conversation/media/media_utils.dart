import 'dart:math';

import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';

Widget mediaErrorWidget() {
  return Container(
    color: kWhiteColor,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 24,
          color: LMTheme.headerColor,
        ),
        const SizedBox(height: 24),
        Text(
          "An error occurred fetching media",
          style: LMTheme.medium,
        )
      ],
    ),
  );
}

Widget mediaShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.black26,
    highlightColor: Colors.black12,
    child: Container(
      color: Colors.white,
      width: 60.w,
      height: 60.w,
    ),
  );
}

String getFileSizeString({required int bytes, int decimals = 0}) {
  const suffixes = ["b", "kb", "mb", "gb", "tb"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
}

// Returns file size in double in MBs
double getFileSizeInDouble(int bytes) {
  return (bytes / pow(1024, 2));
}
