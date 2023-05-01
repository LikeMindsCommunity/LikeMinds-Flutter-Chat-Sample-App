import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/media/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chat_action_bloc/chat_action_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/conversation/media/media_utils.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class MediaForward extends StatefulWidget {
  int chatroomId;
  List<Media> media;
  MediaForward({
    Key? key,
    required this.media,
    required this.chatroomId,
  }) : super(key: key);

  @override
  State<MediaForward> createState() => _MediaForwardState();
}

class _MediaForwardState extends State<MediaForward> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ChatActionBloc chatActionBloc = BlocProvider.of<ChatActionBloc>(context);
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
      bottomSheet: Container(
        color: kBlackColor,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onTap: () {},
              child: SizedBox(
                width: 10.w,
                height: 10.w,
                child: Icon(
                  Icons.add_a_photo,
                  color: kWhiteColor,
                  size: 24.sp,
                ),
              ),
            ),
            SizedBox(
              width: 60.w,
              child: TextField(
                controller: _textEditingController,
                style: LMTheme.medium.copyWith(
                  color: kWhiteColor,
                ),
                decoration: InputDecoration(
                  hintStyle: LMTheme.medium.copyWith(
                    color: kWhiteColor,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                context.pop();
                chatActionBloc.add(
                  PostMultiMediaConversation(
                    (PostConversationRequestBuilder()
                          ..attachmentCount(1)
                          ..chatroomId(widget.chatroomId)
                          ..temporaryId(
                              DateTime.now().millisecondsSinceEpoch.toString())
                          ..text(_textEditingController.text)
                          ..hasFiles(true))
                        .build(),
                    widget.media,
                  ),
                );
              },
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: LMTheme.buttonColor,
                  borderRadius: BorderRadius.circular(
                    100.0,
                  ),
                ),
                child: Icon(
                  Icons.send,
                  color: kWhiteColor,
                  size: 24.sp,
                ),
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          const Spacer(),
          Align(
            alignment: Alignment.center,
            child: getMediaPreview(),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget getMediaPreview() {
    if (widget.media.first.mediaType == MediaType.photo) {
      return CarouselSlider.builder(
        options: CarouselOptions(
          aspectRatio: 1,
          clipBehavior: Clip.hardEdge,
          scrollDirection: Axis.horizontal,
          initialPage: 0,
          enableInfiniteScroll: false,
          enlargeFactor: 0.0,
          viewportFraction: 1.0,
        ),
        itemCount: widget.media.length,
        itemBuilder: (context, index, realIndex) => AspectRatio(
          aspectRatio: 1,
          child: Image.file(
            widget.media[index].mediaFile!,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (widget.media.first.mediaType == MediaType.document) {
      return SizedBox(
        width: 100.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AspectRatio(
              aspectRatio:
                  (widget.media.first.width! / widget.media.first.height!),
              child:
                  Image.file(widget.media.first.thumbnailFile!, width: 100.w),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 100.w,
                  child: Text(
                    basenameWithoutExtension(
                        widget.media.first.mediaFile!.path),
                    style: LMTheme.medium.copyWith(color: kWhiteColor),
                  ),
                ),
                SizedBox(
                  width: 100.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                          '${widget.media.first.pageCount} ${widget.media.first.pageCount! > 1 ? 'pages' : 'page'} * ${getFileSizeString(bytes: widget.media.first.size!)} * PDF',
                          style: LMTheme.medium.copyWith(color: kWhiteColor))
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }
}
