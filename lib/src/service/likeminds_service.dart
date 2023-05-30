import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/utils/analytics/analytics.dart';

abstract class ILikeMindsService {
  Future<LMResponse<InitiateUserResponse>> initiateUser(
      InitiateUserRequest request);
  Future<LMResponse<MemberStateResponse>> getMemberState();
  Future<LMResponse<LogoutResponse>> logout(LogoutRequest request);
  Future<LMResponse<GetHomeFeedResponse>> getHomeFeed(
      GetHomeFeedRequest request);
  Future<LMResponse<GetChatroomResponse>> getChatroom(
      GetChatroomRequest request);
  Future<LMResponse<FollowChatroomResponse>> followChatroom(
      FollowChatroomRequest request);
  Future<LMResponse<MuteChatroomResponse>> muteChatroom(
      MuteChatroomRequest request);
  Future<LMResponse<MarkReadChatroomResponse>> markReadChatroom(
      MarkReadChatroomRequest request);
  Future<LMResponse<ShareChatroomResponse>> shareChatroomUrl(
      ShareChatroomRequest request);
  Future<LMResponse<SetChatroomTopicResponse>> setChatroomTopic(
      SetChatroomTopicRequest request);
  Future<LMResponse<DeleteParticipantResponse>> deleteParticipant(
      DeleteParticipantRequest request);
  Future<LMResponse<GetConversationResponse>> getConversation(
      GetConversationRequest request);
  Future<LMResponse<GetSingleConversationResponse>> getSingleConversation(
      GetSingleConversationRequest request);
  Future<LMResponse<PostConversationResponse>> postConversation(
      PostConversationRequest request);
  Future<LMResponse<EditConversationResponse>> editConversation(
      EditConversationRequest request);
  Future<LMResponse<DeleteConversationResponse>> deleteConversation(
      DeleteConversationRequest request);
  Future<LMResponse<PutMediaResponse>> putMultimedia(PutMediaRequest request);
  Future<LMResponse<RegisterDeviceResponse>> registerDevice(
      RegisterDeviceRequest request);
  Future<LMResponse<GetParticipantsResponse>> getParticipants(
      GetParticipantsRequest request);
  Future<LMResponse<TagResponseModel>> getTaggingList(TagRequestModel request);
}

class LikeMindsService implements ILikeMindsService {
  final String apiKey;
  final LMSdkCallback lmCallBack;
  late final LMChatClient client;

  LikeMindsService({
    required this.apiKey,
    required this.lmCallBack,
  }) {
    client = (LMChatClientBuilder()
          ..apiKey(apiKey)
          ..sdkCallback(lmCallBack))
        .build();
    LMAnalytics.get().initialize();
  }

  @override
  Future<LMResponse<InitiateUserResponse>> initiateUser(
      InitiateUserRequest request) async {
    UserLocalPreference userLocalPreference = UserLocalPreference.instance;
    await userLocalPreference.initialize();
    return client.initiateUser(request);
  }

  @override
  Future<LMResponse<MemberStateResponse>> getMemberState() async {
    return client.getMemberState();
  }

  @override
  Future<LMResponse<LogoutResponse>> logout(LogoutRequest request) {
    return client.logout(request);
  }

  @override
  Future<LMResponse<GetHomeFeedResponse>> getHomeFeed(
      GetHomeFeedRequest request) {
    return client.getHomeFeed(request);
  }

  @override
  Future<LMResponse<GetChatroomResponse>> getChatroom(
      GetChatroomRequest request) {
    return client.getChatroom(request);
  }

  @override
  Future<LMResponse<FollowChatroomResponse>> followChatroom(
      FollowChatroomRequest request) {
    return client.followChatroom(request);
  }

  @override
  Future<LMResponse<MuteChatroomResponse>> muteChatroom(
      MuteChatroomRequest request) {
    return client.muteChatroom(request);
  }

  @override
  Future<LMResponse<MarkReadChatroomResponse>> markReadChatroom(
      MarkReadChatroomRequest request) {
    return client.markReadChatroom(request);
  }

  @override
  Future<LMResponse<ShareChatroomResponse>> shareChatroomUrl(
      ShareChatroomRequest request) {
    return client.shareChatroomUrl(request);
  }

  @override
  Future<LMResponse<DeleteParticipantResponse>> deleteParticipant(
      DeleteParticipantRequest request) {
    return client.deleteParticipant(request);
  }

  @override
  Future<LMResponse<SetChatroomTopicResponse>> setChatroomTopic(
      SetChatroomTopicRequest request) {
    return client.setChatroomTopic(request);
  }

  @override
  Future<LMResponse<GetConversationResponse>> getConversation(
      GetConversationRequest request) {
    return client.getConversation(request);
  }

  @override
  Future<LMResponse<GetSingleConversationResponse>> getSingleConversation(
      GetSingleConversationRequest request) {
    return client.getSingleConversation(request);
  }

  @override
  Future<LMResponse<PostConversationResponse>> postConversation(
      PostConversationRequest request) {
    return client.postConversation(request);
  }

  @override
  Future<LMResponse<EditConversationResponse>> editConversation(
      EditConversationRequest request) {
    return client.editConversation(request);
  }

  @override
  Future<LMResponse<DeleteConversationResponse>> deleteConversation(
      DeleteConversationRequest request) {
    return client.deleteConversation(request);
  }

  @override
  Future<LMResponse<PutMediaResponse>> putMultimedia(PutMediaRequest request) {
    return client.putMultimedia(request);
  }

  @override
  Future<LMResponse<RegisterDeviceResponse>> registerDevice(
      RegisterDeviceRequest request) {
    return client.registerDevice(request);
  }

  @override
  Future<LMResponse<GetParticipantsResponse>> getParticipants(
      GetParticipantsRequest request) {
    return client.getParticipants(request);
  }

  @override
  Future<LMResponse<TagResponseModel>> getTaggingList(TagRequestModel request) {
    return client.getTaggingList(request);
  }
}
