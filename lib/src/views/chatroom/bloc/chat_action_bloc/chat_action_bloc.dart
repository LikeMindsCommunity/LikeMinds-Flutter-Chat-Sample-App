import 'package:firebase_database/firebase_database.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:bloc/bloc.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/utils/realtime/realtime.dart';
import 'package:likeminds_chat_mm_fl/src/utils/media/media_service.dart';

part 'chat_action_event.dart';
part 'chat_action_state.dart';

const bool isDebug = bool.fromEnvironment('DEBUG');

class ChatActionBloc extends Bloc<ChatActionEvent, ChatActionState> {
  MediaService mediaService = MediaService(!isDebug);
  final DatabaseReference realTime = LMRealtime.instance.chatroom();
  int? lastConversationId;

  ChatActionBloc() : super(ConversationInitial()) {
    on<NewConversation>((event, emit) {
      int chatroomId = event.chatroomId;
      lastConversationId = event.conversationId;

      realTime.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final response = event.snapshot.value as Map;
          final conversationId = int.parse(response["collabcard"]["answer_id"]);
          if (lastConversationId != null &&
              conversationId != lastConversationId) {
            add(UpdateConversationList(
              chatroomId: chatroomId,
              conversationId: conversationId,
            ));
          }
        }
      });
    });
    on<UpdateConversationList>((event, emit) async {
      if (lastConversationId != null &&
          event.conversationId != lastConversationId) {
        final response = await locator<LikeMindsService>()
            .getSingleConversation((GetSingleConversationRequestBuilder()
                  ..chatroomId(event.chatroomId)
                  ..conversationId(event.conversationId))
                .build());
        if (response.success) {
          emit(UpdateConversation(response: response.data!.conversation!));

          lastConversationId = event.conversationId;
        }
      }
    });
    on<PostConversation>((event, emit) async {
      await mapPostConversationFunction(
        event,
        emit,
      );
    });
    on<PostMultiMediaConversation>(
      (event, emit) async {
        await mapPostMultiMediaConversation(
          event,
          emit,
        );
      },
    );
    on<ReplyConversation>((event, emit) async {
      emit(ReplyConversationState(
        chatroomId: event.chatroomId,
        conversationId: event.conversationId,
        conversation: event.replyConversation,
      ));
    });
    on<ReplyRemove>((event, emit) => emit(ReplyRemoveState()));
  }

  mapPostMultiMediaConversation(
    PostMultiMediaConversation event,
    Emitter<ChatActionState> emit,
  ) async {
    try {
      DateTime dateTime = DateTime.now();
      User user = UserLocalPreference.instance.fetchUserData();
      Conversation conversation = Conversation(
        answer: event.postConversationRequest.text,
        chatroomId: event.postConversationRequest.chatroomId,
        createdAt: "",
        header: "",
        date: "${dateTime.day} ${dateTime.month} ${dateTime.year}",
        replyId: event.postConversationRequest.replyId,
        attachmentCount: event.postConversationRequest.attachmentCount,
        hasFiles: event.postConversationRequest.hasFiles,
        member: user,
        temporaryId: event.postConversationRequest.temporaryId,
        id: 1,
      );
      emit(
        MultiMediaConversationLoading(
          conversation,
          event.mediaFiles,
        ),
      );
      LMResponse<PostConversationResponse> response =
          await locator<LikeMindsService>().postConversation(
        event.postConversationRequest,
      );

      if (response.success) {
        PostConversationResponse postConversationResponse = response.data!;
        if (postConversationResponse.success) {
          List<dynamic> fileLink = [];
          int length = event.mediaFiles.length;
          for (int i = 0; i < length; i++) {
            Media media = event.mediaFiles[i];
            String? url = await mediaService.uploadFile(
              media.mediaFile!,
              event.postConversationRequest.chatroomId,
              postConversationResponse.conversation!.id,
            );
            if (url == null) {
              throw 'Error uploading file';
            } else {
              PutMediaRequest putMediaRequest = (PutMediaRequestBuilder()
                    ..conversationId(postConversationResponse.conversation!.id)
                    ..filesCount(length)
                    ..index(i)
                    ..height(media.height!)
                    ..width(media.width!)
                    ..meta({'size': media.size})
                    ..type("image")
                    ..url(url))
                  .build();
              LMResponse<PutMediaResponse> uploadFileResponse =
                  await locator<LikeMindsService>()
                      .putMultimedia(putMediaRequest);
              if (!uploadFileResponse.success) {
                emit(
                  MultiMediaConversationError(
                    uploadFileResponse.errorMessage!,
                    event.postConversationRequest.temporaryId,
                  ),
                );
              } else {
                if (!uploadFileResponse.data!.success) {
                  emit(
                    MultiMediaConversationError(
                      uploadFileResponse.data!.errorMessage!,
                      event.postConversationRequest.temporaryId,
                    ),
                  );
                } else {
                  fileLink.add(
                    putMediaRequest.toJson(),
                  );
                }
              }
            }
          }
          lastConversationId = response.data!.conversation!.id;
          emit(
            MultiMediaConversationPosted(
              postConversationResponse,
              fileLink,
            ),
          );
        } else {
          emit(
            MultiMediaConversationError(
              postConversationResponse.errorMessage!,
              event.postConversationRequest.temporaryId,
            ),
          );
        }
      } else {
        emit(
          MultiMediaConversationError(
            response.errorMessage!,
            event.postConversationRequest.temporaryId,
          ),
        );
        return false;
      }
    } catch (e) {
      emit(
        ChatActionError(
          "An error occurred",
          event.postConversationRequest.temporaryId,
        ),
      );
      return false;
    }
  }

  mapPostConversationFunction(
      PostConversation event, Emitter<ChatActionState> emit) async {
    try {
      DateTime dateTime = DateTime.now();
      User user = UserLocalPreference.instance.fetchUserData();
      Conversation conversation = Conversation(
        answer: event.postConversationRequest.text,
        chatroomId: event.postConversationRequest.chatroomId,
        createdAt: "",
        header: "",
        date: "${dateTime.day} ${dateTime.month} ${dateTime.year}",
        replyId: event.postConversationRequest.replyId,
        attachmentCount: event.postConversationRequest.attachmentCount,
        replyConversationObject: event.replyConversation,
        hasFiles: event.postConversationRequest.hasFiles,
        member: user,
        temporaryId: event.postConversationRequest.temporaryId,
        id: 1,
      );
      emit(LocalConversation(conversation));
      LMResponse<PostConversationResponse> response =
          await locator<LikeMindsService>().postConversation(
        event.postConversationRequest,
      );

      if (response.success) {
        if (response.data!.success) {
          Conversation conversation = response.data!.conversation!;
          if (conversation.replyId != null ||
              conversation.replyConversation != null) {
            conversation.replyConversationObject = event.replyConversation;
          }
          emit(ConversationPosted(response.data!));
        } else {
          emit(
            ChatActionError(
              response.data!.errorMessage!,
              event.postConversationRequest.temporaryId,
            ),
          );
          return false;
        }
      } else {
        emit(
          ChatActionError(
            response.errorMessage!,
            event.postConversationRequest.temporaryId,
          ),
        );
        return false;
      }
    } catch (e) {
      emit(
        ChatActionError(
          "An error occurred",
          event.postConversationRequest.temporaryId,
        ),
      );
      return false;
    }
  }
}

// realTime.onValue.listen((rtEvent) {
//       on<NewConversation>((event, emit) {
//         int chatroomId = event.chatroomId;
//         lastConversationId = event.conversationId;
//         if (rtEvent.snapshot.value != null) {
//           final response = rtEvent.snapshot.value as Map;
//           final conversationId = int.parse(response["collabcard"]["answer_id"]);
//           if (lastConversationId != null &&
//               conversationId != lastConversationId) {
//             add(UpdateConversationList(
//               chatroomId: chatroomId,
//               conversationId: conversationId,
//             ));
//           }
//         }
//       });
//     });