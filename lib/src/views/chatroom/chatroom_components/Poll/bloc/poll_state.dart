part of 'poll_bloc.dart';

class PollState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PollInitial extends PollState {
  @override
  List<Object?> get props => [];
}

class PollUsers extends PollState {
  final GetPollUsersResponse getPollUsersResponse;

  PollUsers({
    required this.getPollUsersResponse,
  });

  @override
  List<Object?> get props => [
        getPollUsersResponse,
      ];
}

class PollUsersLoading extends PollState {
  final GetPollUsersRequest getPollUsersRequest;

  PollUsersLoading({
    required this.getPollUsersRequest,
  });

  @override
  List<Object?> get props => [
        getPollUsersRequest,
      ];
}

class PollUsersError extends PollState {
  final String errorMessage;
  final GetPollUsersRequest getPollUsersRequest;

  PollUsersError({
    required this.errorMessage,
    required this.getPollUsersRequest,
  });

  @override
  List<Object?> get props => [
        errorMessage,
        getPollUsersRequest,
      ];
}

class SubmittedPoll extends PollState {
  final SubmitPollResponse submitPollResponse;

  SubmittedPoll({
    required this.submitPollResponse,
  });

  @override
  List<Object?> get props => [
        submitPollResponse,
      ];
}

class PollConversationPosted extends PollState {
  final PostPollConversationResponse postPollConversationResponse;

  PollConversationPosted({
    required this.postPollConversationResponse,
  });

  @override
  List<Object?> get props => [
        postPollConversationResponse,
      ];
}

class PollOptionAdded extends PollState {
  final AddPollOptionResponse addPollOptionResponse;

  PollOptionAdded({
    required this.addPollOptionResponse,
  });

  @override
  List<Object?> get props => [
        addPollOptionResponse,
      ];
}

class PollSubmitError extends PollState {
  final String errorMessage;
  final SubmitPollRequest submitPollRequest;

  PollSubmitError({
    required this.errorMessage,
    required this.submitPollRequest,
  });

  @override
  List<Object?> get props => [
        errorMessage,
        submitPollRequest,
      ];
}

class PollOptionError extends PollState {
  final String errorMessage;
  final AddPollOptionRequest addPollOptionRequest;

  PollOptionError({
    required this.errorMessage,
    required this.addPollOptionRequest,
  });

  @override
  List<Object?> get props => [
        errorMessage,
        addPollOptionRequest,
      ];
}
