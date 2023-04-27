import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
import 'package:overlay_support/overlay_support.dart';

/// This class handles all the notification related logic
/// It registers the device for notifications in the SDK
/// It handles the notification when it is received and shows it
/// It routes the notification to the appropriate screen
/// Since this is a singleton class, it is initialized on the client side
class LMNotificationHandler {
  late final String deviceId;
  late final String fcmToken;
  int? memberId;

  static LMNotificationHandler? _instance;
  static LMNotificationHandler get instance =>
      _instance ??= LMNotificationHandler._();

  LMNotificationHandler._();

  /// Initialize the notification handler
  /// This is called from the client side
  /// It initializes the [fcmToken] and the [deviceId]
  void init({
    required String deviceId,
    required String fcmToken,
  }) {
    this.deviceId = deviceId;
    this.fcmToken = fcmToken;
  }

  /// Register the device for notifications
  /// This is called from the client side
  /// It calls the [registerDevice] method of the [LikeMindsService]
  /// It initializes the [memberId] which is used to route the notification
  /// If the registration is successful, it prints success message
  void registerDevice(int memberId) async {
    RegisterDeviceRequest request = RegisterDeviceRequest(
      token: fcmToken,
      memberId: memberId,
      deviceId: deviceId,
    );
    this.memberId = memberId;
    final response = await locator<LikeMindsService>().registerDevice(request);
    if (response.success) {
      debugPrint("Device registered for notifications successfully");
    } else {
      throw Exception("Device registration for notification failed");
    }
  }

  /// Handle the notification when it is received
  /// This is called from the client side when notification [message] is received
  /// and is needed to be handled, i.e. shown and routed to the appropriate screen
  Future<void> handleNotification(RemoteMessage message, bool show) async {
    debugPrint("--- Notification received in LEVEL 2 ---");
    message.toMap().forEach((key, value) {
      debugPrint("$key: $value");
      if (key == "data") {
        message.data.forEach((key, value) {
          debugPrint("$key: $value");
        });
      }
    });

    // First, check if the message contains a data payload.
    if (show && message.data.isNotEmpty) {
      //Add LM check for showing LM notifications
      showNotification(message);
    } else if (message.data.isNotEmpty) {
      // Second, extract the notification data and routes to the appropriate screen
      routeNotification(message);
    }
  }

  void routeNotification(RemoteMessage message) async {
    Map<String, String> queryParams = {};
    String host = "";

    // Only notifications with data payload are handled
    if (message.data.isNotEmpty) {
      final Map<String, dynamic> notifData = message.data;
      final String category = notifData["category"];
      final String route = notifData["route"]!;

      // If the notification is a feed notification, extract the route params
      if (category.toString().toLowerCase() == "chat room") {
        final Uri routeUri = Uri.parse(route);
        final Map<String, String> routeParams =
            routeUri.hasQuery ? routeUri.queryParameters : {};
        final String routeHost = routeUri.host;
        host = routeHost;
        debugPrint("The route host is $routeHost");
        queryParams.addAll(routeParams);
        queryParams.forEach((key, value) {
          debugPrint("$key: $value");
        });
      }
    }

    // Route the notification to the appropriate screen
    // If the notification is post related, route to the post detail screen
    // if (host == "post_detail") {
    //   final String postId = queryParams["post_id"]!;
    //   final GetPostResponse postDetails =
    //       await locator<LikeMindsService>().getPost(
    //     (GetPostRequestBuilder()
    //           ..postId(postId)
    //           ..page(1)
    //           ..pageSize(10))
    //         .build(),
    //   );
    //   locator<NavigationService>().navigateTo(
    //     AllCommentsScreen.route,
    //     arguments: AllCommentsScreenArguments(
    //       post: postDetails.post!,
    //       feedroomId: locator<LikeMindsService>().feedroomId!,
    //     ),
    //   );
    // }
  }

  /// Show a simple notification using overlay package
  /// This is a dismissable notification shown on the top of the screen
  /// It is shown when the notification is received in foreground
  void showNotification(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      showSimpleNotification(
        GestureDetector(
          onTap: () {
            routeNotification(message);
          },
          child: Text(
            message.data["sub_title"],
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        background: Colors.white,
        duration: const Duration(seconds: 3),
        leading: Icon(
          Icons.notifications,
          color: Colors.blue.shade400,
          size: 24,
        ),
        trailing: Icon(
          Icons.swipe_right_outlined,
          color: Colors.grey.shade400,
          size: 18,
        ),
        position: NotificationPosition.top,
        slideDismissDirection: DismissDirection.horizontal,
      );
    }
  }
}
