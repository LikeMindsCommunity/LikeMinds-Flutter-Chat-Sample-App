import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:go_router/go_router.dart';
import 'package:likeminds_chat_mm_fl/src/views/conversation/media/media_utils.dart';

class MediaPreview extends StatefulWidget {
  final List<dynamic>? conversationAttachments;

  MediaPreview({Key? key, this.conversationAttachments}) : super(key: key);

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  int currPosition = 0;
  CarouselController controller = CarouselController();
  ValueNotifier<bool> rebuildCurr = ValueNotifier<bool>(false);

  bool checkIfMultipleAttachments() {
    return (widget.conversationAttachments != null &&
        widget.conversationAttachments!.length > 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlackColor,
      appBar: AppBar(
        backgroundColor: kBlackColor,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          CarouselSlider.builder(
            options: CarouselOptions(
                clipBehavior: Clip.hardEdge,
                scrollDirection: Axis.horizontal,
                initialPage: 0,
                enlargeCenterPage: false,
                enableInfiniteScroll: false,
                height: 85.h,
                enlargeFactor: 0.0,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  currPosition = index;
                  rebuildCurr.value = !rebuildCurr.value;
                }),
            itemCount: widget.conversationAttachments!.length,
            itemBuilder: (context, index, realIndex) => AspectRatio(
              aspectRatio: widget.conversationAttachments![index]["width"] /
                  widget.conversationAttachments![index]['height'],
              child: CachedNetworkImage(
                imageUrl: widget.conversationAttachments![index]['file_url'] ??
                    widget.conversationAttachments![index]['url'],
                errorWidget: (context, url, error) => mediaErrorWidget(),
                progressIndicatorBuilder: (context, url, progress) =>
                    mediaShimmer(),
                fit: BoxFit.contain,
              ),
            ),
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
                            children:
                                widget.conversationAttachments!.map((url) {
                              int index =
                                  widget.conversationAttachments!.indexOf(url);
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 7.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: currPosition == index
                                      ? const Color.fromRGBO(255, 255, 255, 0.9)
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
    );
  }
}
