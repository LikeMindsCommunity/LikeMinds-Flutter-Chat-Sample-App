import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat_example/utils/ui_utils.dart';

class ChatBubble extends StatefulWidget {
  final bool? isSent;
  final String? message;
  final String? time;
  final String? profileImageUrl;

  const ChatBubble({
    super.key,
    this.isSent = true,
    this.message,
    this.time,
    this.profileImageUrl,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    bool _isSent = widget.isSent!;
    String _message = widget.message ?? "Test message";
    String _time = widget.time ?? "12:00";
    String _profileImageUrl =
        widget.profileImageUrl ?? "https://picsum.photos/200/300";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            mainAxisAlignment:
                _isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              !_isSent
                  ? Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(21),
                        image: _profileImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_profileImageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 42,
                  maxWidth: getWidth(context) * 0.7,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: _isSent
                        ? Colors.grey.withOpacity(0.7)
                        : Colors.green.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: _isSent
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          _message,
                          style: GoogleFonts.roboto(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _time,
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _isSent
                  ? Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(21),
                        image: _profileImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_profileImageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }
}
