part of 'chatroom_bloc.dart';

@immutable
abstract class ChatroomEvent {}

class InitChatroomEvent extends ChatroomEvent {
  final GetChatroomRequest chatroomRequest;

  InitChatroomEvent(this.chatroomRequest);
}

class ReloadChatroomEvent extends ChatroomEvent {}

class ChatroomDetailsEvent extends ChatroomEvent {}