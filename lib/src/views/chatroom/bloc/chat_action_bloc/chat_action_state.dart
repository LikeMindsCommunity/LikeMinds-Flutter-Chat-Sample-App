part of 'chat_action_bloc.dart';

abstract class ChatActionState extends Equatable {}

class ConversationInitial extends ChatActionState {
  @override
  List<Object> get props => [];
}

class ChatActionError extends ChatActionState {
  final String temporaryId;
  final String errorMessage;

  ChatActionError(this.errorMessage, this.temporaryId);

  @override
  List<Object> get props => [
        temporaryId,
        errorMessage,
      ];
}

class LocalConversation extends ChatActionState {
  final Conversation conversation;

  LocalConversation(this.conversation);

  @override
  List<Object> get props => [
        conversation,
      ];
}

class ConversationPosted extends ChatActionState {
  final PostConversationResponse postConversationResponse;

  ConversationPosted(
    this.postConversationResponse,
  );

  @override
  List<Object> get props => [
        postConversationResponse,
      ];
}

class UpdateConversation extends ChatActionState {
  final Conversation response;

  UpdateConversation({
    required this.response,
  });

  @override
  List<Object> get props => [
        response,
      ];
}

class ConversationEdited extends ChatActionState {
  final EditConversationResponse editConversationResponse;

  ConversationEdited(
    this.editConversationResponse,
  );

  @override
  List<Object> get props => [
        editConversationResponse,
      ];
}

class ConversationDelete extends ChatActionState {
  final DeleteConversationResponse deleteConversationResponse;

  ConversationDelete(
    this.deleteConversationResponse,
  );

  @override
  List<Object> get props => [
        deleteConversationResponse,
      ];
}

class MultiMediaConversationLoading extends ChatActionState {
  final Conversation postConversation;
  final List<Media> mediaFiles;

  MultiMediaConversationLoading(
    this.postConversation,
    this.mediaFiles,
  );

  @override
  List<Object> get props => [
        mediaFiles,
      ];
}

class MultiMediaConversationPosted extends ChatActionState {
  final PostConversationResponse postConversationResponse;
  final List<Media> putMediaResponse;

  MultiMediaConversationPosted(
    this.postConversationResponse,
    this.putMediaResponse,
  );

  @override
  List<Object> get props => [
        postConversationResponse,
        putMediaResponse,
      ];
}

class MultiMediaConversationError extends ChatActionState {
  final String errorMessage;
  final String temporaryId;

  MultiMediaConversationError(
    this.errorMessage,
    this.temporaryId,
  );

  @override
  List<Object> get props => [
        errorMessage,
        temporaryId,
      ];
}

class ReplyConversationState extends ChatActionState {
  final int chatroomId;
  final int conversationId;
  final Conversation conversation;

  ReplyConversationState({
    required this.chatroomId,
    required this.conversationId,
    required this.conversation,
  });

  @override
  List<Object> get props => [
        chatroomId,
        conversationId,
      ];
}

class ReplyRemoveState extends ChatActionState {
  @override
  List<Object> get props => [];
}

class EditConversationState extends ChatActionState {
  final int chatroomId;
  final int conversationId;
  final Conversation editConversation;

  EditConversationState({
    required this.chatroomId,
    required this.conversationId,
    required this.editConversation,
  });

  @override
  List<Object> get props => [
        chatroomId,
        conversationId,
        editConversation.toEntity().toJson(),
      ];
}

class EditRemoveState extends ChatActionState {
  @override
  List<Object> get props => [];
}
