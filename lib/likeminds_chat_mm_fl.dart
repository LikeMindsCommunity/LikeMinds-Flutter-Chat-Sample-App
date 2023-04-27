library likeminds_chat_mm_fl;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/navigation/router.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/lm_branding.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/utils/notifications/notification_handler.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/spinner.dart';
import 'package:sizer/sizer.dart';

export 'package:likeminds_chat_mm_fl/src/utils/branding/lm_branding.dart';
export 'package:likeminds_chat_mm_fl/src/utils/branding/lm_fonts.dart';
export 'package:likeminds_chat_mm_fl/src/utils/notifications/notification_handler.dart';

class LMChat extends StatelessWidget {
  final String _userId;
  final String _userName;

  LMChat._internal(
    this._userId,
    this._userName,
  ) {
    debugPrint('LMChat initialized');
  }

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

  Future<InitiateUser> initiateUser() async {
    final response = await locator<LikeMindsService>().initiateUser(
      InitiateUserRequest(
        userId: _userId,
        userName: _userName,
      ),
    );
    UserLocalPreference.instance
        .storeUserData(response.data!.initiateUser!.user);
    firebase();
    return response.data!.initiateUser!;
  }

  firebase() {
    try {
      final firebase = Firebase.app();
      print("Firebase - ${firebase.options.appId}");
    } on FirebaseException catch (e) {
      print("Make sure you have initialized firebase, ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: ((context, orientation, deviceType) {
        return FutureBuilder(
          future: initiateUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final user = snapshot.data!.user;
              LMNotificationHandler.instance.registerDevice(user.id);
              return MaterialApp.router(
                routerConfig: router,
                debugShowCheckedModeBanner: true,
              );
            }
            return Container(
              color: kWhiteColor,
              child: Spinner(
                color: LMBranding.instance.headerColor,
              ),
            );
          },
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
