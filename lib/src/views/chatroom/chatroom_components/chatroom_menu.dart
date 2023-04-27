import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/constants.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/participants_bloc/participants_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/views/chatroom_participants_page.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/views/chatroom_report_page.dart';

class ChatroomMenu extends StatelessWidget {
  final ChatRoom chatroom;
  const ChatroomMenu({
    Key? key,
    required this.chatroom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CustomPopupMenuController _controller = CustomPopupMenuController();

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
                    builder: (context) => BlocProvider<ParticipantsBloc>(
                      create: (context) => ParticipantsBloc(),
                      child: ChatroomParticipantsPage(
                        chatroom: chatroom,
                      ),
                    ),
                  );
                  Navigator.push(context, route);
                  // // _controller.hideMenu();
                },
                title: Text(
                  "View Participants",
                  style: LMTheme.regular.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: LMTheme.buttonColor,
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
                  style: LMTheme.regular.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: LMTheme.buttonColor,
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
                  style: LMTheme.regular.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: LMTheme.buttonColor,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  // _controller.hideMenu();
                  // Route route = MaterialPageRoute(
                  //   builder: (context) => const ChatroomReportPage(),
                  // );
                  // Navigator.push(context, route);
                  // _controller.hideMenu();
                },
                title: Text(
                  "Report chatroom",
                  style: LMTheme.regular.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: LMTheme.buttonColor,
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
        color: LMTheme.buttonColor,
      ),
    );
  }
}
