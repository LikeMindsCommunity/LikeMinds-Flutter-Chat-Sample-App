part of 'chat_action_bloc.dart';

abstract class ChatActionEvent extends Equatable {}

class PostConversation extends ChatActionEvent {
  final PostConversationRequest postConversationRequest;
  final Conversation? replyConversation;

  PostConversation(this.postConversationRequest, {this.replyConversation});

  @override
  List<Object> get props => [
        postConversationRequest,
      ];
}

class EditConversation extends ChatActionEvent {
  final EditConversationRequest editConversationRequest;
  final Conversation? replyConversation;

  EditConversation(this.editConversationRequest, {this.replyConversation});

  @override
  List<Object> get props => [
        editConversationRequest,
      ];
}

class EditingConversation extends ChatActionEvent {
  final int conversationId;
  final int chatroomId;
  final Conversation editConversation;

  EditingConversation({
    required this.conversationId,
    required this.chatroomId,
    required this.editConversation,
  });

  @override
  List<Object> get props => [
        conversationId,
        chatroomId,
        editConversation,
      ];
}

class EditRemove extends ChatActionEvent {
  @override
  List<Object> get props => [];
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
  final List<Media> mediaFiles;

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

class NewConversation extends ChatActionEvent {
  final int chatroomId;
  final int conversationId;

  NewConversation({
    required this.chatroomId,
    required this.conversationId,
  });

  @override
  List<Object> get props => [
        chatroomId,
        conversationId,
      ];
}

class UpdateConversationList extends ChatActionEvent {
  final int conversationId;
  final int chatroomId;

  UpdateConversationList({
    required this.conversationId,
    required this.chatroomId,
  });

  @override
  List<Object> get props => [
        conversationId,
        chatroomId,
      ];
}

class ReplyConversation extends ChatActionEvent {
  final int conversationId;
  final int chatroomId;
  final Conversation replyConversation;

  ReplyConversation({
    required this.conversationId,
    required this.chatroomId,
    required this.replyConversation,
  });

  @override
  List<Object> get props => [
        conversationId,
        chatroomId,
        replyConversation,
      ];
}

class ReplyRemove extends ChatActionEvent {
  @override
  List<Object> get props => [];
}

class ConversationToolBar extends ChatActionEvent {
  final Conversation conversation;
  final Conversation? replyConversation;

  ConversationToolBar({required this.conversation, this.replyConversation});

  @override
  List<Object> get props => [conversation];
}

class RemoveConversationToolBar extends ChatActionEvent {
  @override
  List<Object> get props => [];
}
