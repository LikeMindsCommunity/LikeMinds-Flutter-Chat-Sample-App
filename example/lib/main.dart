import 'package:example/example_callback.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_chat_mm_fl/likeminds_chat_mm_fl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LMChat.setupLMChat(
    apiKey: "bad53fff-c85a-4098-b011-ac36703cc98b",
    lmCallBack: ExampleCallback(),
  );
  LMChat.setBranding();
  runApp(
    LMChat.instance(
      builder: LMChatBuilder()
        ..userId("userId")
        ..userName("userName"),
    ),
  );
}
