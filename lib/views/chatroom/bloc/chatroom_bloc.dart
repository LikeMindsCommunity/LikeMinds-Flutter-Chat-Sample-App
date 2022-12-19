import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'chatroom_event.dart';
part 'chatroom_state.dart';

class ChatroomBloc extends Bloc<ChatroomEvent, ChatroomState> {
  ChatroomBloc() : super(ChatroomInitial()) {
    on<ChatroomEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
