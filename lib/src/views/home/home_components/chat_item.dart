// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/ui_utils.dart';
import 'package:intl/intl.dart';

class ChatItem extends StatefulWidget {
  final String name;
  final String message;
  final String time;
  final int? unreadCount;
  final String? avatarUrl;
  final Function()? onTap;

  const ChatItem(
      {super.key,
      this.name = "Testy McTester",
      this.message = "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
      this.time = "11:11",
      this.unreadCount = 2,
      this.avatarUrl,
      this.onTap});

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  @override
  Widget build(BuildContext context) {
    String _name = widget.name;
    String _message = widget.message;
    String _time = widget.time;
    int? _unreadCount = widget.unreadCount;
    String? _avatarUrl = widget.avatarUrl;
    Function()? _onTap = widget.onTap;

    return GestureDetector(
      onTap: _onTap,
      child: SizedBox(
        width: getWidth(context),
        height: 90,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(32),
                image: _avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(_avatarUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _name,
                      style: LMBranding.instance.fonts.medium.copyWith(
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LMBranding.instance.fonts.regular.copyWith(
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('kk:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.tryParse(_time) ?? 0)),
                  style: LMBranding.instance.fonts.regular.copyWith(
                    fontSize: 9.sp,
                  ),
                ),
                const SizedBox(height: 6),
                Visibility(
                  visible: _unreadCount != 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 10, 24, 103),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _unreadCount.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
