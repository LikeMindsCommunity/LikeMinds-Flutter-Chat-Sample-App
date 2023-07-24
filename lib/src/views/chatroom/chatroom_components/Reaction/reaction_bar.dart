import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chat_action_bloc/chat_action_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/helper/reaction_helper.dart';

class ReactionBar extends StatelessWidget {
  final int? chatroomId;
  final Conversation conversation;
  final Conversation? replyToConversation;
  final User loggedinUser;

  const ReactionBar({
    Key? key,
    required this.chatroomId,
    required this.conversation,
    required this.replyToConversation,
    required this.loggedinUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChatActionBloc chatActionBloc = BlocProvider.of(context);
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            width: 90.w,
            height: 50,
            child: getListOfReactions(
              onTap: (String reaction) async {
                if (reaction == 'Add') {
                  chatActionBloc.add(ConversationToolBar(
                    selectedConversation: [conversation],
                    showReactionKeyboard: true,
                    showReactionBar: false,
                  ));
                } else {
                  PutReactionRequest request = (PutReactionRequestBuilder()
                        ..conversationId(conversation.id)
                        ..reaction(reaction))
                      .build();
                  chatActionBloc.add(PutReaction(putReactionRequest: request));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
