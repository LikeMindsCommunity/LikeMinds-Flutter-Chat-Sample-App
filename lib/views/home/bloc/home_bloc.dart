import 'package:bloc/bloc.dart';
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
        List<ChatItem> chats = getChats();
        await Future.delayed(
            Duration(seconds: 1), (() => emit(HomeLoaded(chats))));
        // emit(HomeLoaded(chats));
      }

      if (event is ReloadHomeEvent) {
        emit(HomeLoading());
      }
    });
  }
}

List<ChatItem> getChats() {
  List<ChatItem> chats = [];

  for (int i = 0; i < 10; i++) {
    chats.add(ChatItem(
      name: "Testy $i",
      message:
          "Lorem ipsum message $i dolor sit amet, consectetur adipiscing elit.",
      time: "11:1$i",
      avatarUrl: "https://picsum.photos/200/300",
    ));
  }

  return chats;
}
