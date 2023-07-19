import 'package:intl/intl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';

Widget getOptionsTile(TextEditingController textEditingController,
    TextStyle? subHeaderStyle, String hintText,
    {bool enabled = true}) {
  return TextFormField(
    controller: textEditingController,
    decoration: InputDecoration(
      hintText: hintText,
      enabled: enabled,
      hintStyle: subHeaderStyle?.copyWith(
        color: kGreyColor,
      ),
      border: InputBorder.none,
    ),
  );
}

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

Widget getTextButton({
  required String text,
  Color? backgroundColor,
  TextStyle? textStyle,
  EdgeInsets? padding,
  double? borderRadius,
  Function()? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            borderRadius == null ? null : BorderRadius.circular(borderRadius),
      ),
      child: Text(
        text,
        style: textStyle,
      ),
    ),
  );
}

String formatDate(DateTime dateTime) {
  return DateFormat("dd-MM-yy").format(dateTime);
}

String formatTime(TimeOfDay timeOfDay) {
  String hour = timeOfDay.hour.toString().padLeft(2, '0');
  String minute = timeOfDay.minute.toString().padLeft(2, '0');
  return "$hour:$minute";
}
