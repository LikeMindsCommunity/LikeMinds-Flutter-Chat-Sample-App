import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:go_router/go_router.dart';

class MediaPreview extends StatefulWidget {
  final List<dynamic>? conversationAttachments;

  MediaPreview({Key? key, this.conversationAttachments}) : super(key: key);

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
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
          const Spacer(),
          CarouselSlider.builder(
            options: CarouselOptions(
              aspectRatio: 1,
              clipBehavior: Clip.hardEdge,
              scrollDirection: Axis.horizontal,
              initialPage: 0,
              enableInfiniteScroll: false,
              enlargeFactor: 0.0,
              viewportFraction: 1.0,
            ),
            itemCount: widget.conversationAttachments!.length,
            itemBuilder: (context, index, realIndex) => AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                widget.conversationAttachments![index]['file_url'] ??
                    widget.conversationAttachments![index]['url'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
