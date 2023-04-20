import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';

class ChatroomMenu extends StatelessWidget {
  late final CustomPopupMenuController _controller;

  ChatroomMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _controller = CustomPopupMenuController();

    return CustomPopupMenu(
      pressType: PressType.singleClick,
      showArrow: false,
      controller: _controller,
      enablePassEvent: false,
      menuBuilder: () => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 50.w,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  _controller.hideMenu();
                  Route route = MaterialPageRoute(
                    builder: (context) => const ChatroomParticipantsPage(),
                  );
                  Navigator.push(context, route);
                  // // _controller.hideMenu();
                },
                title: Text(
                  "View Participants",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  Fluttertoast.showToast(msg: "Add mute notifications");
                  _controller.hideMenu();
                },
                title: Text(
                  "Mute notifications",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  Fluttertoast.showToast(msg: "Add leave chatroom");
                  _controller.hideMenu();
                },
                title: Text(
                  "Leave chatroom",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  _controller.hideMenu();
                  Route route = MaterialPageRoute(
                    builder: (context) => const ChatroomReportPage(),
                  );
                  Navigator.push(context, route);
                  _controller.hideMenu();
                },
                title: Text(
                  "Report chatroom",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      child: Icon(
        Icons.menu,
        size: 24,
        color: primaryColor,
      ),
    );
  }
}
