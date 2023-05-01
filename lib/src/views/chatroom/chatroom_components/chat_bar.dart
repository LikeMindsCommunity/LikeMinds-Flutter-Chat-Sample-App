import 'dart:io';
import 'dart:ui' as ui;

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/navigation/router.dart';
import 'package:likeminds_chat_mm_fl/src/utils/analytics/analytics.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/media/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/utils/media/permission_handler.dart';
import 'package:likeminds_chat_mm_fl/src/utils/simple_bloc_observer.dart';
import 'package:likeminds_chat_mm_fl/src/utils/tagging/helpers/tagging_helper.dart';
import 'package:likeminds_chat_mm_fl/src/utils/tagging/tagging_textfield_ta.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chat_action_bloc/chat_action_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/conversation/media/media_utils.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

class ChatBar extends StatefulWidget {
  final ChatRoom chatroom;
  Conversation? replyToConversation;
  final Function() scrollToBottom;

  ChatBar({
    super.key,
    required this.chatroom,
    this.replyToConversation,
    required this.scrollToBottom,
  });

  @override
  State<ChatBar> createState() => _ChatBarState();
}

class _ChatBarState extends State<ChatBar> {
  ChatActionBloc? chatActionBloc;
  ImagePicker? imagePicker;
  FilePicker? filePicker;
  Conversation? replyToConversation;
  late CustomPopupMenuController _popupMenuController;
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  LMBranding lmBranding = LMBranding.instance;

  List<UserTag> userTags = [];
  String? result;

  @override
  void initState() {
    Bloc.observer = SimpleBlocObserver();
    _popupMenuController = CustomPopupMenuController();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
    imagePicker = ImagePicker();
    filePicker = FilePicker.platform;
    super.initState();
  }

  String getText() {
    if (_textEditingController.text.isNotEmpty) {
      return _textEditingController.text;
    } else {
      return "";
    }
  }

