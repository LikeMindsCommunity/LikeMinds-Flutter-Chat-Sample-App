import 'dart:io';
import 'dart:ui' as ui show Image;

import 'package:firebase_database/firebase_database.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:bloc/bloc.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_mm_fl/src/utils/realtime/realtime.dart';
import 'package:likeminds_chat_mm_fl/src/views/conversation/bloc/conversation_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/utils/media/media_service.dart';

part 'chat_action_event.dart';
part 'chat_action_state.dart';

class ChatActionBloc extends Bloc<ChatActionEvent, ChatActionState> {
  MediaService mediaService = MediaService(false);
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
            lastConversationId = conversationId;
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
        }
      }
    });
    on<PostConversation>((event, emit) async {
      await mapPostConversationFunction(
        event.postConversationRequest,
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
  }

  mapPostMultiMediaConversation(
    PostMultiMediaConversation event,
    Emitter<ChatActionState> emit,
  ) async {
    try {
      LMResponse<PostConversationResponse> response =
          await locator<LikeMindsService>().postConversation(
        event.postConversationRequest,
      );

      if (response.success) {
        PostConversationResponse postConversationResponse = response.data!;
        if (postConversationResponse.success) {
          emit(
            MultiMediaConversationLoading(
              response.data!,
              event.mediaFiles,
            ),
          );
          List<dynamic> fileLink = [];
          User user = UserLocalPreference.instance.fetchUserData();
          int length = event.mediaFiles.length;
          for (int i = 0; i < length; i++) {
            Media media = event.mediaFiles[i];
            String? url = await mediaService.uploadFile(
              media.mediaFile!,
              user.userUniqueId,
            );
            if (url == null) {
              throw 'Error uploading file';
            } else {
              ui.Image image =
                  await decodeImageFromList(media.mediaFile!.readAsBytesSync());
              PutMediaRequest putMediaRequest = (PutMediaRequestBuilder()
                    ..conversationId(postConversationResponse.conversation!.id)
                    ..filesCount(event.mediaFiles.length)
                    ..index(i)
                    ..height(media.height!)
                    ..width(media.width!)
                    ..meta("")
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

  mapPostConversationFunction(PostConversationRequest postConversationRequest,
      Emitter<ChatActionState> emit) async {
    try {
      LMResponse<PostConversationResponse> response =
          await locator<LikeMindsService>().postConversation(
        postConversationRequest,
      );

      if (response.success) {
        if (response.data!.success) {
          lastConversationId = response.data!.conversation!.id;
          emit(ConversationPosted(response.data!));
        } else {
          emit(
            ChatActionError(
              response.data!.errorMessage!,
              postConversationRequest.temporaryId,
            ),
          );
          return false;
        }
      } else {
        emit(
          ChatActionError(
            response.errorMessage!,
            postConversationRequest.temporaryId,
          ),
        );
        return false;
      }
    } catch (e) {
      emit(
        ChatActionError(
          "An error occurred",
          postConversationRequest.temporaryId,
        ),
      );
      return false;
    }
  }
}
