import 'package:bloc/bloc.dart';
import 'package:group_chat_example/views/chatroom/chatroom_components/chat_bubble.dart';
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

List<ChatBubble> getChats() {
  List<ChatBubble> chats = [];

  for (int i = 0; i < 20; i++) {
    chats.add(ChatBubble(
      isSent: i % 2 == 0,
      message:
          "Lorem ipsum message $i dolor sit amet, consectetur adipiscing elit.",
      time: "11:1$i",
      profileImageUrl: "https://picsum.photos/200/300",
      // onTap: () => print("Tapped $i"),
    ));
  }

  return chats;
}
