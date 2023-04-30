import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:bloc/bloc.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_mm_fl/src/utils/realtime/realtime.dart';
import 'package:likeminds_chat_mm_fl/src/views/conversation/bloc/conversation_bloc.dart';

part 'chat_action_event.dart';
part 'chat_action_state.dart';

class ChatActionBloc extends Bloc<ChatActionEvent, ChatActionState> {
  final DatabaseReference realTime = LMRealtime.instance.chatroom();
  int? lastConversationId;

  ChatActionBloc() : super(ConversationInitial()) {
    on<NewConversation>((event, emit) {
      int chatroomId = event.chatroomId;
      lastConversationId = event.conversationId;

      realTime.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final response = event.snapshot.value as Map;
          final conversationId = int.parse(response["collabcard"]["answer_id"]);
          if (lastConversationId != null &&
              conversationId != lastConversationId) {
            add(UpdateConversationList(
              chatroomId: chatroomId,
              conversationId: conversationId,
            ));
          }
        }
      });
    });
    on<UpdateConversationList>((event, emit) async {
      if (lastConversationId != null &&
          event.conversationId != lastConversationId) {
        final response = await locator<LikeMindsService>()
            .getSingleConversation((GetSingleConversationRequestBuilder()
                  ..chatroomId(event.chatroomId)
                  ..conversationId(event.conversationId))
                .build());
        if (response.success) {
          emit(UpdateConversation(response.data!.conversation!));
        }
      }
    });
    on<PostConversation>((event, emit) async {
      await mapPostConversationFunction(event.postConversationRequest, emit);
    });
    on<PostMultiMediaConversation>(
      (event, emit) async {
        mapPostConversationFunction(event.postConversationRequest, emit);
      },
    );
  }

  mapPostConversationFunction(PostConversationRequest postConversationRequest,
      Emitter<ChatActionState> emit) async {
    try {
      LMResponse<PostConversationResponse> response =
          await locator<LikeMindsService>()
              .postConversation(postConversationRequest);

      if (response.success) {
        if (response.data!.success) {
          lastConversationId = response.data!.conversation!.id;
          emit(ConversationPosted(response.data!));
        } else {
          emit(ChatActionError(response.data!.errorMessage!,
              postConversationRequest.temporaryId));
        }
      } else {
        emit(ChatActionError(
            response.errorMessage!, postConversationRequest.temporaryId));
      }
    } catch (e) {
      emit(ChatActionError(
          "An error occurred", postConversationRequest.temporaryId));
    }
  }
}
