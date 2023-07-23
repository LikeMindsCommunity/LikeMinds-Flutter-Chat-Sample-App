part of 'poll_bloc.dart';

class PollEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitPoll extends PollEvents {
  final SubmitPollRequest submitPollRequest;

  SubmitPoll({
    required this.submitPollRequest,
  });

  @override
  List<Object?> get props => [submitPollRequest];
}

class GetPollUsers extends PollEvents {
  final GetPollUsersRequest getPollUsersRequest;

  GetPollUsers({
    required this.getPollUsersRequest,
  });

  @override
  List<Object?> get props => [getPollUsersRequest];
}

class PostPollConversation extends PollEvents {
  final PostPollConversationRequest postConversationRequest;

  PostPollConversation(
    this.postConversationRequest,
  );

  @override
  List<Object?> get props => [
        postConversationRequest,
      ];
}

class AddPollOption extends PollEvents {
  final AddPollOptionRequest addPollOptionRequest;

  AddPollOption(
    this.addPollOptionRequest,
  );

  @override
  List<Object?> get props => [
        addPollOptionRequest,
      ];
}
