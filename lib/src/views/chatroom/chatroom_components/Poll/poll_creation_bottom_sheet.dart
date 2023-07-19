import 'package:flutter/cupertino.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/constants/string_constant.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/helper_widgets.dart';

class PollCreationBottomSheet extends StatefulWidget {
  final Color? backgroundColor;
  final Color? inputBoxColor;
  final TextStyle? headerStyle;
  final TextStyle? subHeaderStyle;

  const PollCreationBottomSheet({
    Key? key,
    this.backgroundColor,
    this.inputBoxColor,
    this.headerStyle,
    this.subHeaderStyle,
  }) : super(key: key);

  @override
  State<PollCreationBottomSheet> createState() =>
      _PollCreationBottomSheetState();
}

class _PollCreationBottomSheetState extends State<PollCreationBottomSheet> {
  Color? backgroundColor;
  Color? inputBoxColor;
  TextStyle? headerStyle;
  TextStyle? subHeaderStyle;
  final _formKey = GlobalKey<FormState>();
  int pollOptionsCount = 2;
  bool _showAdvancedOptions = false;
  bool _allowAddOptions = false;
  bool _isAnonymousPoll = false;
  bool _showLiveResults = false;
  DateTime? expiryDate;

  TextEditingController pollQuestionController = TextEditingController();
  TextEditingController pollExpiryController = TextEditingController();

  List<TextEditingController> pollOptionsControllerList = [
    TextEditingController(),
    TextEditingController()
  ];

