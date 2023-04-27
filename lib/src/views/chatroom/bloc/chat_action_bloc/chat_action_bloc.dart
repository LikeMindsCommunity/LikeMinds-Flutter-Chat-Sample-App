import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:bloc/bloc.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';

part 'chat_action_event.dart';
part 'chat_action_state.dart';

class ChatActionBloc extends Bloc<ChatActionEvent, ChatActionState> {
  ChatActionBloc() : super(ConversationInitial()) {
    on<PostConversation>((event, emit) async {
      try {
        LMResponse<PostConversationResponse> response =
            await locator<LikeMindsService>()
                .postConversation(event.postConversationRequest);

        if (response.success) {
          if (response.data!.success) {
            emit(ConversationPosted(response.data!));
          } else {
            emit(ChatActionError(response.data!.errorMessage!));
          }
        } else {
          emit(ChatActionError(response.errorMessage!));
        }
      } catch (e) {
        emit(ChatActionError("An error occurred"));
      }
    });
  }
}
