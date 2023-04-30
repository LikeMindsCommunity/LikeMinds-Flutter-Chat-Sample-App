part of 'chat_action_bloc.dart';

abstract class ChatActionState {}

class ConversationInitial extends ChatActionState {}

class ChatActionError extends ChatActionState {
  String temporaryId;
  String errorMessage;

  ChatActionError(this.errorMessage, this.temporaryId);
}

class ConversationPosted extends ChatActionState {
  PostConversationResponse postConversationResponse;

  ConversationPosted(
    this.postConversationResponse,
  );
}

class UpdateConversation extends ChatActionState {
  Conversation response;

  UpdateConversation(
    this.response,
  );
}

class ConversationEdited extends ChatActionState {
  EditConversationResponse editConversationResponse;

  ConversationEdited(
    this.editConversationResponse,
  );
}

class ConversationDelete extends ChatActionState {
  DeleteConversationResponse deleteConversationResponse;

  ConversationDelete(
    this.deleteConversationResponse,
  );
}

class MultiMediaConversationLoading extends ChatActionBloc {
  PostConversationResponse postConversationResponse;
  List<File> mediaFiles;

  MultiMediaConversationLoading(
    this.postConversationResponse,
    this.mediaFiles,
  );
}

class MultiMediaConversationPosted extends ChatActionBloc {
  PostConversationResponse postConversationResponse;
  PutMediaResponse putMediaResponse;

  MultiMediaConversationPosted(
    this.postConversationResponse,
    this.putMediaResponse,
  );
}

class MultiMediaConversationError extends ChatActionBloc {
  String errorMessage;
  String temporaryId;

  MultiMediaConversationError(
    this.errorMessage,
    this.temporaryId,
  );
}
