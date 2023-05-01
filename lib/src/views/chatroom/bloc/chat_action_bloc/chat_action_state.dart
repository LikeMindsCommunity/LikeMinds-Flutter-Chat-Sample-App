part of 'chat_action_bloc.dart';

abstract class ChatActionState extends Equatable {}

class ConversationInitial extends ChatActionState {
  @override
  List<Object> get props => [];
}

class ChatActionError extends ChatActionState {
  final String temporaryId;
  final String errorMessage;

  ChatActionError(this.errorMessage, this.temporaryId);

  @override
  List<Object> get props => [
        temporaryId,
        errorMessage,
      ];
}

class ConversationPosted extends ChatActionState {
  final PostConversationResponse postConversationResponse;

  ConversationPosted(
    this.postConversationResponse,
  );

  @override
  List<Object> get props => [
        postConversationResponse,
      ];
}

class UpdateConversation extends ChatActionState {
  final Conversation response;

  UpdateConversation({
    required this.response,
  });

  @override
  List<Object> get props => [
        response,
      ];
}

class ConversationEdited extends ChatActionState {
  final EditConversationResponse editConversationResponse;

  ConversationEdited(
    this.editConversationResponse,
  );

  @override
  List<Object> get props => [
        editConversationResponse,
      ];
}

class ConversationDelete extends ChatActionState {
  final DeleteConversationResponse deleteConversationResponse;

  ConversationDelete(
    this.deleteConversationResponse,
  );

  @override
  List<Object> get props => [
        deleteConversationResponse,
      ];
}

class MultiMediaConversationLoading extends ChatActionState {
  final PostConversationResponse postConversationResponse;
  final List<Media> mediaFiles;

  MultiMediaConversationLoading(
    this.postConversationResponse,
    this.mediaFiles,
  );

  @override
  List<Object> get props => [
        postConversationResponse,
        mediaFiles,
      ];
}

class MultiMediaConversationPosted extends ChatActionState {
  final PostConversationResponse postConversationResponse;
  final List<dynamic> putMediaResponse;

  MultiMediaConversationPosted(
    this.postConversationResponse,
    this.putMediaResponse,
  );

  @override
  List<Object> get props => [
        postConversationResponse,
        putMediaResponse,
      ];
}

class MultiMediaConversationError extends ChatActionState {
  final String errorMessage;
  final String temporaryId;

  MultiMediaConversationError(
    this.errorMessage,
    this.temporaryId,
  );

  @override
  List<Object> get props => [
        errorMessage,
        temporaryId,
      ];
}
