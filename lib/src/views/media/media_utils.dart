import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/navigation/router.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/service/media_service.dart';

Widget mediaErrorWidget() {
  return Container(
    color: kWhiteColor,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 9.sp,
          color: LMTheme.headerColor,
        ),
        const SizedBox(height: 12),
        Text(
          "An error occurred fetching media",
          textAlign: TextAlign.center,
          style: LMTheme.medium.copyWith(
            fontSize: 7.sp,
          ),
        )
      ],
    ),
  );
}

Widget mediaShimmer({bool? isPP}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade100,
    highlightColor: Colors.grey.shade200,
    period: const Duration(seconds: 2),
    direction: ShimmerDirection.ltr,
    child: isPP != null && isPP
        ? const CircleAvatar(backgroundColor: Colors.white)
        : Container(
            color: Colors.white,
            width: 60.w,
            height: 60.w,
          ),
  );
}

String getFileSizeString({required int bytes, int decimals = 0}) {
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  var i = (log(bytes) / log(1000)).floor();
  return "${((bytes / pow(1000, i)).toStringAsFixed(decimals))} ${suffixes[i]}";
}

// Returns file size in double in MBs
double getFileSizeInDouble(int bytes) {
  return (bytes / pow(1000, 2));
}

Widget getChatBubbleImage(Media mediaFile, {double? width, double? height}) {
  return Container(
    height: height,
    width: width,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6.0),
    ),
    child: CachedNetworkImage(
      imageUrl: mediaFile.mediaType == MediaType.photo
          ? mediaFile.mediaUrl ?? ''
          : mediaFile.thumbnailUrl ?? '',
      fit: BoxFit.cover,
      height: height,
      width: width,
      errorWidget: (context, url, error) => mediaErrorWidget(),
      progressIndicatorBuilder: (context, url, progress) => mediaShimmer(),
    ),
  );
}

Widget getImageMessage(
    BuildContext context,
    List<Media>? conversationAttachments,
    ChatRoom chatroom,
    int conversationId) {
  if (conversationAttachments!.length == 1) {
    return GestureDetector(
      onTap: () {
        router.pushNamed(
          "media_preview",
          extra: [conversationAttachments, chatroom],
          params: {
            'messageId': conversationId.toString(),
          },
        );
      },
      child: getChatBubbleImage(
        conversationAttachments.first,
        height: 55.w,
        width: 55.w,
      ),
    );
  } else if (conversationAttachments.length == 2) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          "media_preview",
          extra: [conversationAttachments, chatroom],
          params: {
            'messageId': conversationId.toString(),
          },
        );
      },
      child: Row(
        children: <Widget>[
          getChatBubbleImage(
            conversationAttachments[0],
            height: 26.w,
            width: 26.w,
          ),
          kHorizontalPaddingSmall,
          getChatBubbleImage(
            conversationAttachments[1],
            height: 26.w,
            width: 26.w,
          ),
        ],
      ),
    );
  } else if (conversationAttachments.length == 3) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          "media_preview",
          extra: [conversationAttachments, chatroom],
          params: {
            'messageId': conversationId.toString(),
          },
        );
      },
      child: Row(
        children: <Widget>[
          getChatBubbleImage(
            conversationAttachments[0],
            height: 26.w,
            width: 26.w,
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
                  conversationAttachments[1],
                  height: 26.w,
                  width: 26.w,
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
          extra: [conversationAttachments, chatroom],
          params: {
            'messageId': conversationId.toString(),
          },
        );
      },
      child: Column(
        children: [
          Row(
            children: <Widget>[
              getChatBubbleImage(
                conversationAttachments[0],
                height: 26.w,
                width: 26.w,
              ),
              kHorizontalPaddingSmall,
              getChatBubbleImage(
                conversationAttachments[1],
                height: 26.w,
                width: 26.w,
              ),
            ],
          ),
          kVerticalPaddingSmall,
          Row(
            children: <Widget>[
              getChatBubbleImage(
                conversationAttachments[2],
                height: 26.w,
                width: 26.w,
              ),
              kHorizontalPaddingSmall,
              getChatBubbleImage(
                conversationAttachments[3],
                height: 26.w,
                width: 26.w,
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
          extra: [conversationAttachments, chatroom],
          params: {
            'messageId': conversationId.toString(),
          },
        );
      },
      child: Column(
        children: [
          Row(
            children: <Widget>[
              getChatBubbleImage(
                conversationAttachments[0],
                height: 26.w,
                width: 26.w,
              ),
              kHorizontalPaddingSmall,
              getChatBubbleImage(
                conversationAttachments[1],
                height: 26.w,
                width: 26.w,
              ),
            ],
          ),
          kVerticalPaddingSmall,
          Row(
            children: <Widget>[
              getChatBubbleImage(
                conversationAttachments[2],
                height: 26.w,
                width: 26.w,
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
                      conversationAttachments[3],
                      height: 26.w,
                      width: 26.w,
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

Widget getFileImageTile(Media mediaFile, {double? width, double? height}) {
  if (mediaFile.mediaFile == null && mediaFile.thumbnailFile == null) {
    return mediaErrorWidget();
  }
  return Image.file(
    mediaFile.mediaType == MediaType.photo
        ? mediaFile.mediaFile!
        : mediaFile.thumbnailFile!,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => mediaErrorWidget(),
    height: width,
    width: height,
  );
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
        child: getFileImageTile(
          mediaFiles.first,
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
              child: getFileImageTile(
                mediaFiles[0],
                height: 26.w,
                width: 26.w,
              )),
          kHorizontalPaddingSmall,
          Container(
              height: 26.w,
              width: 26.w,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: getFileImageTile(
                mediaFiles[2],
                height: 26.w,
                width: 26.w,
              ))
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
              child: getFileImageTile(
                mediaFiles[0],
                height: 26.w,
                width: 26.w,
              )),
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
                    child: getFileImageTile(
                      mediaFiles[1],
                      height: 26.w,
                      width: 26.w,
                    )),
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
                child: getFileImageTile(
                  mediaFiles[0],
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
                  child: getFileImageTile(
                    mediaFiles[1],
                    height: 26.w,
                    width: 26.w,
                  )),
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
                  child: getFileImageTile(
                    mediaFiles[2],
                    height: 26.w,
                    width: 26.w,
                  )),
              kHorizontalPaddingSmall,
              Container(
                  height: 26.w,
                  width: 26.w,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: getFileImageTile(
                    mediaFiles[3],
                    height: 26.w,
                    width: 26.w,
                  )),
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
                child: getFileImageTile(
                  mediaFiles[0],
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
                child: getFileImageTile(
                  mediaFiles[1],
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
                child: getFileImageTile(
                  mediaFiles[2],
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
                      child: getFileImageTile(
                        mediaFiles[3],
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
