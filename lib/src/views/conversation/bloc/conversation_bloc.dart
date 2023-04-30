import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationBloc() : super(ConversationInitial()) {
    on<ConversationEvent>((event, emit) async {
      if (event is GetConversation) {
        if (event.getConversationRequest.page > 1) {
          emit(ConversationPaginationLoading());
        } else {
          emit(ConversationLoading());
        } //Perform logic
        LMResponse response = await locator<LikeMindsService>()
            .getConversation(event.getConversationRequest);
        if (response.success) {
          GetConversationResponse conversationResponse = response.data;
          emit(
            ConversationLoaded(conversationResponse),
          );
        } else {
          emit(
            ConversationError(response.errorMessage!),
          );
        }
      }
      if (event is MarkReadChatroomEvent) {
        LMResponse response =
            await locator<LikeMindsService>().markReadChatroom(
          MarkReadChatroomRequest(
            chatroomId: event.chatroomId,
          ),
        );
      }
    });
  }
}
