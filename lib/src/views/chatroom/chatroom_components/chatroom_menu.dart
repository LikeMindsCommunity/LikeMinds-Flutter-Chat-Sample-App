import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/navigation/router.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/constants.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/participants_bloc/participants_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/views/chatroom_participants_page.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/views/chatroom_report_page.dart';
import 'package:overlay_support/overlay_support.dart';

class ChatroomMenu extends StatelessWidget {
  final ChatRoom chatroom;
  final List<ChatroomAction> chatroomActions;
  final CustomPopupMenuController _controller = CustomPopupMenuController();

  ChatroomMenu({
    Key? key,
    required this.chatroom,
    required this.chatroomActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      pressType: PressType.singleClick,
      showArrow: false,
      controller: _controller,
      enablePassEvent: false,
      menuBuilder: () => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: BoxConstraints(
            minWidth: 42.w,
            maxWidth: 52.w,
          ),
          color: Colors.white,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: chatroomActions.length,
            itemBuilder: (BuildContext context, int index) {
              return getListTile(chatroomActions[index]);
            },
          ),
        ),
      ),
      child: Icon(
        Icons.menu,
        size: 18.sp,
        color: LMTheme.buttonColor,
      ),
    );
  }

  Widget? getListTile(ChatroomAction action) {
    return action.id != 9
        ? ListTile(
            visualDensity: VisualDensity.compact,
            minVerticalPadding: kPaddingSmall,
            onTap: () {
              _controller.hideMenu();
              performAction(action);
            },
            title: Text(
              action.title,
              style: LMTheme.regular.copyWith(
                fontSize: 9.sp,
                fontWeight: FontWeight.w400,
                color: LMTheme.buttonColor,
              ),
            ),
          )
        : null;
  }

  void performAction(ChatroomAction action) {
    switch (action.id) {
      case 2:
        _controller.hideMenu();
        router.push("/participants", extra: chatroom);
        break;
      case 6:
        muteChatroom();
        break;
      case 8:
        muteChatroom();
        break;
      case 9:
        leaveChatroom();
        break;
      case 15:
        leaveChatroom();
        break;
      default:
        unimplemented();
    }
  }

  void unimplemented() {
    Fluttertoast.showToast(msg: "Coming Soon");
  }

  void muteChatroom() async {
    final response =
        await locator<LikeMindsService>().muteChatroom(MuteChatroomRequest(
      chatroomId: chatroom.id,
      value: !chatroom.muteStatus!,
    ));
    if (response.success) {
      _controller.hideMenu();
      Fluttertoast.showToast(msg: "Mute status changed");
    } else {
      toast(response.errorMessage!);
    }
  }

  void leaveChatroom() async {
    if (!(chatroom.isSecret ?? false)) {
      final response = await locator<LikeMindsService>()
          .followChatroom(FollowChatroomRequest(
        chatroomId: chatroom.id,
        value: false,
      ));
      if (response.success) {
        _controller.hideMenu();
        Fluttertoast.showToast(msg: "Chatroom left");
        router.pop();
      } else {
        Fluttertoast.showToast(msg: response.errorMessage!);
      }
    } else {
      final response = await locator<LikeMindsService>()
          .deleteParticipant((DeleteParticipantRequestBuilder()
                ..chatroomId(chatroom.id)
                ..isSecret(true))
              .build());
      if (response.success) {
        _controller.hideMenu();
        Fluttertoast.showToast(msg: "Chatroom left");
        router.pop();
      } else {
        Fluttertoast.showToast(msg: response.errorMessage!);
      }
    }
    // final response =
    //     await locator<LikeMindsService>().leaveChatroom(LeaveChatroomRequest(
    //   chatroomId: chatroom.id,
    // ));
    // if (response.success) {
    //   toast("Chatroom left");
    // } else {
    //   toast(response.errorMessage!);
    // }
  }
}
