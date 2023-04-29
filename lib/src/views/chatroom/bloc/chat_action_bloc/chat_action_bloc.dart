import 'dart:io';

import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:bloc/bloc.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_mm_fl/src/views/conversation/bloc/conversation_bloc.dart';

part 'chat_action_event.dart';
part 'chat_action_state.dart';

class ChatActionBloc extends Bloc<ChatActionEvent, ChatActionState> {
  ChatActionBloc() : super(ConversationInitial()) {
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