  @override
  void initState() {
    super.initState();
    backgroundColor = widget.backgroundColor ?? kGreyBackgroundColor;
    inputBoxColor = widget.inputBoxColor ?? kWhiteColor;
    headerStyle =
        widget.headerStyle ?? LMTheme.bold.copyWith(color: LMTheme.buttonColor);
    subHeaderStyle =
        widget.subHeaderStyle ?? LMTheme.medium.copyWith(color: kBlackColor);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 90.h,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6.w),
            topRight: Radius.circular(6.w),
          ),
        ),
        child: Container(
          color: backgroundColor,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    kVerticalPaddingSmall,
                    SizedBox(
                      width: 100.w,
                      child: ListTile(
                        leading: SizedBox(
                          width: 20.w,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.zero),
                            ),
                            child: Text(
                              'Cancel',
                              style: subHeaderStyle?.copyWith(
                                  color: LMTheme.buttonColor),
                            ),
                          ),
                        ),
                        title: Align(
                          alignment: Alignment.center,
                          child: Text(
                            PollCreationStringConstants.newPoll,
                            style: headerStyle,
                          ),
                        ),
                        trailing: SizedBox(width: 20.w),
                      ),
                    ),
                    Container(
                      width: 100.w,
                      padding: EdgeInsets.all(5.w),
                      color: inputBoxColor,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 90.w,
                            child: Text(
                              PollCreationStringConstants.pollQuestionText,
                              style: headerStyle,
                            ),
                          ),
                          kVerticalPaddingSmall,
                          getOptionsTile(pollQuestionController, subHeaderStyle,
                              PollCreationStringConstants.pollQuestionHint),
                        ],
                      ),
                    ),
                    kVerticalPaddingLarge,
                    Container(
                      width: 100.w,
                      padding: EdgeInsets.all(5.w),
                      color: inputBoxColor,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 90.w,
                            child: Text(
                              PollCreationStringConstants.answerOptions,
                              style: headerStyle,
                            ),
                          ),
                          kVerticalPaddingSmall,
                          Column(
                            children: [
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: pollOptionsCount,
                                itemBuilder: (context, index) => Container(
                                  width: 90.w,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: kGreyColor, width: 0.3))),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: getOptionsTile(
                                          pollOptionsControllerList[index],
                                          subHeaderStyle,
                                          PollCreationStringConstants
                                              .optionHint,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10.w,
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              pollOptionsControllerList
                                                  .removeAt(index);
                                              pollOptionsCount--;
                                            });
                                          },
                                          icon: Icon(
                                            CupertinoIcons.xmark,
                                            color: LMTheme.buttonColor,
                                            size: 10.sp,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              kVerticalPaddingLarge,
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    pollOptionsControllerList
                                        .add(TextEditingController());
                                    pollOptionsCount++;
                                  });
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: LMTheme.buttonColor,
                                    ),
                                    kHorizontalPaddingLarge,
                                    Text(
                                      PollCreationStringConstants.addOption,
                                      style: subHeaderStyle?.copyWith(
                                          color: LMTheme.buttonColor),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    kVerticalPaddingLarge,
                    GestureDetector(
                      onTap: () async {
                        DateTime currentTime = DateTime.now();
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: currentTime,
                          firstDate: currentTime,
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                          lastDate: currentTime.add(
                            const Duration(days: 365 * 4),
                          ),
                        );
                        TimeOfDay? pickedTime;
                        if (pickedDate != null) {
                          TimeOfDay currentTime = TimeOfDay.now();
                          pickedTime = await showTimePicker(
                            context: context,
                            initialTime: currentTime,
                            initialEntryMode: TimePickerEntryMode.dialOnly,
                          );
                        }
                        if (pickedTime != null) {
                          setState(() {
                            pollExpiryController.text =
                                "${formatDate(pickedDate!)} ${formatTime(pickedTime!)}";
                          });
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 100.w,
                        padding: EdgeInsets.all(5.w),
                        color: inputBoxColor,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 90.w,
                              child: Text(
                                PollCreationStringConstants.pollExpiresOn,
                                style: headerStyle,
                              ),
                            ),
                            kVerticalPaddingSmall,
                            getOptionsTile(
                              pollExpiryController,
                              subHeaderStyle,
                              enabled: false,
                              PollCreationStringConstants.pollExpiryHint,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _showAdvancedOptions
                        ? Container(
                            padding: EdgeInsets.all(5.w),
                            color: inputBoxColor,
                            margin: const EdgeInsets.only(top: 12),
                            child: Column(
                              children: <Widget>[
                                getToggleButtonWithText(
                                  status: _allowAddOptions,
                                  text: Text(
                                    'Allow voters to add options',
                                    style: subHeaderStyle,
                                  ),
                                  enabledColor: LMTheme.buttonColor,
                                  onChanged: (bool toggleUpdateValue) =>
                                      setState(
                                    () {
                                      _allowAddOptions = toggleUpdateValue;
                                    },
                                  ),
                                ),
                                kVerticalPaddingMedium,
                                getToggleButtonWithText(
                                  status: _isAnonymousPoll,
                                  text: Text(
                                    'Anonymous poll',
                                    style: subHeaderStyle,
                                  ),
                                  enabledColor: LMTheme.buttonColor,
                                  onChanged: (bool toggleUpdateValue) =>
                                      setState(
                                    () {
                                      _isAnonymousPoll = toggleUpdateValue;
                                    },
                                  ),
                                ),
                                kVerticalPaddingMedium,
                                getToggleButtonWithText(
                                  status: _showLiveResults,
                                  text: Text(
                                    'Don\'t show live results',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: subHeaderStyle,
                                  ),
                                  enabledColor: LMTheme.buttonColor,
                                  onChanged: (bool toggleUpdateValue) =>
                                      setState(
                                    () {
                                      _showLiveResults = toggleUpdateValue;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                    kVerticalPaddingLarge,
                    GestureDetector(
                      onTap: () => setState(() {
                        _showAdvancedOptions = !_showAdvancedOptions;
                      }),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ADVANCED',
                            style: LMTheme.medium.copyWith(
                              color: kGrey3Color,
                            ),
                          ),
                          kHorizontalPaddingSmall,
                          Icon(
                            _showAdvancedOptions
                                ? CupertinoIcons.chevron_up
                                : CupertinoIcons.chevron_down,
                            color: kGrey3Color,
                          ),
                        ],
                      ),
                    ),
                    kVerticalPaddingLarge,
                    kVerticalPaddingLarge,
                    getTextButton(
                      text: "Post",
                      backgroundColor: LMTheme.buttonColor,
                      borderRadius: 20,
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.w,
                        vertical: 2.w,
                      ),
                      textStyle: subHeaderStyle?.copyWith(
                        color: kWhiteColor,
                        fontSize: 13.sp,
                      ),
                    ),
                    kVerticalPaddingLarge,
                    kVerticalPaddingLarge,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
