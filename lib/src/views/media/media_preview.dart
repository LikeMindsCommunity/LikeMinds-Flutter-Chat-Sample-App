import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/navigation/router.dart';
import 'package:likeminds_chat_mm_fl/src/service/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/utils/analytics/analytics.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/media_utils.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/multimedia/video/chat_video_factory.dart';
import 'package:video_player/video_player.dart';

class MediaPreview extends StatefulWidget {
  final List<Media>? conversationAttachments;
  final int messageId;
  final ChatRoom chatroom;

  const MediaPreview({
    Key? key,
    this.conversationAttachments,
    required this.chatroom,
    required this.messageId,
  }) : super(key: key);

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  int currPosition = 0;
  CarouselController controller = CarouselController();
  ValueNotifier<bool> rebuildCurr = ValueNotifier<bool>(false);
  List<Media>? conversationAttachments;
  FlickManager? flickManager;

  bool checkIfMultipleAttachments() {
    return (conversationAttachments != null &&
        conversationAttachments!.length > 1);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LMAnalytics.get().track(AnalyticsKeys.imageViewed, {
      'chatroom_id': widget.chatroom.id,
      'community_id': widget.chatroom.communityId,
      'chatroom_type': widget.chatroom.type,
      'message_id': widget.messageId,
    });
  }

  void setupFlickManager() {
    if (conversationAttachments?[currPosition].mediaType == MediaType.video) {
      flickManager ??= FlickManager(
        videoPlayerController: VideoPlayerController.network(
          conversationAttachments![currPosition].mediaUrl!,
        ),
        autoPlay: true,
        autoInitialize: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    conversationAttachments = widget.conversationAttachments;
    setupFlickManager();
    return Scaffold(
      backgroundColor: kBlackColor,
      appBar: AppBar(
        backgroundColor: kBlackColor,
        leading: IconButton(
          onPressed: () {
            router.pop();
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: CarouselSlider.builder(
                  options: CarouselOptions(
                      clipBehavior: Clip.hardEdge,
                      scrollDirection: Axis.horizontal,
                      initialPage: 0,
                      enlargeCenterPage: false,
                      enableInfiniteScroll: false,
                      height: 80.h,
                      enlargeFactor: 0.0,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        currPosition = index;
                        if (conversationAttachments![index].mediaType ==
                            MediaType.video) {
                          if (flickManager == null) {
                            setupFlickManager();
                          } else {
                            flickManager?.handleChangeVideo(
                              VideoPlayerController.network(
                                conversationAttachments![currPosition]
                                    .mediaUrl!,
                              ),
                            );
                          }
                        }
                        rebuildCurr.value = !rebuildCurr.value;
                      }),
                  itemCount: conversationAttachments!.length,
                  itemBuilder: (context, index, realIndex) {
                    if (conversationAttachments![index].mediaType ==
                        MediaType.video) {
                      return chatVideoFactory(
                          conversationAttachments![index], flickManager!);
                    }
                    return AspectRatio(
                      aspectRatio: conversationAttachments![index].width! /
                          conversationAttachments![index].height!,
                      child: CachedNetworkImage(
                        imageUrl: conversationAttachments![index].mediaUrl!,
                        errorWidget: (context, url, error) =>
                            mediaErrorWidget(),
                        progressIndicatorBuilder: (context, url, progress) =>
                            mediaShimmer(),
                        fit: BoxFit.contain,
                      ),
                    );
                  }),
            ),
            ValueListenableBuilder(
                valueListenable: rebuildCurr,
                builder: (context, _, __) {
                  return Column(
                    children: [
                      checkIfMultipleAttachments()
                          ? kVerticalPaddingMedium
                          : const SizedBox(),
                      checkIfMultipleAttachments()
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: conversationAttachments!.map((url) {
                                int index =
                                    conversationAttachments!.indexOf(url);
                                return Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 7.0, horizontal: 2.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: currPosition == index
                                        ? const Color.fromRGBO(
                                            255, 255, 255, 0.9)
                                        : const Color.fromRGBO(
                                            255, 255, 255, 0.4),
                                  ),
                                );
                              }).toList())
                          : const SizedBox(),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }
}
