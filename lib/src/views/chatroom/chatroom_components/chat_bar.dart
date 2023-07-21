import 'dart:io';
import 'dart:ui' as ui;

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/navigation/router.dart';
import 'package:likeminds_chat_mm_fl/src/utils/analytics/analytics.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/service/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/utils/media/permission_handler.dart';
import 'package:likeminds_chat_mm_fl/src/utils/member_rights/member_rights.dart';
import 'package:likeminds_chat_mm_fl/src/utils/simple_bloc_observer.dart';
import 'package:likeminds_chat_mm_fl/src/utils/tagging/helpers/tagging_helper.dart';
import 'package:likeminds_chat_mm_fl/src/utils/tagging/tagging_textfield_ta.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chat_action_bloc/chat_action_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/widget/media_helper_widget.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/media_utils.dart';

class ChatBar extends StatefulWidget {
  final ChatRoom chatroom;
  final Conversation? replyToConversation;
  final List<Media>? replyConversationAttachments;
  final Conversation? editConversation;
  final Map<int, User?>? userMeta;
  final FocusNode focusNode;
  final Function() scrollToBottom;

  const ChatBar({
    super.key,
    required this.chatroom,
    this.replyToConversation,
    this.replyConversationAttachments,
    this.editConversation,
    required this.scrollToBottom,
    this.userMeta,
    required this.focusNode,
  });

  @override
  State<ChatBar> createState() => _ChatBarState();
}

class _ChatBarState extends State<ChatBar> {
  ChatActionBloc? chatActionBloc;
  ImagePicker? imagePicker;
  FilePicker? filePicker;
  Conversation? replyToConversation;
  List<Media>? replyConversationAttachments;
  Conversation? editConversation;
  Map<int, User?>? userMeta;
  late CustomPopupMenuController _popupMenuController;
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  LMBranding lmBranding = LMBranding.instance;
  User currentUser = UserLocalPreference.instance.fetchUserData();
  MemberStateResponse getMemberState =
      UserLocalPreference.instance.fetchMemberRights();

  List<UserTag> userTags = [];
  String? result;

  @override
  void initState() {
    Bloc.observer = SimpleBlocObserver();
    _popupMenuController = CustomPopupMenuController();
    _textEditingController = TextEditingController();
    _focusNode = widget.focusNode;
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
    replyToConversation = null;
    super.dispose();
  }

  bool checkIfSecretAndJoined() {
    if (widget.chatroom.isSecret == null) {
      return true;
    } else {
      if (widget.chatroom.isSecret!) {
        return widget.chatroom.followStatus!;
      } else {
        return true;
      }
    }
  }

  bool checkIfAnnouncementChannel() {
    if (getMemberState.member!.state != 1 && widget.chatroom.type == 7) {
      return false;
    } else if (!MemberRightCheck.checkRespondRights(getMemberState)) {
      return false;
    } else {
      return true;
    }
  }

  String getChatBarHintText() {
    if (getMemberState.member!.state != 1 && widget.chatroom.type == 7) {
      return 'Only Community Managers can respond here';
    } else if (!MemberRightCheck.checkRespondRights(getMemberState)) {
      return 'The community managers have restricted you from responding here';
    } else if (!checkIfSecretAndJoined()) {
      return "Join this chat room to participate in this chat room.";
    } else {
      return "Write something here";
    }
  }

