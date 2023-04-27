part of 'chat_action_bloc.dart';

abstract class ChatActionState {}

class ConversationInitial extends ChatActionState {}

class ChatActionError extends ChatActionState {
  String errorMessage;

  ChatActionError(this.errorMessage);
}

class ConversationPosted extends ChatActionState {
  PostConversationResponse postConversationResponse;
  ConversationPosted(this.postConversationResponse);
}

class ConversationEdited extends ChatActionState {
  EditConversationResponse editConversationResponse;
  ConversationEdited(this.editConversationResponse);
}

class ConversationDelete extends ChatActionState {
  DeleteConversationResponse deleteConversationResponse;
  ConversationDelete(this.deleteConversationResponse);
}
