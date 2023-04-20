library likeminds_chat_mm_fl;

import 'package:flutter/material.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/navigation/router.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/lm_branding.dart';
import 'package:sizer/sizer.dart';

class LMChat extends StatelessWidget {
  final String _userId;
  final String _userName;

  static LMChat? _instance;
  static LMBranding? _branding;

  static LMChat instance({required LMChatBuilder builder}) {
    if (builder.getUserId == null || builder.getUserName == null) {
      throw Exception(
          'LMChat builder needs to be initialized with userId, and userName');
    } else {
      return _instance ??= LMChat._internal(
        builder.getUserId,
        builder.getUserName,
      );
    }
  }

  static void setupLMChat({
    required String apiKey,
    required LMSdkCallback lmCallBack,
  }) {
    setupChat(
      apiKey: apiKey,
      lmCallBack: lmCallBack,
    );
  }

  static void setBranding({LMBranding? branding}) {
    if (branding != null) {
      _branding = branding;
    } else {
      LMBranding.instance.initialize();
    }
  }

  static Future<LMResponse> initiateUser(InitiateUserRequest request) {
    return locator<LikeMindsService>().initiateUser(request);
  }

  LMChat._internal(
    this._userId,
    this._userName,
  ) {
    debugPrint('LMChat initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: ((context, orientation, deviceType) {
        return MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: true,
        );
      }),
    );
  }
}

class LMChatBuilder {
  late final String _userId;
  late final String _userName;
  late final String _domain;

  LMChatBuilder();

  void userId(String userId) => _userId = userId;
  void userName(String userName) => _userName = userName;
  void domain(String domain) => _domain = domain;

  get getUserId => _userId;
  get getUserName => _userName;
  get getDomain => _domain;
}
