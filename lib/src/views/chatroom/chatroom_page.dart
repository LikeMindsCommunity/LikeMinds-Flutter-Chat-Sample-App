import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/chatroom/conversation_utils.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/utils/media/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/utils/simple_bloc_observer.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chat_action_bloc/chat_action_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/chat_bar.dart';
import 'package:likeminds_chat_mm_fl/src/views/conversation/bloc/conversation_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/picture_or_initial.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/spinner.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/back_button.dart' as BB;

import 'bloc/chatroom_bloc.dart';
import 'chatroom_components/chat_bubble.dart';
import 'chatroom_components/chatroom_menu.dart';

class ChatroomPage extends StatefulWidget {
  final int chatroomId;
  const ChatroomPage({super.key, required this.chatroomId});

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  ChatActionBloc? chatActionBloc;
  Map<String, dynamic> conversationAttachmentsMeta = <String, dynamic>{};
  Map<String, List<Media>> mediaFiles = <String, List<Media>>{};
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  ValueNotifier rebuildConversationList = ValueNotifier(false);
  ConversationBloc? conversationBloc;
  Map<int, User?> userMeta = <int, User?>{};
  ChatRoom? chatroom;
  User currentUser = UserLocalPreference.instance.fetchUserData();

  PagingController<int, Conversation> pagedListController =
      PagingController<int, Conversation>(firstPageKey: 1);

  int _page = 1;

  _addPaginationListener() {
    pagedListController.addPageRequestListener(
      (pageKey) {
        conversationBloc!.add(
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

  @override
  void initState() {
    super.initState();
    Bloc.observer = SimpleBlocObserver();
    _addPaginationListener();
    chatActionBloc = BlocProvider.of<ChatActionBloc>(context);
    conversationBloc = ConversationBloc()
      ..add(
        MarkReadChatroomEvent(chatroomId: widget.chatroomId),
      );
  }

  @override
  void dispose() {
    pagedListController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<ChatroomBloc, ChatroomState>(
          listener: (context, state) {
            if (state is ChatroomLoaded) {
              chatroom = state.getChatroomResponse.chatroom!;
              chatActionBloc?.add(
                NewConversation(
                  chatroomId: chatroom!.id,
                  conversationId: state.getChatroomResponse.lastConversationId!,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ChatroomLoading) {
              return const Spinner();
            }

            if (state is ChatroomLoaded) {
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
                                const Spinner(),
                            newPageProgressIndicatorBuilder: (context) =>
                                const Spinner(),
                            animateTransitions: true,
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            itemBuilder: (context, item, index) {
                              if (item.isTimeStamp != null &&
                                  item.isTimeStamp!) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: kWhiteColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        item.answer,
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ],
                                );
                              }
                              // item.
                              return ChatBubble(
                                key: Key(item.id.toString()),
                                chatroom: chatroom!,
                                conversation: item,
                                sender:
                                    userMeta[item.userId ?? item.memberId] ??
                                        item.member!,
                                mediaFiles: mediaFiles,
                                conversationAttachments:
                                    conversationAttachmentsMeta
                                            .containsKey(item.id.toString())
                                        ? conversationAttachmentsMeta[
                                            '${item.id}']
                                        : null,
                              );
                            },
                          ),
                        );
                      });
                },
              );

              return Column(
                children: [
                  kVerticalPaddingLarge,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const BB.BackButton(),
                        const SizedBox(width: 18),
                        PictureOrInitial(
                          fallbackText: chatroom!.header,
                          imageUrl: chatroom?.chatroomImageUrl,
                          size: 28.sp,
                          fontSize: 14.sp,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Text(
                            chatroom!.header,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LMTheme.medium.copyWith(
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        kHorizontalPaddingMedium,
                        ChatroomMenu(
                          chatroom: chatroom!,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Container(
                      color: LMBranding.instance.headerColor.withOpacity(0.2),
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
                          mediaFiles[state.postConversationResponse
                              .conversation!.temporaryId!] = state.mediaFiles;

                          List<Conversation> conversationList =
                              pagedListController.itemList ?? <Conversation>[];

                          conversationList.insert(
                              0, state.postConversationResponse.conversation!);

                          rebuildConversationList.value =
                              !rebuildConversationList.value;
                        } else if (state is MultiMediaConversationPosted) {
                          addMultiMediaConversation(
                            state,
                          );
                        }
                        if (state is UpdateConversation) {
                          if (currentUser.id ==
                              (state.response.userId ??
                                  state.response.memberId ??
                                  state.response.member!.id)) {
                            addConversationToPagedList(
                              state.response,
                            );
                          }
                        }
                      },
                      builder: (context, state) {
                        return ChatBar(chatroomId: widget.chatroomId);
                      }),
                ],
              );
            }
            return Container(color: Colors.red);
          },
        ),
      ),
    );
  }
}