  void setupEditText() {
    editConversation = widget.editConversation;
    String? convertedMsgText =
        TaggingHelper.convertRouteToTag(editConversation?.answer);
    if (widget.editConversation == null) {
      return;
    }
    _textEditingController.value =
        TextEditingValue(text: convertedMsgText ?? '');
    _textEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textEditingController.text.length));
    userTags =
        TaggingHelper.addUserTagsIfMatched(editConversation?.answer ?? '');
    if (editConversation != null) {
      _focusNode.requestFocus();
    }
  }

  void setupReplyText() {
    replyToConversation = widget.replyToConversation;
    replyConversationAttachments = widget.replyConversationAttachments;
    if (replyToConversation != null) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    setupReplyText();
    setupEditText();
    userMeta = widget.userMeta;
    chatActionBloc = BlocProvider.of<ChatActionBloc>(context);
    return Column(
      children: [
        replyToConversation != null &&
                checkIfAnnouncementChannel() &&
                checkIfSecretAndJoined()
            ? _getReplyConversation()
            : const SizedBox(),
        editConversation != null &&
                checkIfAnnouncementChannel() &&
                checkIfSecretAndJoined()
            ? _getEditConversation()
            : const SizedBox(),
        Container(
          width: 100.w,
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
                  width:
                      checkIfAnnouncementChannel() && checkIfSecretAndJoined()
                          ? 80.w
                          : 90.w,
                  constraints: BoxConstraints(
                    // minHeight: 4.h,
                    minHeight: 12.w,
                    maxHeight: 24.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kPaddingSmall,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TaggingAheadTextField(
                            isDown: false,
                            chatroomId: widget.chatroom.id,
                            style: LMTheme.regular.copyWith(fontSize: 10.sp),
                            onTagSelected: (tag) {
                              debugPrint(tag.toString());
                              userTags.add(tag);
                              LMAnalytics.get()
                                  .logEvent(AnalyticsKeys.userTagsSomeone, {
                                'community_id': widget.chatroom.id,
                                'chatroom_name': widget.chatroom.title,
                                'tagged_user_id': tag.id,
                                'tagged_user_name': tag.name,
                              });
                            },
                            onChange: (value) {},
                            controller: _textEditingController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabled: checkIfAnnouncementChannel() &&
                                  checkIfSecretAndJoined(),
                              hintMaxLines: 2,
                              hintStyle: LMTheme.medium.copyWith(
                                color: kGreyColor,
                                fontSize: 9.sp,
                              ),
                              hintText: getChatBarHintText(),
                            ),
                            hintText: getChatBarHintText(),
                          ),
                          focusNode: _focusNode,
                        ),
                        checkIfAnnouncementChannel() && checkIfSecretAndJoined()
                            ? CustomPopupMenu(
                                controller: _popupMenuController,
                                arrowColor: Colors.white,
                                showArrow: false,
                                menuBuilder: () => Container(
                                  margin: EdgeInsets.only(bottom: 1.h),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 100.w,
                                      // height: ,
                                      color: Colors.white,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 6.w,
                                          horizontal: 4.w,
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
                                                    _popupMenuController
                                                        .hideMenu();
                                                    if (await handlePermissions(
                                                        1)) {
                                                      XFile? pickedImage =
                                                          await imagePicker!
                                                              .pickImage(
                                                                  source:
                                                                      ImageSource
                                                                          .camera);
                                                      List<Media> mediaList =
                                                          [];
                                                      if (pickedImage != null) {
                                                        File file = File(
                                                            pickedImage.path);
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
                                                        router.pushNamed(
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
                                                  }
                                                },
                                                child: SizedBox(
                                                  width: 25.w,
                                                  height: 12.h,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: 40.sp,
                                                        height: 40.sp,
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: LMBranding
                                                                .instance
                                                                .buttonColor),
                                                        child: Icon(
                                                            Icons
                                                                .camera_alt_outlined,
                                                            color: kWhiteColor,
                                                            size: 25.sp),
                                                      ),
                                                      kVerticalPaddingMedium,
                                                      Text(
                                                        "Camera",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: lmBranding
                                                            .fonts.medium,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  _popupMenuController
                                                      .hideMenu();
                                                  if (await handlePermissions(
                                                      2)) {
                                                    List<Media>
                                                        pickedMediaFiles =
                                                        await pickMediaFiles();
                                                    if (pickedMediaFiles
                                                            .length >
                                                        10) {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              'Only 10 attachments can be sent');
                                                      return;
                                                    }

                                                    if (pickedMediaFiles
                                                        .isNotEmpty) {
                                                      for (Media mediaFile
                                                          in pickedMediaFiles) {
                                                        if (getFileSizeInDouble(
                                                                mediaFile
                                                                    .size!) >
                                                            100) {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  'File size should be smaller than 100 MB');
                                                          pickedMediaFiles
                                                              .remove(
                                                                  mediaFile);
                                                        }
                                                      }
                                                    }
                                                    if (pickedMediaFiles
                                                        .isNotEmpty) {
                                                      router.pushNamed(
                                                        "media_forward",
                                                        extra: pickedMediaFiles,
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
                                                  width: 25.w,
                                                  height: 12.h,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: 40.sp,
                                                        height: 40.sp,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: LMBranding
                                                              .instance
                                                              .buttonColor,
                                                        ),
                                                        child: Icon(
                                                          Icons.photo_library,
                                                          color: kWhiteColor,
                                                          size: 25.sp,
                                                        ),
                                                      ),
                                                      kVerticalPaddingMedium,
                                                      Text(
                                                        "Gallery",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: lmBranding
                                                            .fonts.medium,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  _popupMenuController
                                                      .hideMenu();
                                                  if (await handlePermissions(
                                                      3)) {
                                                    List<Media>
                                                        pickedMediaFiles =
                                                        await pickDocumentFiles();
                                                    if (pickedMediaFiles
                                                        .isNotEmpty) {
                                                      router.pushNamed(
                                                        "media_forward",
                                                        extra: pickedMediaFiles,
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
                                                  width: 25.w,
                                                  height: 12.h,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: 40.sp,
                                                        height: 40.sp,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: LMBranding
                                                              .instance
                                                              .buttonColor,
                                                        ),
                                                        child: Icon(
                                                          Icons
                                                              .file_copy_outlined,
                                                          color: kWhiteColor,
                                                          size: 25.sp,
                                                        ),
                                                      ),
                                                      kVerticalPaddingMedium,
                                                      Text(
                                                        "Document",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: lmBranding
                                                            .fonts.medium,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              pressType: PressType.singleClick,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 3.w,
                                ),
                                child: const Icon(Icons.attach_file),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                checkIfAnnouncementChannel() && checkIfSecretAndJoined()
                    ? GestureDetector(
                        onTap: checkIfAnnouncementChannel()
                            ? () {
                                if (_textEditingController.text.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg: "Text can't be empty");
                                } else {
                                  // Fluttertoast.showToast(msg: "Send message");
                                  chatActionBloc!.add(
                                    PostConversation(
                                        (PostConversationRequestBuilder()
                                              ..chatroomId(widget.chatroom.id)
                                              ..text(result!)
                                              ..replyId(replyToConversation?.id)
                                              ..temporaryId(DateTime.now()
                                                  .millisecondsSinceEpoch
                                                  .toString()))
                                            .build(),
                                        replyConversation: editConversation!
                                            .replyConversationObject));
                                  } else {
                                    // Fluttertoast.showToast(msg: "Send message");
                                    chatActionBloc!.add(
                                      PostConversation(
                                          (PostConversationRequestBuilder()
                                                ..chatroomId(widget.chatroom.id)
                                                ..text(result!)
                                                ..replyId(
                                                    replyToConversation?.id)
                                                ..temporaryId(DateTime.now()
                                                    .millisecondsSinceEpoch
                                                    .toString()))
                                              .build(),
                                          replyConversation:
                                              replyToConversation),
                                    );
                                  }
                                  if (widget.chatroom.followStatus != null &&
                                      !widget.chatroom.followStatus!) {
                                    Fluttertoast.showToast(
                                        msg: "Chatroom joined");
                                    widget.chatroom.followStatus = true;
                                  }
                                  _textEditingController.clear();
                                  userTags = [];
                                  result = "";
                                  if (editConversation == null) {
                                    widget.scrollToBottom();
                                  }
                                  editConversation = null;
                                  replyToConversation = null;
                                }
                                if (widget.chatroom.isGuest ?? false) {
                                  Fluttertoast.showToast(
                                      msg: "Chatroom joined");
                                  widget.chatroom.isGuest = false;
                                }
                                _textEditingController.clear();
                                userTags = [];
                                result = "";
                                if (editConversation == null) {
                                  widget.scrollToBottom();
                                }
                                editConversation = null;
                                replyToConversation = null;
                              }
                            }
                          : () {},
                      child: Container(
                        height: 12.w,
                        width: 12.w,
                        decoration: BoxDecoration(
                            color: checkIfAnnouncementChannel()
                                ? LMBranding.instance.buttonColor
                                : kGreyColor,
                            borderRadius: BorderRadius.circular(6.w),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 4),
                                blurRadius: 25,
                                color: kBlackColor.withOpacity(0.3),
                              )
                            ]),
                        child: Center(
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }

  Container _getReplyConversation() {
    if (replyToConversation == null) {
      return Container();
    }
    return Container(
      height: 10.h,
      width: 100.w,
      color: kWhiteColor,
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
                            replyToConversation!.member?.name ??
                                userMeta?[replyToConversation?.userId]?.name ??
                                '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: LMTheme.medium.copyWith(
                              color: LMTheme.headerColor,
                            ),
                          ),
                          kVerticalPaddingSmall,
                          SizedBox(
                            width: 70.w,
                            child: getChatItemAttachmentTile(
                                replyConversationAttachments ?? [],
                                replyToConversation!),
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
                chatActionBloc!.add(ReplyRemove());
              },
              icon: const Icon(
                Icons.close,
                color: kGreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _getEditConversation() {
    return Container(
      height: 8.h,
      width: 100.w,
      color: kWhiteColor,
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
                            "Edit message",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: LMTheme.medium.copyWith(
                              color: LMTheme.headerColor,
                            ),
                          ),
                          kVerticalPaddingSmall,
                          SizedBox(
                            width: 70.w,
                            child: Text(
                              TaggingHelper.convertRouteToTag(
                                  editConversation?.answer,
                                  withTilde: false)!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: LMTheme.regular.copyWith(
                                fontSize: 8.sp,
                              ),
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
                chatActionBloc!.add(EditRemove());
                _textEditingController.clear();
              },
              icon: const Icon(
                Icons.close,
                color: kGreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
