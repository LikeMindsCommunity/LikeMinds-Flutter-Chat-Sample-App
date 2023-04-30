part of 'chat_action_bloc.dart';

abstract class ChatActionEvent {}

class PostConversation extends ChatActionEvent {
  final PostConversationRequest postConversationRequest;

  PostConversation(this.postConversationRequest);
}

class EditConversation extends ChatActionEvent {
  final EditConversationRequest editConversationRequest;

  EditConversation(this.editConversationRequest);
}

class DeleteConversation extends ChatActionEvent {
  final DeleteConversationRequest deleteConversationRequest;

  DeleteConversation(this.deleteConversationRequest);
}

class PostMultiMediaConversation extends ChatActionEvent {
  PostConversationRequest postConversationRequest;
  List<File> mediaFiles;

  PostMultiMediaConversation(
    this.postConversationRequest,
    this.mediaFiles,
  );
}

class NewConversation extends ChatActionEvent {
  final int chatroomId;
  final int conversationId;

  NewConversation({
    required this.chatroomId,
    required this.conversationId,
  });
}

class UpdateConversationList extends ChatActionEvent {
  final int conversationId;
  final int chatroomId;

  UpdateConversationList({
    required this.conversationId,
    required this.chatroomId,
  });
}
