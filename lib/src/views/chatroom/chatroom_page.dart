import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/packages/expandable_text/expandable_text.dart';
import 'package:likeminds_chat_mm_fl/src/navigation/router.dart';
import 'package:likeminds_chat_mm_fl/src/utils/analytics/analytics.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/chatroom/conversation_utils.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/utils/media/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/utils/simple_bloc_observer.dart';
import 'package:likeminds_chat_mm_fl/src/utils/tagging/helpers/tagging_helper.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chat_action_bloc/chat_action_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/chat_bar.dart';
import 'package:likeminds_chat_mm_fl/src/views/conversation/bloc/conversation_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/bloc/home_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/picture_or_initial.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/spinner.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/back_button.dart' as BB;
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/chatroom_skeleton.dart';

import 'bloc/chatroom_bloc.dart';
import 'chatroom_components/chat_bubble.dart';
import 'chatroom_components/chatroom_menu.dart';

class ChatroomPage extends StatefulWidget {
  final int chatroomId;
  final bool isRoot;
  const ChatroomPage({
    super.key,
    required this.chatroomId,
    required this.isRoot,
  });

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  bool? isCm;
  ChatActionBloc? chatActionBloc;
  Map<String, dynamic> conversationAttachmentsMeta = <String, dynamic>{};
  Map<String, List<Media>> mediaFiles = <String, List<Media>>{};
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  ValueNotifier rebuildConversationList = ValueNotifier(false);
  final ConversationBloc conversationBloc = ConversationBloc();
  Map<int, User?> userMeta = <int, User?>{};
  ChatRoom? chatroom;
  ValueNotifier rebuildChatBar = ValueNotifier(false);
  ValueNotifier showConversationActions = ValueNotifier(false);
  User currentUser = UserLocalPreference.instance.fetchUserData();
  bool showScrollButton = false;
  int lastConversationId = 0;
  List<Conversation> selectedConversations = <Conversation>[];

  ScrollController scrollController = ScrollController();
  PagingController<int, Conversation> pagedListController =
      PagingController<int, Conversation>(firstPageKey: 1);

  int _page = 1;

  @override
  void initState() {
    super.initState();
    Bloc.observer = SimpleBlocObserver();
    _addPaginationListener();
    scrollController.addListener(() {
      _showScrollToBottomButton();
    });
    chatActionBloc = BlocProvider.of<ChatActionBloc>(context);
    // conversationBloc = ConversationBloc();
    isCm = UserLocalPreference.instance.fetchMemberState();
  }

  @override
  void dispose() {
    pagedListController.dispose();
    scrollController.dispose();
    lastConversationId = 0;
    super.dispose();
  }

  _addPaginationListener() {
    pagedListController.addPageRequestListener(
      (pageKey) {
        conversationBloc.add(
          GetConversation(
            getConversationRequest: (GetConversationRequestBuilder()
                  ..chatroomId(widget.chatroomId)
                  ..page(pageKey)
                  ..pageSize(500)
                  ..minTimestamp(0)
                  ..maxTimestamp(currentTime))
                .build(),
          ),
        );
      },
    );
  }

  void addConversationToPagedList(Conversation conversation) {
    List<Conversation> conversationList =
        pagedListController.itemList ?? <Conversation>[];

    if (conversationList.isNotEmpty) {
      if (conversationList.first.date != conversation.date) {
        conversationList.insert(
          0,
          Conversation(
            isTimeStamp: true,
            id: 1,
            hasFiles: false,
            attachmentCount: 0,
            attachmentsUploaded: false,
            createdEpoch: conversation.createdEpoch,
            chatroomId: chatroom!.id,
            date: conversation.date,
            memberId: conversation.memberId,
            userId: conversation.userId,
            temporaryId: conversation.temporaryId,
            answer: conversation.date ?? '',
            communityId: chatroom!.communityId!,
            createdAt: conversation.createdAt,
            header: conversation.header,
          ),
        );
      }
    }
    conversationList.insert(0, conversation);
    if (conversationList.length >= 500) {
      conversationList.removeLast();
    }
    if (!userMeta.containsKey(currentUser.id)) {
      userMeta[currentUser.id] = currentUser;
    }
    pagedListController.itemList = conversationList;
    rebuildConversationList.value = !rebuildConversationList.value;
  }

