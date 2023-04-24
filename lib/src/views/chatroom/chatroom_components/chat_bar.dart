import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';

class ChatBar extends StatefulWidget {
  const ChatBar({super.key});

  @override
  State<ChatBar> createState() => _ChatBarState();
}

class _ChatBarState extends State<ChatBar> {
  late CustomPopupMenuController _popupMenuController;
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;

  @override
  void initState() {
    _popupMenuController = CustomPopupMenuController();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
    super.initState();
  }

  String getText() {
    if (_textEditingController.text.isNotEmpty) {
      return _textEditingController.text;
    } else {
      return "";
    }
  }

  @override
  void dispose() {
    _popupMenuController.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        padding: const EdgeInsets.all(4),
                        onPressed: () {
                          _focusNode.requestFocus();
                        },
                        icon: const Icon(Icons.emoji_emotions_outlined),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _textEditingController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type a message",
                            hintStyle: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      CustomPopupMenu(
                        controller: _popupMenuController,
                        arrowColor: Colors.white,
                        menuBuilder: () => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 60.w,
                            height: 148,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.camera_alt_outlined,
                                              color: LMBranding
                                                  .instance.buttonColor,
                                            ),
                                            const SizedBox(height: 2),
                                            const Text(
                                              "Camera",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {},
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.photo_outlined,
                                                color: LMBranding
                                                    .instance.buttonColor,
                                              ),
                                              const SizedBox(height: 2),
                                              const Text(
                                                "Gallery",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.file_copy_outlined,
                                              color: LMBranding
                                                  .instance.buttonColor,
                                            ),
                                            const SizedBox(height: 2),
                                            const Text(
                                              "Document",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.headphones_outlined,
                                              color: LMBranding
                                                  .instance.buttonColor,
                                            ),
                                            const SizedBox(height: 2),
                                            const Text(
                                              "Audio",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 36),
                                        GestureDetector(
                                          onTap: () {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) =>
                                            //         ChatroomPollsPage(),
                                            //   ),
                                            // );
                                          },
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.bar_chart_outlined,
                                                color: LMBranding
                                                    .instance.buttonColor,
                                              ),
                                              const SizedBox(height: 2),
                                              const Text(
                                                "Poll",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Column(
                                        //   children: const [
                                        //     Icon(Icons.camera_alt),
                                        //     SizedBox(width: 4),
                                        //     Text(
                                        //       "Camera",
                                        //       style: TextStyle(
                                        //         fontSize: 16,
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        pressType: PressType.singleClick,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.attach_file),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Fluttertoast.showToast(msg: "Send message");
                },
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: LMBranding.instance.buttonColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
