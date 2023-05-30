import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';

class ExampleCallback extends LMSdkCallback {
  @override
  void eventFiredCallback(String eventKey, Map<String, dynamic> propertiesMap) {
    debugPrint("EXAMPLE: eventFiredCallback: $eventKey, $propertiesMap");
  }

  @override
  void loginRequiredCallback() {
    debugPrint("EXAMPLE: loginRequiredCallback");
  }

  @override
  void logoutCallback() {
    debugPrint("EXAMPLE: logoutCallback");
  }
}
