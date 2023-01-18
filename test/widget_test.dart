// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:group_chat_example/service_locator.dart';
import 'package:group_chat_example/services/likeminds_service.dart';
import 'package:likeminds_groupchat/likeminds_groupchat.dart';

void main() {
  test(
    "Test LikeMinds service for initiatiung user with a given InitiateUserRequest",
    () async {
      setupLocator();
      final InitiateUserRequest initiateUserRequest = InitiateUserRequest(
          userId: "divyansh-test-ui-1",
          userName: "Divyansh Gandhi Integration",
          isGuest: false,
          apiKey: "bad53fff-c85a-4098-b011-ac36703cc98b");
      final InitiateUserResponse response =
          await locator<LikeMindsService>().initiateUser(initiateUserRequest);
      debugPrint(response.toString());
      expect(response.success, true);
    },
  );
}
