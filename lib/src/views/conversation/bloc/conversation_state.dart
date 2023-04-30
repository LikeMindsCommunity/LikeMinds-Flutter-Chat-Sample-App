part of 'conversation_bloc.dart';

abstract class ConversationState {}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationPaginationLoading extends ConversationState {}

class ConversationLoaded extends ConversationState {
  GetConversationResponse getConversationResponse;

  ConversationLoaded(this.getConversationResponse);
}

class ConversationError extends ConversationState {
  final String message;

  ConversationError(this.message);
}

class ChatroomUpdated extends ConversationState {}
