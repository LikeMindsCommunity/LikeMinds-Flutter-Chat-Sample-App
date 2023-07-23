import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chat_action_bloc/chat_action_bloc.dart';

part 'poll_event.dart';
part 'poll_state.dart';

class PollBloc extends Bloc<PollEvents, PollState> {
  PollBloc() : super(PollInitial()) {
    on<SubmitPoll>(mapSubmitPollEvent);
    on<AddPollOption>(mapAddPollOption);
    on<PostPollConversation>(mapPostPollConversation);
    on<GetPollUsers>(mapGetPollUsers);
  }

  void mapSubmitPollEvent(SubmitPoll event, Emitter<PollState> emit) async {
    LMResponse response =
        await locator<LikeMindsService>().submitPoll(event.submitPollRequest);
    if (response.success) {
    } else if (response.errorMessage != null) {}
  }

  void mapAddPollOption(AddPollOption event, Emitter<PollState> emit) async {
    LMResponse response = await locator<LikeMindsService>()
        .addPollOption(event.addPollOptionRequest);
    if (response.success) {
    } else if (response.errorMessage != null) {}
  }

  void mapPostPollConversation(
      PostPollConversation event, Emitter<PollState> emit) async {
    LMResponse response = await locator<LikeMindsService>()
        .postPollConversation(event.postConversationRequest);
    if (response.success) {
    } else if (response.errorMessage != null) {}
  }

  void mapGetPollUsers(GetPollUsers event, Emitter<PollState> emit) async {
    emit(PollUsersLoading(getPollUsersRequest: event.getPollUsersRequest));
    LMResponse response = await locator<LikeMindsService>()
        .getPollUsers(event.getPollUsersRequest);
    if (response.success) {
      emit(PollUsers(getPollUsersResponse: response.data));
    } else {
      emit(PollUsersError(
          errorMessage: response.errorMessage ?? "An error occurred",
          getPollUsersRequest: event.getPollUsersRequest));
    }
  }
}
