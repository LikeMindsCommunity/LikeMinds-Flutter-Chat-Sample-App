import 'dart:io';
import 'dart:ui' as ui;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/media/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/utils/media/permission_handler.dart';
import 'package:likeminds_chat_mm_fl/src/utils/tagging/helpers/tagging_helper.dart';
import 'package:likeminds_chat_mm_fl/src/utils/tagging/tagging_textfield_ta.dart';
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
  ImagePicker imagePicker = ImagePicker();
  List<Media> mediaList = [];
  int currPosition = 0;
  CarouselController controller = CarouselController();
  ValueNotifier<bool> rebuildCurr = ValueNotifier<bool>(false);

  List<UserTag> userTags = [];
  String? result;

  @override
  void initState() {
    super.initState();
    mediaList = widget.media;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  bool checkIfMultipleAttachments() {
    return mediaList.length > 1;
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
        decoration: const BoxDecoration(
            color: kBlackColor,
            border: Border(
              top: BorderSide(
                color: kGreyColor,
                width: 0.1,
              ),
            )),
        padding: const EdgeInsets.symmetric(vertical: 12.5, horizontal: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                if (await handlePermissions(1)) {
                  List<XFile>? pickedImage = await imagePicker.pickMultiImage();
                  if (mediaList.length + pickedImage.length > 10) {
                    Fluttertoast.showToast(
                        msg: 'Only 10 attachments can be sent');
                    return;
                  }
                  if (pickedImage.isNotEmpty) {
                    for (XFile xImage in pickedImage) {
                      int fileBytes = await xImage.length();
                      if (getFileSizeInDouble(fileBytes) > 100) {
                        Fluttertoast.showToast(
                          msg: 'File size should be smaller than 100MB',
                        );
                        return;
                      }
                      File file = File(xImage.path);
                      ui.Image image =
                          await decodeImageFromList(file.readAsBytesSync());
                      Media media = Media(
                        mediaType: MediaType.photo,
                        height: image.height,
                        width: image.width,
                        mediaFile: file,
                        size: fileBytes,
                      );
                      mediaList.add(media);
                    }
                  }
                  setState(() {});
                }
              },
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
            Expanded(
              child: TaggingAheadTextField(
                isDown: false,
                chatroomId: widget.chatroomId,
                style: LMTheme.regular.copyWith(color: kWhiteColor),
                onTagSelected: (tag) {
                  print(tag);
                  userTags.add(tag);
                },
                onChange: (value) {
                  print(value);
                },
                controller: _textEditingController,
                focusNode: FocusNode(),
              ),
            ),
            GestureDetector(
              onTap: () {
                context.pop();
                final string = _textEditingController.text;
                userTags = TaggingHelper.matchTags(string, userTags);
                result = TaggingHelper.encodeString(string, userTags);
                result = result?.trim();
                chatActionBloc.add(
                  PostMultiMediaConversation(
                    (PostConversationRequestBuilder()
                          ..attachmentCount(1)
                          ..chatroomId(widget.chatroomId)
                          ..temporaryId(
                              DateTime.now().millisecondsSinceEpoch.toString())
                          ..text(result!)
                          ..hasFiles(true))
                        .build(),
                    mediaList,
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
    if (mediaList.first.mediaType == MediaType.photo) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CarouselSlider.builder(
            options: CarouselOptions(
              aspectRatio: 1,
              clipBehavior: Clip.hardEdge,
              scrollDirection: Axis.horizontal,
              initialPage: 0,
              enableInfiniteScroll: false,
              enlargeFactor: 0.0,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                currPosition = index;
                rebuildCurr.value = !rebuildCurr.value;
              },
            ),
            itemCount: mediaList.length,
            itemBuilder: (context, index, realIndex) => AspectRatio(
              aspectRatio: 1,
              child: Image.file(
                mediaList[index].mediaFile!,
                fit: BoxFit.cover,
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
                            children: mediaList.map((url) {
                              int index = mediaList.indexOf(url);
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
      );
    } else if (mediaList.first.mediaType == MediaType.document) {
      return SizedBox(
        width: 100.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AspectRatio(
              aspectRatio: (mediaList.first.width! / mediaList.first.height!),
              child: Image.file(mediaList.first.thumbnailFile!, width: 100.w),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 100.w,
                  child: Text(
                    basenameWithoutExtension(mediaList.first.mediaFile!.path),
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
                          '${mediaList.first.pageCount} ${mediaList.first.pageCount! > 1 ? 'pages' : 'page'} * ${getFileSizeString(bytes: mediaList.first.size!)} * PDF',
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