  void addMultiMediaConversation(MultiMediaConversationPosted state) {
    if (!userMeta.containsKey(currentUser.id)) {
      userMeta[currentUser.id] = currentUser;
    }
    if (!conversationAttachmentsMeta
        .containsKey(state.postConversationResponse.conversation!.id)) {
      conversationAttachmentsMeta[
              '${state.postConversationResponse.conversation!.id}'] =
          state.putMediaResponse;
    }
    List<Conversation> conversationList =
        pagedListController.itemList ?? <Conversation>[];

    conversationList.removeWhere((element) =>
        element.temporaryId ==
        state.postConversationResponse.conversation!.temporaryId);

    mediaFiles.remove(state.postConversationResponse.conversation!.temporaryId);

    conversationList.insert(
      0,
      Conversation(
        id: state.postConversationResponse.conversation!.id,
        hasFiles: true,
        attachmentCount: state.putMediaResponse.length,
        attachmentsUploaded: true,
        chatroomId: chatroom!.id,
        state: state.postConversationResponse.conversation!.state,
        date: state.postConversationResponse.conversation!.date,
        memberId: state.postConversationResponse.conversation!.memberId,
        userId: state.postConversationResponse.conversation!.userId,
        temporaryId: state.postConversationResponse.conversation!.temporaryId,
        answer: state.postConversationResponse.conversation!.answer,
        communityId: chatroom!.communityId!,
        createdAt: state.postConversationResponse.conversation!.createdAt,
        header: state.postConversationResponse.conversation!.header,
      ),
    );

    if (conversationList.length >= 500) {
      conversationList.removeLast();
    }
    rebuildConversationList.value = !rebuildConversationList.value;
  }

  void _scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void _showScrollToBottomButton() {
    if (scrollController.position.pixels >
        scrollController.position.viewportDimension) {
      _showButton();
    }
    if (scrollController.position.pixels <
        scrollController.position.viewportDimension) {
      _hideButton();
    }
  }

  void _showButton() {
    setState(() {
      showScrollButton = true;
    });
  }

  void _hideButton() {
    setState(() {
      showScrollButton = false;
    });
  }

