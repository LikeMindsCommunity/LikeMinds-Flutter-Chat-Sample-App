import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:intl/intl.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/constants/string_constant.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/picture_or_initial.dart';

Widget getDropDownText(String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Text(text, style: LMTheme.medium),
      kHorizontalPaddingMedium,
      const Icon(
        Icons.arrow_drop_down,
        color: kGreyColor,
      ),
    ],
  );
}

Widget getPollDropDownMenu(
    CustomPopupMenuController controller, List<String> options, Function onTap,
    {int? optionsCount}) {
  return Container(
    constraints: BoxConstraints(maxHeight: 30.h, maxWidth: 40.w),
    decoration: BoxDecoration(
      color: kWhiteColor,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: optionsCount == null ? options.length : optionsCount + 1,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(options[index]),
          onTap: () {
            controller.hideMenu();
            onTap(options[index]);
          },
        );
      },
    ),
  );
}

// This function is used to get a text field with a label
Widget getOptionsTile(TextEditingController textEditingController,
    TextStyle? subHeaderStyle, String hintText,
    {bool enabled = true}) {
  return TextFormField(
    controller: textEditingController,
    decoration: InputDecoration(
      enabled: enabled,
      contentPadding: const EdgeInsets.only(top: 10),
      hintStyle: subHeaderStyle?.copyWith(
        color: kGreyColor,
      ),
      hintText: hintText,
      border: InputBorder.none,
    ),
  );
}

// This function is used to get a toggle button with text
Widget getToggleButtonWithText({
  required bool status,
  required Widget text,
  Color? enabledColor,
  Function(bool)? onChanged,
}) {
  return SizedBox(
    width: 90.w,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: text,
        ),
        kHorizontalPaddingMedium,
        Switch(
          value: status,
          onChanged: onChanged,
          activeColor: enabledColor,
        )
      ],
    ),
  );
}

// This function is used to get a text button with a background color
Widget getTextButton({
  required String text,
  Color? backgroundColor,
  double? width,
  TextStyle? textStyle,
  EdgeInsets? padding,
  double? borderRadius,
  BoxBorder? border,
  Function()? onTap,
  Alignment? alignment,
  TextAlign textAlign = TextAlign.left,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: padding,
      alignment: alignment,
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: border,
        borderRadius:
            borderRadius == null ? null : BorderRadius.circular(borderRadius),
      ),
      child: Text(
        text,
        style: textStyle,
        textAlign: textAlign,
      ),
    ),
  );
}

Widget getVotingType(int optionsCount, Function onTypeSelect,
    Function onNumVotesSelect, String? votingType, String? numVotes) {
  CustomPopupMenuController voteTypeController = CustomPopupMenuController();
  CustomPopupMenuController numVotesController = CustomPopupMenuController();
  return SizedBox(
    width: 90.w,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(PollCreationStringConstants.votingTypeText,
            style: LMTheme.medium.copyWith(color: kGrey3Color)),
        kVerticalPaddingMedium,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            CustomPopupMenu(
              controller: voteTypeController,
              menuBuilder: () => getPollDropDownMenu(
                  voteTypeController, usersCanVoteForList, onTypeSelect),
              pressType: PressType.singleClick,
              child: getDropDownText(votingType ?? usersCanVoteForList[0]),
            ),
            const Text("="),
            CustomPopupMenu(
              controller: numVotesController,
              menuBuilder: () => getPollDropDownMenu(
                  numVotesController, numOfVotes, onNumVotesSelect,
                  optionsCount: optionsCount),
              pressType: PressType.singleClick,
              child: getDropDownText(
                numVotes ?? numOfVotes[0],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// This function is used to convert DateTime object into string in the format dd-MM-yy
String formatDate(DateTime dateTime) {
  return DateFormat("dd-MM-yy").format(dateTime);
}

// This function is used to convert TimeOfDay object into string in the format HH:mm
String formatTime(TimeOfDay timeOfDay) {
  String hour = timeOfDay.hour.toString().padLeft(2, '0');
  String minute = timeOfDay.minute.toString().padLeft(2, '0');
  return "$hour:$minute";
}

Widget getPollResultTile(User user) {
  return Container(
    width: 100.w,
    margin: const EdgeInsets.only(top: 10.0),
    padding: const EdgeInsets.symmetric(
      horizontal: 20.0,
    ),
    child: Row(
      children: <Widget>[
        PictureOrInitial(
          fallbackText: user.name,
          imageUrl: user.imageUrl,
          backgroundColor: LMTheme.buttonColor,
          size: 15.w,
        ),
        kHorizontalPaddingLarge,
        Expanded(
          child: Container(
            height: 15.w,
            decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: kGreyColor, width: 0.5))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  user.name,
                  style: LMTheme.medium,
                ),
                kVerticalPaddingMedium,
                Text(
                  user.memberSince ?? '',
                  style: LMTheme.medium.copyWith(color: kGreyColor),
                ),
              ],
            ),
          ),
        )
      ],
    ),
  );
}
