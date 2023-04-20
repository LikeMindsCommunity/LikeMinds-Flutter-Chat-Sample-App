import 'package:example/example_callback.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:likeminds_chat_mm_fl/likeminds_chat_mm_fl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LMChat.setupLMChat(
    apiKey: "bad53fff-c85a-4098-b011-ac36703cc98b",
    lmCallBack: ExampleCallback(),
  );
  LMBranding.instance.initialize(
    // headerColor: Colors.red,
    // buttonColor: Colors.blue,
    // textLinkColor: Colors.green,
    fonts: LMFonts.instance.initialize(
      regular: fontsMap["regular"],
      medium: fontsMap["medium"],
      bold: fontsMap["bold"],
    ),
  );
  runApp(
    LMChat.instance(
      builder: LMChatBuilder()
        ..userId("userId")
        ..userName("userName"),
    ),
  );
}

final Map<String, TextStyle> fontsMap = {
  "regular": GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  ),
  "medium": GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  ),
  "bold": GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  ),
};
