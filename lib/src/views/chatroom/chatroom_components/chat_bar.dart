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
  final int chatroomId;
  const ChatBar({super.key, required this.chatroomId});

  @override
  State<ChatBar> createState() => _ChatBarState();
}

class _ChatBarState extends State<ChatBar> {
  ChatActionBloc? chatActionBloc;
  ImagePicker? imagePicker;
  FilePicker? filePicker;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    chatActionBloc = BlocProvider.of<ChatActionBloc>(context);
    return Container(
      width: 100.w,
      color: Colors.grey.withOpacity(0.2),
      padding: EdgeInsets.symmetric(
        horizontal: 3.w,
        vertical: 12,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 80.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TaggingAheadTextField(
                      isDown: false,
                      chatroomId: widget.chatroomId,
                      onTagSelected: (tag) {
                        print(tag);
                        userTags.add(tag);
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                              await imagePicker!.pickImage(
                                            source: ImageSource.camera,
                                          );
                                          List<Media> mediaList = [];
                                          if (pickedImage != null) {
                                            File file = File(pickedImage.path);
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
                                            context.pushNamed("media_forward",
                                                extra: mediaList,
                                                params: {
                                                  'chatroomId': widget
                                                      .chatroomId
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
                                                    BorderRadius.circular(40.w),
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
                                              style: lmBranding.fonts.medium,
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
                                            for (XFile xImage in pickedImage) {
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
                                              File file = File(xImage.path);
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
                                            }
                                            context.pushNamed(
                                              "media_forward",
                                              extra: mediaList,
                                              params: {
                                                'chatroomId':
                                                    widget.chatroomId.toString()
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
                                                    BorderRadius.circular(40.w),
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
                                              style: lmBranding.fonts.medium,
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
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.attach_file),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: () {
                if (_textEditingController.text.isEmpty) {
                  Fluttertoast.showToast(msg: "Text can't be empty");
                } else {
                  Fluttertoast.showToast(msg: "Send message");
                  final string = _textEditingController.text;
                  userTags = TaggingHelper.matchTags(string, userTags);
                  result = TaggingHelper.encodeString(string, userTags);
                  result = result?.trim();
                  chatActionBloc!.add(PostConversation(
                      (PostConversationRequestBuilder()
                            ..chatroomId(widget.chatroomId)
                            ..text(result!)
                            ..temporaryId(DateTime.now()
                                .millisecondsSinceEpoch
                                .toString()))
                          .build()));
                  _textEditingController.clear();
                  userTags = [];
                  result = "";
                }
              },
              child: Container(
                height: 12.w,
                width: 12.w,
                decoration: BoxDecoration(
                  color: LMBranding.instance.buttonColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
