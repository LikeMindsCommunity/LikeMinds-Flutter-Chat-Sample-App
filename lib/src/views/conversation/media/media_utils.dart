import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/media/media_service.dart';

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

Widget getChatBubbleImage(String url) {
  return Container(
    height: 26.w,
    width: 26.w,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6.0),
    ),
    child: CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      height: 26.w,
      width: 26.w,
      errorWidget: (context, url, error) => mediaErrorWidget(),
      progressIndicatorBuilder: (context, url, progress) => mediaShimmer(),
    ),
  );
}

Widget getImageMessage(
    BuildContext context, List<dynamic>? conversationAttachments) {
  if (conversationAttachments!.length == 1) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          "media_preview",
          extra: conversationAttachments,
        );
      },
      child: Container(
        height: 55.w,
        width: 55.w,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: CachedNetworkImage(
          imageUrl: conversationAttachments.first['file_url'] ??
              conversationAttachments.first['url'],
          fit: BoxFit.cover,
          height: 55.w,
          width: 55.w,
          errorWidget: (context, url, error) => mediaErrorWidget(),
          progressIndicatorBuilder: (context, url, progress) => mediaShimmer(),
        ),
      ),
    );
  } else if (conversationAttachments.length == 2) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          "media_preview",
          extra: conversationAttachments,
        );
      },
      child: Row(
        children: <Widget>[
          Container(
            height: 26.w,
            width: 26.w,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: CachedNetworkImage(
              imageUrl: conversationAttachments[0]['file_url'] ??
                  conversationAttachments[0]['url'],
              fit: BoxFit.cover,
              height: 26.w,
              width: 26.w,
              errorWidget: (context, url, error) => mediaErrorWidget(),
              progressIndicatorBuilder: (context, url, progress) =>
                  mediaShimmer(),
            ),
          ),
          kHorizontalPaddingSmall,
          Container(
            height: 26.w,
            width: 26.w,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: CachedNetworkImage(
              imageUrl: conversationAttachments[1]['file_url'] ??
                  conversationAttachments[1]['url'],
              fit: BoxFit.cover,
              height: 26.w,
              width: 26.w,
              errorWidget: (context, url, error) => mediaErrorWidget(),
              progressIndicatorBuilder: (context, url, progress) =>
                  mediaShimmer(),
            ),
          )
        ],
      ),
    );
  } else if (conversationAttachments.length == 3) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          "media_preview",
          extra: conversationAttachments,
        );
      },
      child: Row(
        children: <Widget>[
          getChatBubbleImage(
            conversationAttachments[0]['file_url'] ??
                conversationAttachments[0]['url'],
          ),
          kHorizontalPaddingSmall,
          Container(
            height: 26.w,
            width: 26.w,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Stack(
              children: [
                getChatBubbleImage(
                  conversationAttachments[1]['file_url'] ??
                      conversationAttachments[1]['url'],
                ),
                Positioned(
                  child: Container(
                    height: 26.w,
                    width: 26.w,
                    alignment: Alignment.center,
                    color: kBlackColor.withOpacity(0.5),
                    child: Text(
                      '+2',
                      style: LMTheme.medium
                          .copyWith(color: kWhiteColor, fontSize: 20.sp),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  } else if (conversationAttachments.length == 4) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          "media_preview",
          extra: conversationAttachments,
        );
      },
      child: Column(
        children: [
          Row(
            children: <Widget>[
              getChatBubbleImage(
                conversationAttachments[0]['file_url'] ??
                    conversationAttachments[0]['url'],
              ),
              kHorizontalPaddingSmall,
              getChatBubbleImage(
                conversationAttachments[1]['file_url'] ??
                    conversationAttachments[1]['url'],
              ),
            ],
          ),
          kVerticalPaddingSmall,
          Row(
            children: <Widget>[
              getChatBubbleImage(
                conversationAttachments[2]['file_url'] ??
                    conversationAttachments[2]['url'],
              ),
              kHorizontalPaddingSmall,
              getChatBubbleImage(
                conversationAttachments[3]['file_url'] ??
                    conversationAttachments[3]['url'],
              ),
            ],
          ),
        ],
      ),
    );
  } else {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          "media_preview",
          extra: conversationAttachments,
        );
      },
      child: Column(
        children: [
          Row(
            children: <Widget>[
              getChatBubbleImage(
                conversationAttachments[0]['file_url'] ??
                    conversationAttachments[0]['url'],
              ),
              kHorizontalPaddingSmall,
              getChatBubbleImage(
                conversationAttachments[1]['file_url'] ??
                    conversationAttachments[1]['url'],
              ),
            ],
          ),
          kVerticalPaddingSmall,
          Row(
            children: <Widget>[
              getChatBubbleImage(
                conversationAttachments[2]['file_url'] ??
                    conversationAttachments[2]['url'],
              ),
              kHorizontalPaddingSmall,
              Container(
                height: 26.w,
                width: 26.w,
                clipBehavior: Clip.hardEdge,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(6.0)),
                child: Stack(
                  children: [
                    getChatBubbleImage(
                      conversationAttachments[3]['file_url'] ??
                          conversationAttachments[3]['url'],
                    ),
                    Positioned(
                      child: Container(
                        height: 26.w,
                        width: 26.w,
                        alignment: Alignment.center,
                        color: kBlackColor.withOpacity(0.5),
                        child: Text(
                          '+${conversationAttachments.length - 3}',
                          style: LMTheme.medium
                              .copyWith(color: kWhiteColor, fontSize: 20.sp),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget getImageFileMessage(BuildContext context, List<Media> mediaFiles) {
  if (mediaFiles.length == 1) {
    return GestureDetector(
      child: Container(
        height: 55.w,
        width: 55.w,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: Image.file(
          mediaFiles.first.mediaFile!,
          fit: BoxFit.cover,
          height: 55.w,
          width: 55.w,
        ),
      ),
    );
  } else if (mediaFiles.length == 2) {
    return GestureDetector(
      child: Row(
        children: <Widget>[
          Container(
            height: 26.w,
            width: 26.w,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Image.file(
              mediaFiles[0].mediaFile!,
              fit: BoxFit.cover,
              height: 26.w,
              width: 26.w,
            ),
          ),
          kHorizontalPaddingSmall,
          Container(
            height: 26.w,
            width: 26.w,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Image.file(
              mediaFiles[1].mediaFile!,
              fit: BoxFit.cover,
              height: 26.w,
              width: 26.w,
            ),
          )
        ],
      ),
    );
  } else if (mediaFiles.length == 3) {
    return GestureDetector(
      child: Row(
        children: <Widget>[
          Container(
            height: 26.w,
            width: 26.w,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Image.file(
              mediaFiles[0].mediaFile!,
              fit: BoxFit.cover,
              height: 26.w,
              width: 26.w,
            ),
          ),
          kHorizontalPaddingSmall,
          Container(
            height: 26.w,
            width: 26.w,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Stack(
              children: [
                Container(
                  height: 26.w,
                  width: 26.w,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Image.file(
                    mediaFiles[1].mediaFile!,
                    fit: BoxFit.cover,
                    height: 26.w,
                    width: 26.w,
                  ),
                ),
                Positioned(
                  child: Container(
                    height: 26.w,
                    width: 26.w,
                    alignment: Alignment.center,
                    color: kBlackColor.withOpacity(0.5),
                    child: Text(
                      '+2',
                      style: LMTheme.medium
                          .copyWith(color: kWhiteColor, fontSize: 20.sp),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  } else if (mediaFiles.length == 4) {
    return GestureDetector(
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Container(
                height: 26.w,
                width: 26.w,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Image.file(
                  mediaFiles[0].mediaFile!,
                  fit: BoxFit.cover,
                  height: 26.w,
                  width: 26.w,
                ),
              ),
              kHorizontalPaddingSmall,
              Container(
                height: 26.w,
                width: 26.w,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Image.file(
                  mediaFiles[1].mediaFile!,
                  fit: BoxFit.cover,
                  height: 26.w,
                  width: 26.w,
                ),
              ),
            ],
          ),
          kVerticalPaddingSmall,
          Row(
            children: <Widget>[
              Container(
                height: 26.w,
                width: 26.w,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Image.file(
                  mediaFiles[2].mediaFile!,
                  fit: BoxFit.cover,
                  height: 26.w,
                  width: 26.w,
                ),
              ),
              kHorizontalPaddingSmall,
              Container(
                height: 26.w,
                width: 26.w,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Image.file(
                  mediaFiles[3].mediaFile!,
                  fit: BoxFit.cover,
                  height: 26.w,
                  width: 26.w,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  } else {
    return GestureDetector(
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Container(
                height: 26.w,
                width: 26.w,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Image.file(
                  mediaFiles[0].mediaFile!,
                  fit: BoxFit.cover,
                  height: 26.w,
                  width: 26.w,
                ),
              ),
              kHorizontalPaddingSmall,
              Container(
                height: 26.w,
                width: 26.w,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Image.file(
                  mediaFiles[1].mediaFile!,
                  fit: BoxFit.cover,
                  height: 26.w,
                  width: 26.w,
                ),
              ),
            ],
          ),
          kVerticalPaddingSmall,
          Row(
            children: <Widget>[
              Container(
                height: 26.w,
                width: 26.w,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Image.file(
                  mediaFiles[2].mediaFile!,
                  fit: BoxFit.cover,
                  height: 26.w,
                  width: 26.w,
                ),
              ),
              kHorizontalPaddingSmall,
              Container(
                height: 26.w,
                width: 26.w,
                clipBehavior: Clip.hardEdge,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(6.0)),
                child: Stack(
                  children: [
                    Container(
                      height: 26.w,
                      width: 26.w,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Image.file(
                        mediaFiles[3].mediaFile!,
                        fit: BoxFit.cover,
                        height: 26.w,
                        width: 26.w,
                      ),
                    ),
                    Positioned(
                      child: Container(
                        height: 26.w,
                        width: 26.w,
                        alignment: Alignment.center,
                        color: kBlackColor.withOpacity(0.5),
                        child: Text(
                          '+${mediaFiles.length - 3}',
                          style: LMTheme.medium
                              .copyWith(color: kWhiteColor, fontSize: 20.sp),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
