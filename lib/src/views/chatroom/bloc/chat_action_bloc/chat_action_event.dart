part of 'chat_action_bloc.dart';

abstract class ChatActionEvent extends Equatable {}

class PostConversation extends ChatActionEvent {
  final PostConversationRequest postConversationRequest;

  PostConversation(this.postConversationRequest);

  @override
  List<Object> get props => [
        postConversationRequest,
      ];
}

class EditConversation extends ChatActionEvent {
  final EditConversationRequest editConversationRequest;

  EditConversation(this.editConversationRequest);

  @override
  List<Object> get props => [
        editConversationRequest,
      ];
}

class DeleteConversation extends ChatActionEvent {
  final DeleteConversationRequest deleteConversationRequest;

  DeleteConversation(this.deleteConversationRequest);

  @override
  List<Object> get props => [
        deleteConversationRequest,
      ];
}

class PostMultiMediaConversation extends ChatActionEvent {
  final PostConversationRequest postConversationRequest;
  final List<File> mediaFiles;

  PostMultiMediaConversation(
    this.postConversationRequest,
    this.mediaFiles,
  );

  @override
  List<Object> get props => [
        postConversationRequest,
        mediaFiles,
      ];
}
