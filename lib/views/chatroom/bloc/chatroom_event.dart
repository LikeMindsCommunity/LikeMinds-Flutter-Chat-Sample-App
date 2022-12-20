part of 'chatroom_bloc.dart';

@immutable
abstract class ChatroomEvent {}

class InitChatroomEvent extends ChatroomEvent {}

class RefreshChatroomEvent extends ChatroomEvent {}

class ChatroomDetailsEvent extends ChatroomEvent {}