  @override
  void dispose() {
    _popupMenuController.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
    replyToConversation = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    replyToConversation = widget.replyToConversation;
    chatActionBloc = BlocProvider.of<ChatActionBloc>(context);
    return Column(
      children: [
        replyToConversation != null
            ? Container(
                height: 8.h,
                width: 100.w,
                color: kGreyColor.withOpacity(0.1),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            color: kGreyColor.withOpacity(0.2),
                            child: Row(
                              children: [
                                Container(
                                  width: 1.w,
                                  color: LMTheme.buttonColor,
                                ),
                                kHorizontalPaddingMedium,
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      replyToConversation!.member?.name ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: LMTheme.medium.copyWith(
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                    kVerticalPaddingSmall,
                                    SizedBox(
                                      child: Text(
                                        TaggingHelper.convertRouteToTag(
                                                replyToConversation?.answer) ??
                                            "",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: LMTheme.regular,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            widget.replyToConversation = null;
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          color: kGreyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
        Container(
          width: 100.w,
          color: kGreyColor.withOpacity(0.3),
          padding: EdgeInsets.symmetric(
            horizontal: 3.w,
            vertical: 12,
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 80.w,
                  constraints: BoxConstraints(
                    // minHeight: 4.h,
                    maxHeight: 24.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: kPaddingSmall,
                      vertical: 1.h,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TaggingAheadTextField(
                            isDown: false,
                            chatroomId: widget.chatroom.id,
                            onTagSelected: (tag) {
                              print(tag);
                              userTags.add(tag);
                              LMAnalytics.get()
                                  .logEvent(AnalyticsKeys.userTagsSomeone, {
                                'community_id': widget.chatroom.id,
                                'chatroom_name': widget.chatroom.title,
                                'tagged_user_id': tag.id,
                                'tagged_user_name': tag.name,
                              });
                            },
                            onChange: (value) {
                              print(value);
                            },
                            controller: _textEditingController,
                            focusNode: _focusNode,
                          ),
                        ),
                        CustomPopupMenu(
                          controller: _popupMenuController,
                          arrowColor: Colors.white,
                          showArrow: false,
                          menuBuilder: () => Container(
                            margin: const EdgeInsets.only(bottom: 25),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 100.w,
                                height: 30.w,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              _popupMenuController.hideMenu();
                                              if (await handlePermissions(1)) {
                                                XFile? pickedImage =
                                                    await imagePicker!
                                                        .pickImage(
                                                  source: ImageSource.camera,
                                                );
                                                List<Media> mediaList = [];
                                                if (pickedImage != null) {
                                                  File file =
                                                      File(pickedImage.path);
                                                  ui.Image image =
                                                      await decodeImageFromList(
                                                          file.readAsBytesSync());
                                                  Media media = Media(
                                                    mediaType: MediaType.photo,
                                                    height: image.height,
                                                    width: image.width,
                                                    mediaFile: file,
                                                  );
                                                  mediaList.add(media);
                                                  router.pushNamed(
                                                      "media_forward",
                                                      extra: mediaList,
                                                      params: {
                                                        'chatroomId': widget
                                                            .chatroom.id
                                                            .toString()
                                                      });
                                                }
                                              }
                                            },
                                            child: SizedBox(
                                              width: 40.w,
                                              height: 22.w,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 38.sp,
                                                    height: 38.sp,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.w),
                                                      color: LMBranding
                                                          .instance.buttonColor,
                                                    ),
                                                    child: Icon(
                                                      Icons.camera_alt_outlined,
                                                      color: kWhiteColor,
                                                      size: 24.sp,
                                                    ),
                                                  ),
                                                  kVerticalPaddingMedium,
                                                  Text(
                                                    "Camera",
                                                    style:
                                                        lmBranding.fonts.medium,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              _popupMenuController.hideMenu();
                                              if (await handlePermissions(1)) {
                                                List<XFile>? pickedImage =
                                                    await imagePicker!
                                                        .pickMultiImage();
                                                if (pickedImage.length > 10) {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          'Only 10 attachments can be sent');
                                                  return;
                                                }
                                                List<Media> mediaList = [];
                                                if (pickedImage.isNotEmpty) {
                                                  for (XFile xImage
                                                      in pickedImage) {
                                                    int fileBytes =
                                                        await xImage.length();
                                                    if (getFileSizeInDouble(
                                                            fileBytes) >
                                                        100) {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            'File size should be smaller than 100 MB',
                                                      );
                                                      return;
                                                    }
                                                    File file =
                                                        File(xImage.path);
                                                    ui.Image image =
                                                        await decodeImageFromList(
                                                            file.readAsBytesSync());
                                                    Media media = Media(
                                                      mediaType:
                                                          MediaType.photo,
                                                      height: image.height,
                                                      width: image.width,
                                                      mediaFile: file,
                                                    );
                                                    mediaList.add(media);
                                                  }
                                                  context.pushNamed(
                                                    "media_forward",
                                                    extra: mediaList,
                                                    params: {
                                                      'chatroomId': widget
                                                          .chatroom.id
                                                          .toString()
                                                    },
                                                  );
                                                }
                                              }
                                            },
                                            child: SizedBox(
                                              width: 40.w,
                                              height: 22.w,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 38.sp,
                                                    height: 38.sp,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40.w),
                                                      color: LMBranding
                                                          .instance.buttonColor,
                                                    ),
                                                    child: Icon(
                                                      Icons.photo_outlined,
                                                      color: kWhiteColor,
                                                      size: 24.sp,
                                                    ),
                                                  ),
                                                  kVerticalPaddingMedium,
                                                  Text(
                                                    "Photo",
                                                    style:
                                                        lmBranding.fonts.medium,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.spaceEvenly,
                                      //   children: [
                                      //     GestureDetector(
                                      //       onTap: () {},
                                      //       child: SizedBox(
                                      //         width: 40.w,
                                      //         height: 22.w,
                                      //         child: Column(
                                      //           mainAxisAlignment:
                                      //               MainAxisAlignment.center,
                                      //           children: [
                                      //             Container(
                                      //               width: 38.sp,
                                      //               height: 38.sp,
                                      //               decoration: BoxDecoration(
                                      //                 borderRadius:
                                      //                     BorderRadius.circular(40.w),
                                      //                 color: LMBranding
                                      //                     .instance.buttonColor,
                                      //               ),
                                      //               child: Icon(
                                      //                 Icons.video_camera_back,
                                      //                 color: kWhiteColor,
                                      //                 size: 24.sp,
                                      //               ),
                                      //             ),
                                      //             kVerticalPaddingMedium,
                                      //             Text(
                                      //               "Video",
                                      //               style: lmBranding.fonts.medium,
                                      //             ),
                                      //           ],
                                      //         ),
                                      //       ),
                                      //     ),
                                      //     GestureDetector(
                                      //       onTap: () async {
                                      //         FilePickerResult? pickedFile =
                                      //             await filePicker!.pickFiles(
                                      //                 allowMultiple: false,
                                      //                 type: FileType.custom,
                                      //                 allowedExtensions: ['pdf']);
                                      //         if (pickedFile != null) {
                                      //           File file =
                                      //               File(pickedFile.paths.first!);
                                      //           PdfViewerController
                                      //               pdfViewerController =
                                      //               PdfViewerController();
                                      //           PdfViewer.openFile(
                                      //             file.path,
                                      //             viewerController:
                                      //                 pdfViewerController,
                                      //           );

                                      //           PdfPageImage pdfImage =
                                      //               await pdfViewerController
                                      //                   .getPage(1)
                                      //                   .render();
                                      //           ui.Image image = await pdfImage
                                      //               .createImageDetached();

                                      //           final tempDir =
                                      //               await getApplicationDocumentsDirectory();
                                      //           File thumbnailFile = File(
                                      //               "${tempDir.path}/thumbnail_image.png");

                                      //           final data = await image.toByteData(
                                      //             format: ui.ImageByteFormat.png,
                                      //           );

                                      //           final bytes =
                                      //               data!.buffer.asUint64List();

                                      //           thumbnailFile = await thumbnailFile
                                      //               .writeAsBytes(bytes, flush: true);

                                      //           Media media = Media(
                                      //             mediaType: MediaType.document,
                                      //             mediaFile: file,
                                      //             height: image.height,
                                      //             width: image.width,
                                      //             pageCount:
                                      //                 pdfViewerController.pageCount,
                                      //             size: pickedFile.files.first.size,
                                      //             thumbnailFile: thumbnailFile,
                                      //           );
                                      //         }
                                      //       },
                                      //       child: SizedBox(
                                      //         width: 40.w,
                                      //         height: 22.w,
                                      //         child: Column(
                                      //           mainAxisAlignment:
                                      //               MainAxisAlignment.center,
                                      //           children: [
                                      //             Container(
                                      //               width: 38.sp,
                                      //               height: 38.sp,
                                      //               decoration: BoxDecoration(
                                      //                 borderRadius:
                                      //                     BorderRadius.circular(40.w),
                                      //                 color: LMBranding
                                      //                     .instance.buttonColor,
                                      //               ),
                                      //               child: Icon(
                                      //                 Icons.file_copy_outlined,
                                      //                 color: kWhiteColor,
                                      //                 size: 24.sp,
                                      //               ),
                                      //             ),
                                      //             kVerticalPaddingMedium,
                                      //             Text(
                                      //               "Document",
                                      //               style: lmBranding.fonts.medium,
                                      //             ),
                                      //           ],
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          pressType: PressType.singleClick,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 1.h,
                            ),
                            child: const Icon(Icons.attach_file),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                GestureDetector(
                  onTap: () {
                    if (_textEditingController.text.isEmpty) {
                      Fluttertoast.showToast(msg: "Text can't be empty");
                    } else {
                      // Fluttertoast.showToast(msg: "Send message");
                      final string = _textEditingController.text;
                      userTags = TaggingHelper.matchTags(string, userTags);
                      result = TaggingHelper.encodeString(string, userTags);
                      result = result?.trim();
                      chatActionBloc!.add(PostConversation(
                          (PostConversationRequestBuilder()
                                ..chatroomId(widget.chatroom.id)
                                ..text(result!)
                                ..replyId(replyToConversation?.id)
                                ..temporaryId(DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString()))
                              .build()));
                      _textEditingController.clear();
                      userTags = [];
                      result = "";
                      replyToConversation = null;
                      widget.scrollToBottom();
                    }
                  },
                  child: Container(
                    height: 12.w,
                    width: 12.w,
                    decoration: BoxDecoration(
                      color: LMBranding.instance.buttonColor,
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
