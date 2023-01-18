import 'package:likeminds_groupchat/likeminds_groupchat.dart';

abstract class ILikeMindsService {
  Future<InitiateUserResponse> initiateUser(InitiateUserRequest request);
}

class LikeMindsService implements ILikeMindsService {
  late SdkApplication _sdkApplication;

  LikeMindsService() {
    final LikeMindsGroupChat lmChat = LikeMindsGroupChat();
    _sdkApplication = lmChat.initiateLikeMinds();
  }

  @override
  Future<InitiateUserResponse> initiateUser(InitiateUserRequest request) async {
    return await _sdkApplication.getAuthApi().initiateUser(request);
  }
}
