import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_chat_example/views/chatroom/bloc/chatroom_bloc.dart';
import 'package:group_chat_example/views/chatroom/chatroom_page.dart';
import 'package:meta/meta.dart';

import '../home_components/chat_item.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeEvent>((event, emit) async {
      // TODO: implement event handler
      if (event is InitHomeEvent) {
        emit(HomeLoading());
        //Perform logic
        // List<ChatItem> chats = getChats();
        await Future.delayed(
          const Duration(seconds: 1),
          (() => emit(HomeLoaded())),
        );
      }

      if (event is ReloadHomeEvent) {
        emit(HomeLoading());
      }
    });
  }
}
