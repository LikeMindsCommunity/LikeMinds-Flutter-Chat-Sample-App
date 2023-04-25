library likeminds_chat_mm_fl;

import 'package:flutter/material.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/navigation/router.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/lm_branding.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/spinner.dart';
import 'package:sizer/sizer.dart';

export 'package:likeminds_chat_mm_fl/src/utils/branding/lm_branding.dart';
export 'package:likeminds_chat_mm_fl/src/utils/branding/lm_fonts.dart';

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
        return FutureBuilder(
            future: locator<LikeMindsService>().initiateUser(
              InitiateUserRequest(
                userId: _userId,
                userName: _userName,
              ),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                LMResponse<InitiateUserResponse> response = snapshot.data!;
                if (response.success!) {
                  User user = response.data!.initiateUser!.user;
                  UserLocalPreference.instance.storeUserData(user);
                }
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
              // ? MaterialApp.router(
              //     routerConfig: router,
              //     debugShowCheckedModeBanner: true,
              //   )
              // : ;
            }
            // child: MaterialApp.router(
            //   routerConfig: router,
            //   debugShowCheckedModeBanner: true,
            //   builder: (context, child) {
            //     return
            //   },
            // ),
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
