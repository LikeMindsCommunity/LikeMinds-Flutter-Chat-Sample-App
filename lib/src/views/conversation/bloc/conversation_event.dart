part of 'conversation_bloc.dart';

abstract class ConversationEvent {}

class GetConversation extends ConversationEvent {
  final GetConversationRequest getConversationRequest;

  GetConversation({
    required this.getConversationRequest,
  });
}

class ChatroomDetailsEvent extends ConversationEvent {}

class MarkReadChatroomEvent extends ConversationEvent {
  final int chatroomId;

  MarkReadChatroomEvent({required this.chatroomId});
}

class ReloadChatroomEvent extends ConversationEvent {
  final int id;

  ReloadChatroomEvent({required this.id});
}

class UpdateChatroomEvent extends ConversationEvent {
  final int id;

  UpdateChatroomEvent({required this.id});
}
