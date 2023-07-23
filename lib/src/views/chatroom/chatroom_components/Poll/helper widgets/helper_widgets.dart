import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:intl/intl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/constants/string_constant.dart';

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

Widget getPollDropDownMenu(List<String> options, Function onTap) {
  return Container(
    constraints: BoxConstraints(maxHeight: 30.h, maxWidth: 40.w),
    decoration: BoxDecoration(
      color: kWhiteColor,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: options.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(options[index]),
          onTap: () {
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

Widget getVotingType(Function onTypeSelect, Function onNumVotesSelect,
    String votingType, String numVotes) {
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
              menuBuilder: () =>
                  getPollDropDownMenu(usersCanVoteForList, onTypeSelect),
              pressType: PressType.singleClick,
              child: getDropDownText(votingType),
            ),
            const Text("="),
            CustomPopupMenu(
              menuBuilder: () =>
                  getPollDropDownMenu(numOfVotes, onNumVotesSelect),
              pressType: PressType.singleClick,
              child: getDropDownText(numVotes),
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