  void updatePagingControllers(Object? state) {
    if (state is ConversationLoaded) {
      _page++;

      if (state.getConversationResponse.conversationAttachmentsMeta != null &&
          state.getConversationResponse.conversationAttachmentsMeta!
              .isNotEmpty) {
        conversationAttachmentsMeta
            .addAll(state.getConversationResponse.conversationAttachmentsMeta!);
      }

      if (state.getConversationResponse.userMeta != null) {
        userMeta.addAll(state.getConversationResponse.userMeta!);
      }
      List<Conversation>? conversationData =
          state.getConversationResponse.conversationData;
      conversationData = addTimeStampInConversationList(
          conversationData, chatroom!.communityId!);
      if (state.getConversationResponse.conversationData == null ||
          state.getConversationResponse.conversationData!.isEmpty ||
          state.getConversationResponse.conversationData!.length < 500) {
        pagedListController.appendLastPage(conversationData ?? []);
      } else {
        pagedListController.appendPage(conversationData!, _page);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // conversationBloc = BlocProvider.of<ConversationBloc>(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: () async {
          debugPrint(router.location);
          conversationBloc.add(
            MarkReadChatroomEvent(chatroomId: widget.chatroomId),
          );
          BlocProvider.of<HomeBloc>(context).add(UpdateHomeEvent());
          context.pop();
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: showScrollButton
              ? Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Container(
                    height: 32.sp,
                    width: 32.sp,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.sp),
                      color: LMTheme.buttonColor,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 4),
                          blurRadius: 25,
                          color: kBlackColor.withOpacity(0.3),
                        )
                      ],
                    ),
                    child: Center(
                      child: IconButton(
                        iconSize: 18.sp,
                        onPressed: () {
                          _scrollToBottom();
                        },
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
          body: SafeArea(
            bottom: false,
            left: false,
            right: false,
            child: BlocConsumer<ChatroomBloc, ChatroomState>(
              listener: (context, state) {
                if (state is ChatroomLoaded) {
                  chatroom = state.getChatroomResponse.chatroom!;
                  lastConversationId =
                      state.getChatroomResponse.lastConversationId!;
                  chatActionBloc?.add(
                    NewConversation(
                      chatroomId: chatroom!.id,
                      conversationId: lastConversationId,
                    ),
                  );
                }
              },
              builder: (context, state) {
                // return const SkeletonChatList();
                if (state is ChatroomLoading) {
                  return const SkeletonChatPage();
                }

                if (state is ChatroomLoaded) {
                  LMAnalytics.get().track(AnalyticsKeys.chatroomOpened, {
                    'chatroom_id': chatroom!.id,
                    'community_id': chatroom!.communityId,
                    'chatroom_type': chatroom!.type,
                    'source': 'home_feed',
                  });
                  var pagedListView = ValueListenableBuilder(
                    valueListenable: rebuildConversationList,
                    builder: (context, _, __) {
                      return BlocConsumer<ConversationBloc, ConversationState>(
                          bloc: conversationBloc,
                          listener: (context, state) =>
                              updatePagingControllers(state),
                          builder: (context, state) {
                            return PagedListView(
                              pagingController: pagedListController,
                              scrollController: scrollController,
                              physics: const ClampingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              reverse: true,
                              scrollDirection: Axis.vertical,
                              builderDelegate:
                                  PagedChildBuilderDelegate<Conversation>(
                                noItemsFoundIndicatorBuilder: (context) =>
                                    const SizedBox(
                                  height: 10,
                                ),
                                firstPageProgressIndicatorBuilder: (context) =>
                                    SkeletonChatList(),
                                newPageProgressIndicatorBuilder: (context) =>
                                    Padding(
                                  padding: EdgeInsets.symmetric(vertical: 1.h),
                                  child: Column(
                                    children: const [
                                      SkeletonChatBubble(isSent: true),
                                      SkeletonChatBubble(isSent: false),
                                      SkeletonChatBubble(isSent: true),
                                    ],
                                  ),
                                ),
                                animateTransitions: true,
                                transitionDuration:
                                    const Duration(milliseconds: 500),
                                itemBuilder: (context, item, index) {
                                  if (item.isTimeStamp != null &&
                                          item.isTimeStamp! ||
                                      item.state != 0 && item.state != null) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: item.isTimeStamp == null ||
                                                  !item.isTimeStamp!
                                              ? 70.w
                                              : 35.w,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: kWhiteColor.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                              TaggingHelper.extractStateMessage(
                                                  item.answer),
                                              textAlign: TextAlign.center,
                                              style: LMTheme.medium.copyWith(
                                                fontSize: 9.sp,
                                              )),
                                        )
                                      ],
                                    );
                                  }
                                  // item.
                                  return ChatBubble(
                                    key: Key(item.id.toString()),
                                    onReply: (replyingTo) {
                                      if (chatActionBloc == null) {
                                        return;
                                      }
                                      chatActionBloc?.add(
                                        ReplyConversation(
                                          chatroomId: chatroom!.id,
                                          conversationId: item.id,
                                          replyConversation: replyingTo,
                                        ),
                                      );
                                    },
                                    replyToConversation:
                                        item.replyConversationObject,
                                    chatroom: chatroom!,
                                    conversation: item,
                                    sender: userMeta[
                                            item.userId ?? item.memberId] ??
                                        item.member!,
                                    mediaFiles: mediaFiles,
                                    conversationAttachments:
                                        conversationAttachmentsMeta
                                                .containsKey(item.id.toString())
                                            ? conversationAttachmentsMeta[
                                                '${item.id}']
                                            : null,
                                    isSelected: (isSelected) {
                                      if (isSelected) {
                                        selectedConversations.add(item);
                                      } else {
                                        selectedConversations.remove(item);
                                      }
                                    },
                                    onLongPress: (conversation) {
                                      _startSelection(conversation);
                                    },
                                  );
                                },
                              ),
                            );
                          });
                    },
                  );

                  return Column(
                    children: [
                      Container(
                        decoration:
                            BoxDecoration(color: kWhiteColor, boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 10),
                          )
                        ]),
                        child: Column(
                          children: <Widget>[
                            kVerticalPaddingMedium,
                            ValueListenableBuilder(
                              valueListenable: showConversationActions,
                              builder: (BuildContext context, dynamic value,
                                  Widget? child) {
                                if (value) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 2.w),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            _clearSelection();
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            size: 16.sp,
                                            color: Colors.red,
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          '${selectedConversations.length} selected',
                                          style: LMTheme.medium.copyWith(
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {},
                                              icon: Icon(
                                                Icons.reply,
                                                size: 16.sp,
                                                color: LMTheme.buttonColor,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                // _copySelectedConversations();
                                              },
                                              icon: Icon(
                                                Icons.copy,
                                                size: 16.sp,
                                                color: LMTheme.buttonColor,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                // _deleteSelectedConversations();
                                              },
                                              icon: Icon(
                                                Icons.delete,
                                                size: 16.sp,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 0.8.h,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Visibility(
                                          visible: !widget.isRoot,
                                          child: BB.BackButton(
                                            onTap: () {
                                              BlocProvider.of<HomeBloc>(context)
                                                  .add(UpdateHomeEvent());
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        PictureOrInitial(
                                          fallbackText: chatroom!.header,
                                          imageUrl: chatroom?.chatroomImageUrl,
                                          size: 30.sp,
                                          fontSize: 14.sp,
                                        ),
                                        SizedBox(width: 4.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                chatroom!.header,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: LMTheme.medium.copyWith(
                                                  fontSize: 11.sp,
                                                ),
                                              ),
                                              kVerticalPaddingSmall,
                                              Text(
                                                '${chatroom!.participantCount} participants',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: LMTheme.regular.copyWith(
                                                  fontSize: 9.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        kHorizontalPaddingMedium,
                                        ChatroomMenu(
                                          chatroom: chatroom!,
                                          chatroomActions: state
                                              .getChatroomResponse
                                              .chatroomActions!,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const BB.BackButton(),
                                    SizedBox(width: 4.w),
                                    PictureOrInitial(
                                      fallbackText: chatroom!.header,
                                      imageUrl: chatroom?.chatroomImageUrl,
                                      size: 30.sp,
                                      fontSize: 14.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            chatroom!.header,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: LMTheme.medium.copyWith(
                                              fontSize: 11.sp,
                                            ),
                                          ),
                                          kVerticalPaddingSmall,
                                          Text(
                                            '${chatroom!.participantCount} participants',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: LMTheme.regular.copyWith(
                                              fontSize: 9.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    kHorizontalPaddingMedium,
                                    ChatroomMenu(
                                      chatroom: chatroom!,
                                      chatroomActions: state
                                          .getChatroomResponse.chatroomActions!,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            kVerticalPaddingMedium,
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: kGreyColor.withOpacity(0.2),
                          child: pagedListView,
                        ),
                      ),
                      BlocConsumer(
                          bloc: chatActionBloc,
                          listener: (context, state) {
                            if (state is ConversationPosted) {
                              addConversationToPagedList(
                                state.postConversationResponse.conversation!,
                              );
                            } else if (state is MultiMediaConversationLoading) {
                              if (!userMeta.containsKey(currentUser.id)) {
                                userMeta[currentUser.id] = currentUser;
                              }
                              mediaFiles[state
                                  .postConversationResponse
                                  .conversation!
                                  .temporaryId!] = state.mediaFiles;

                              List<Conversation> conversationList =
                                  pagedListController.itemList ??
                                      <Conversation>[];

                              conversationList.insert(0,
                                  state.postConversationResponse.conversation!);

                              rebuildConversationList.value =
                                  !rebuildConversationList.value;
                            } else if (state is MultiMediaConversationPosted) {
                              addMultiMediaConversation(
                                state,
                              );
                            }
                            if (state is UpdateConversation) {
                              if (state.response.id != lastConversationId) {
                                addConversationToPagedList(
                                  state.response,
                                );
                                lastConversationId = state.response.id;
                              }
                            }
                            if (state is ReplyConversationState) {
                              rebuildChatBar.value = !rebuildChatBar.value;
                            }
                          },
                          builder: (context, state) {
                            return ValueListenableBuilder(
                                valueListenable: rebuildChatBar,
                                builder: (context, _, __) {
                                  if (state is ReplyConversationState) {
                                    return ChatBar(
                                      chatroom: chatroom!,
                                      replyToConversation: state.conversation,
                                      scrollToBottom: _scrollToBottom,
                                    );
                                  }
                                  return ChatBar(
                                    chatroom: chatroom!,
                                    scrollToBottom: _scrollToBottom,
                                  );
                                });
                          }),
                    ],
                  );
                }
                return Container(
                  color: kGreyColor.withOpacity(0.2),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _clearSelection() {
    selectedConversations.clear();
    showConversationActions.value = false;
    // rebuildConversationList.value = !rebuildConversationList.value;
  }

  void _startSelection(Conversation conversation) {
    // showConversationActions.value = true;
  }
}
