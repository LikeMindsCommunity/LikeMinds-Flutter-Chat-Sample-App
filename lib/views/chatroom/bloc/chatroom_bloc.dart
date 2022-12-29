import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_example/views/chatroom/chatroom_components/chat_bubble.dart';
import 'package:meta/meta.dart';

part 'chatroom_event.dart';
part 'chatroom_state.dart';

class ChatroomBloc extends Bloc<ChatroomEvent, ChatroomState> {
  ChatroomBloc() : super(ChatroomInitial()) {
    on<ChatroomEvent>((event, emit) async {
      if (event is InitChatroomEvent) {
        emit(ChatroomLoading());
        //Perform logic
        await Future.delayed(
          const Duration(seconds: 1),
          (() => emit(ChatroomLoaded(
                chatroomId: event.chatroomId,
              ))),
        );
      }

      if (event is ReloadChatroomEvent) {
        emit(ChatroomLoading());
      }
    });
  }
}
