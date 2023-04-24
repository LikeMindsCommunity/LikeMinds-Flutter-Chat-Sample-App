part of 'conversation_bloc.dart';

abstract class ConversationEvent {}

class GetConversation extends ConversationEvent {
  final GetConversationRequest getConversationRequest;

  GetConversation({
    required this.getConversationRequest,
  });
}

class ReloadChatroomEvent extends ConversationEvent {}

class ChatroomDetailsEvent extends ConversationEvent {}
