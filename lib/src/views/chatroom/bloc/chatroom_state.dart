part of 'chatroom_bloc.dart';

@immutable
abstract class ChatroomState {}

class ChatroomInitial extends ChatroomState {}

class ChatroomLoading extends ChatroomState {}

class ChatroomLoaded extends ChatroomState {
  final GetChatroomResponse getChatroomResponse;

  ChatroomLoaded({required this.getChatroomResponse});
}

class ChatroomError extends ChatroomState {
  final String message;

  ChatroomError(this.message);
}

class ChatroomReport extends ChatroomState {
  final String message;

  ChatroomReport(this.message);
}
