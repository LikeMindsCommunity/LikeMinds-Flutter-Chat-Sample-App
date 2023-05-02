library likeminds_chat_mm_fl;

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/navigation/router.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/lm_branding.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/utils/notifications/notification_handler.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chat_action_bloc/chat_action_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/bloc/home_bloc.dart';
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
  static LMChat instance({required LMChatBuilder builder}) {
    if (builder.getUserId == null || builder.getUserName == null) {
      throw Exception(
        'LMChat builder needs to be initialized with userId, and userName',
      );
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

  static Future<InitiateUser> initiateUser({
    String? userId,
    String? userName,
  }) async {
    final response = await locator<LikeMindsService>().initiateUser(
      InitiateUserRequest(
        userId: userId ?? _instance?._userId,
        userName: userName ?? _instance?._userName,
      ),
    );
    final initiateUser = response.data!.initiateUser!;
    UserLocalPreference.instance.storeUserData(initiateUser.user);
    UserLocalPreference.instance.storeCommunityData(initiateUser.community);
    await _instance?.firebase();
    return initiateUser;
  }

  firebase() async {
    try {
      final clientFirebase = Firebase.app();
      final ourFirebase = await Firebase.initializeApp(
        name: 'likeminds_chat',
        options: Platform.isIOS
            ? const FirebaseOptions(
                apiKey: 'AIzaSyBWjDQEiYKdQbQNvoiVvvOn_cbufQzvWuo',
                appId: '1:983690302378:ios:00ee53e9ab9afe851b91d3',
                messagingSenderId: '983690302378',
                projectId: 'collabmates-beta',
                databaseURL: "https://collabmates-beta.firebaseio.com/",
              )
            : const FirebaseOptions(
                apiKey: 'AIzaSyB-9J8X0Z3Q4Z2Z3Z2Z3Z2Z3Z2Z3Z2Z3Z2',
                appId: '1:983690302378:android:46abad58705780a81b91d3',
                messagingSenderId: '983690302378',
                projectId: 'collabmates-beta',
                databaseURL: "https://collabmates-beta.firebaseio.com/",
              ),
      );
      debugPrint("Client Firebase - ${clientFirebase.options.appId}");
      debugPrint("Our Firebase - ${ourFirebase.options.appId}");
    } on FirebaseException catch (e) {
      debugPrint("Make sure you have initialized firebase, ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: ((context, orientation, deviceType) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ChatActionBloc>(
              create: (context) => ChatActionBloc(),
            ),
            BlocProvider<HomeBloc>(
              create: (context) => HomeBloc(),
            ),
          ],
          child: FutureBuilder(
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
          ),
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
