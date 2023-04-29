import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:likeminds_chat_mm_fl/likeminds_chat_mm_fl.dart';
import 'package:lm_chat_example/network_handling.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:sizer/sizer.dart';

const credColor = Color.fromARGB(255, 48, 159, 116);
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
Map fonts = {};

Future<void> loadFonts() async {
  fonts = GoogleFonts.asMap();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    loadFonts();
    return Sizer(
      builder: (context, orientation, deviceType) => OverlaySupport.global(
        child: MaterialApp(
          title: 'Chat App for UI + SDK package',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          home: const CredScreen(),
        ),
      ),
    );
  }
}

class CredScreen extends StatefulWidget {
  const CredScreen({super.key});

  @override
  State<CredScreen> createState() => _CredScreenState();
}

class _CredScreenState extends State<CredScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  TextStyle? _textStyle;
  Color? _header;
  Color? _button;
  Color? _textLink;
  Color? _tempColor;

  @override
  @override
  void initState() {
    super.initState();
    NetworkConnectivity networkConnectivity = NetworkConnectivity.instance;
    networkConnectivity.initialise();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: credColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 96),
              Text(
                "Flutter Chat\nSample App",
                textAlign: TextAlign.center,
                style: GoogleFonts.josefinSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 64),
              Text(
                "Enter your credentials",
                style: GoogleFonts.josefinSans(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                cursorColor: Colors.white,
                style: GoogleFonts.josefinSans(color: Colors.white),
                controller: _usernameController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  focusColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Username',
                  labelStyle: GoogleFonts.josefinSans(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                cursorColor: Colors.white,
                controller: _userIdController,
                style: GoogleFonts.josefinSans(color: Colors.white),
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'User ID',
                    labelStyle: GoogleFonts.josefinSans(
                      color: Colors.white,
                    )),
              ),
              const SizedBox(height: 48),
              Text(
                "If no credentials are provided, the app will run with the default credentials of Bot user in your community",
                textAlign: TextAlign.center,
                style: GoogleFonts.josefinSans(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                "Branding",
                style: GoogleFonts.josefinSans(
                  color: Colors.white,
                  fontSize: 24,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  DropdownMenu(
                    enableFilter: true,
                    width: 42.w,
                    menuHeight: 20.h,
                    label: Text(
                      "Choose font",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.josefinSans(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ),
                    textStyle: _textStyle?.copyWith(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ) ??
                        GoogleFonts.josefinSans(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                    inputDecorationTheme: InputDecorationTheme(
                      focusColor: Colors.white,
                      fillColor: Colors.white,
                      hoverColor: Colors.white,
                      floatingLabelStyle: GoogleFonts.josefinSans(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                      labelStyle: GoogleFonts.josefinSans(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    dropdownMenuEntries: getGoogleFontsAsMap(),
                    onSelected: (value) {
                      setState(() {
                        _textStyle = GoogleFonts.asMap()[value]?.call();
                      });
                    },
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          contentPadding: const EdgeInsets.all(6.0),
                          title: const Text("Choose header colour"),
                          content: MaterialColorPicker(
                            allowShades: false,
                            onlyShadeSelection: false,
                            selectedColor: _tempColor,
                            onColorChange: (color) => setState(
                              () => _tempColor = color,
                            ),
                            onMainColorChange: (color) => setState(
                              () => _tempColor = color,
                            ),
                            onBack: () => print("Back button pressed"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: Navigator.of(context).pop,
                              child: Text(
                                'CANCEL',
                                style: GoogleFonts.josefinSans(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            TextButton(
                              child: Text(
                                'SUBMIT',
                                style: GoogleFonts.josefinSans(
                                  color: credColor,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(
                                  () => _header = _tempColor,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    child: Container(
                      height: 6.h,
                      width: 6.h,
                      decoration: BoxDecoration(
                        color: _header ?? Colors.grey,
                        borderRadius: BorderRadius.circular(3.h),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          contentPadding: const EdgeInsets.all(6.0),
                          title: const Text("Choose button colour"),
                          content: MaterialColorPicker(
                            allowShades: false,
                            onlyShadeSelection: false,
                            selectedColor: _tempColor,
                            onColorChange: (color) => setState(
                              () => _tempColor = color,
                            ),
                            onMainColorChange: (color) => setState(
                              () => _tempColor = color,
                            ),
                            onBack: () => print("Back button pressed"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: Navigator.of(context).pop,
                              child: Text(
                                'CANCEL',
                                style: GoogleFonts.josefinSans(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            TextButton(
                              child: Text(
                                'SUBMIT',
                                style: GoogleFonts.josefinSans(
                                  color: credColor,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(
                                  () => _button = _tempColor,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    child: Container(
                      height: 6.h,
                      width: 6.h,
                      decoration: BoxDecoration(
                        color: _button ?? Colors.grey,
                        borderRadius: BorderRadius.circular(3.h),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          contentPadding: const EdgeInsets.all(6.0),
                          title: const Text("Choose text link colour"),
                          content: MaterialColorPicker(
                            allowShades: false,
                            selectedColor: _tempColor,
                            onColorChange: (color) => setState(
                              () => _tempColor = color,
                            ),
                            onMainColorChange: (color) => setState(
                              () => _tempColor = color,
                            ),
                            onBack: () => print("Back button pressed"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: Navigator.of(context).pop,
                              child: Text(
                                'CANCEL',
                                style: GoogleFonts.josefinSans(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            TextButton(
                              child: Text(
                                'SUBMIT',
                                style: GoogleFonts.josefinSans(
                                  color: credColor,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(
                                  () => _textLink = _tempColor,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    child: Container(
                      height: 6.h,
                      width: 6.h,
                      decoration: BoxDecoration(
                        color: _textLink ?? Colors.grey,
                        borderRadius: BorderRadius.circular(3.h),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: () {
                  LMChat? lmChat;
                  String username = _usernameController.text.isEmpty
                      ? "UserName"
                      : _usernameController.text;
                  String userId = _userIdController.text.isEmpty
                      ? "207be084-b38f-4c70-b1c3-7a763dae2020"
                      : _userIdController.text;
                  if (username.isEmpty || userId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter valid credentials"),
                      ),
                    );
                  } else {
                    lmChat = LMChat.instance(
                      builder: LMChatBuilder()
                        ..userId(userId)
                        ..userName(username),
                    );
                  }
                  setBranding();
                  MaterialPageRoute route = MaterialPageRoute(
                    // INIT - Get the LMFeed instance and pass the credentials (if any)
                    builder: (context) => lmChat!,
                  );
                  Navigator.pushReplacement(context, route);
                },
                child: Container(
                  width: 200,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "Submit",
                      style: GoogleFonts.josefinSans(
                        color: credColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  void setBranding() {
    final Map<String, TextStyle> fontsMap = {
      "regular": _textStyle?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ) ??
          GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
      "medium": _textStyle?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ) ??
          GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
      "bold": _textStyle?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ) ??
          GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
    };
    LMBranding.instance.initialize(
      headerColor: _header,
      buttonColor: _button,
      textLinkColor: _textLink,
      fonts: LMFonts.instance.initialize(
        regular: fontsMap["regular"],
        medium: fontsMap["medium"],
        bold: fontsMap["bold"],
      ),
    );
  }

  //Function to return GoogleFonts asMap map to be used in DropdownMenu as dropdownMenuEntries list
  List<DropdownMenuEntry> getGoogleFontsAsMap() {
    List<DropdownMenuEntry> dropdownMenuEntries = [];
    fonts.forEach((key, value) {
      dropdownMenuEntries.add(
        DropdownMenuEntry(
          value: key,
          label: key,
        ),
      );
    });
    return dropdownMenuEntries;
  }
}
