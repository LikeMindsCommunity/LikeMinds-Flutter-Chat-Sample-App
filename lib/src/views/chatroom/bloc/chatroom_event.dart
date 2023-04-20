part of 'chatroom_bloc.dart';

@immutable
abstract class ChatroomEvent {}

class InitChatroomEvent extends ChatroomEvent {
  final int chatroomId;

  InitChatroomEvent(this.chatroomId);
}

class ReloadChatroomEvent extends ChatroomEvent {}

class ChatroomDetailsEvent extends ChatroomEvent {}
