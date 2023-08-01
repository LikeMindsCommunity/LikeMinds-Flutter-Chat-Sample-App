import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/packages/expandable_text/expandable_text.dart';
import 'package:likeminds_chat_mm_fl/src/navigation/router.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/utils/utils.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chat_action_bloc/chat_action_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/bloc/poll_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/constants/poll_mapping.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/constants/string_constant.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/add_option_bottom_sheet.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/helper_widgets.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/poll_end_tile.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/poll_header.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/poll_option.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/poll_submission_bottom_sheet.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/utils/poll_submit_validator.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/custom_dialog.dart';
import 'package:overlay_support/overlay_support.dart';

class PollBubble extends StatefulWidget {
  final Conversation pollConversation;
  final int chatroomId;
  const PollBubble(
      {Key? key, required this.pollConversation, required this.chatroomId})
      : super(key: key);

  @override
  State<PollBubble> createState() => _PollBubbleState();
}

class _PollBubbleState extends State<PollBubble> {
  Conversation? pollConversation;
  bool isSubmitted = false;
  bool isEnabled = false;
  bool isEditing = false;
  List<PollViewData> selectedOptions = [];

  User user = UserLocalPreference.instance.fetchUserData();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
  }

  @override
  void didUpdateWidget(PollBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    initialise();
  }

  void initialise() {
    pollConversation = widget.pollConversation;
    for (int i = 0; i < pollConversation!.poll!.pollViewDataList!.length; i++) {
      if (pollConversation!.poll!.pollViewDataList![i].isSelected!) {
        isSubmitted = true;
        selectedOptions.add(pollConversation!.poll!.pollViewDataList![i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    PollBloc pollBloc = BlocProvider.of<PollBloc>(context);
    ChatActionBloc chatActionBloc = BlocProvider.of<ChatActionBloc>(context);
    return BlocListener(
      bloc: pollBloc,
      listener: (context, state) {
        if (state is PollOptionAdded &&
            state.conversationId == pollConversation!.id) {
          int index = pollConversation!.poll!.pollViewDataList!.indexWhere(
              (element) =>
                  element.id == state.addPollOptionResponse.temporaryId);
          pollConversation!.poll!.pollViewDataList![index].id =
              state.addPollOptionResponse.pollViewData!.id;
          setState(() {});
        }
        if (state is PollOptionError &&
            state.conversationId == pollConversation!.id) {
          toast(state.errorMessage);
          pollConversation!.poll!.pollViewDataList!.removeWhere((element) =>
              element.id == state.addPollOptionRequest.temporaryId);
          setState(() {});
        }
        if (state is SubmittedPoll &&
            state.conversationId == pollConversation!.id) {
          isSubmitted = true;
          isEditing = false;
          if (pollConversation!.poll!.pollType == 1) {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              elevation: 5,
              enableDrag: true,
              useSafeArea: true,
              isScrollControlled: true,
              builder: (context) => const PollSubmissionBottomSheet(),
            );
          }
          chatActionBloc.add(UpdatePollConversation(
              conversationId: pollConversation!.id,
              chatroomId: widget.chatroomId));
        }
        if (state is PollSubmitError &&
            state.submitPollRequest.conversationId == pollConversation!.id) {
          toast(state.errorMessage);
        }
      },
      child: Container(
        width: 60.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: <Widget>[
            PollHeader(
              poll: pollConversation!.poll!,
            ),
            kVerticalPaddingLarge,
            PollEndTile(pollConversation: pollConversation!),
            kVerticalPaddingLarge,
            Align(
              alignment: Alignment.topLeft,
              child: ExpandableText(
                pollConversation!.answer,
                expandText: "",
                textAlign: TextAlign.left,
              ),
            ),
            pollConversation!.poll!.multipleSelectNum != null &&
                    pollConversation!.multipleSelectState != null
                ? Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(top: kPaddingXSmall),
                    child: Text(
                      "*Select ${toStringMultiSelectState(pollConversation!.multipleSelectState!)} ${toStringNoOfVotes(pollConversation!.poll!.multipleSelectNum!)}",
                      style: LMTheme.regular
                          .copyWith(fontSize: 8.sp, color: kGreyColor),
                    ),
                  )
                : const SizedBox(),
            kVerticalPaddingLarge,
            PollOptionList(
              pollConversation: pollConversation!,
              isSubmitted: isSubmitted,
              selectedOptions: selectedOptions,
              onTap: (PollViewData selectedOption) {
                if (!isEditing && isSubmitted) {
                  isEditing = true;
                  setState(() {});
                }
                if (isPollEnded(DateTime.fromMillisecondsSinceEpoch(
                    pollConversation!.poll!.expiryTime!))) {
                  toast("Poll ended, Vote cannot be submitted now");
                  return;
                }
                if (isSubmitted && pollConversation!.poll!.pollType == 0) {
                  return;
                }
                if (selectedOptions.contains(selectedOption)) {
                  selectedOptions.remove(selectedOption);
                  if (pollConversation!.poll!.multipleSelectState != null) {
                    isEnabled = PollSubmitValidator.checkMultiSelectPoll(
                        pollConversation!.poll!, selectedOptions);
                  }
                } else {
                  if (pollConversation!.poll!.multipleSelectNum != null &&
                      (pollConversation!.poll!.multipleSelectState == 0 ||
                          pollConversation!.poll!.multipleSelectState == 1) &&
                      selectedOptions.length ==
                          pollConversation!.poll!.multipleSelectNum) {
                    toast(
                        "Please selected only ${pollConversation!.poll!.multipleSelectNum} options");
                  } else {
                    isEditing = true;

                    if (pollConversation!.poll!.multipleSelectState != null) {
                      selectedOptions.add(selectedOption);
                      isEnabled = PollSubmitValidator.checkMultiSelectPoll(
                          pollConversation!.poll!, selectedOptions);
                      setState(() {});
                    } else {
                      selectedOptions = [selectedOption];
                      PollSubmitValidator.checkNonMultiStatePoll(
                          context, pollConversation!.poll!, selectedOptions);
                      setState(() {});
                    }
                  }
                }
              },
            ),
            (!isSubmitted && pollConversation!.poll!.pollType == 0) &&
                    pollConversation!.poll!.allowAddOption! &&
                    !isPollEnded(DateTime.fromMillisecondsSinceEpoch(
                        pollConversation!.poll!.expiryTime!))
                ? getTextButton(
                    width: 60.w,
                    alignment: Alignment.center,
                    text: PollBubbleStringConstants.addAnOption,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    borderRadius: 8.0,
                    onTap: () async {
                      await showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          elevation: 5,
                          useSafeArea: true,
                          isScrollControlled: true,
                          builder: (context) => AddPollOptionBottomSheet(
                                onOptionAdded: (String value) {
                                  int temporaryId =
                                      DateTime.now().millisecondsSinceEpoch;
                                  PollViewData newPollOption = PollViewData(
                                    text: value,
                                    conversationId: pollConversation!.id,
                                    noVotes: 0,
                                    isSelected: false,
                                    percentage: 0,
                                    id: temporaryId,
                                    memberId: user.id,
                                  );
                                  pollBloc.add(AddPollOption(
                                      (AddPollOptionRequestBuilder()
                                            ..conversationId(
                                                pollConversation!.id)
                                            ..pollViewData(newPollOption)
                                            ..temporaryId(temporaryId))
                                          .build()));

                                  pollConversation!.poll!.pollViewDataList!.add(
                                    newPollOption,
                                  );
                                  setState(() {});
                                },
                              ));
                    },
                    border: Border.all(
                      color: LMTheme.buttonColor,
                      width: 1,
                    ),
                  )
                : const SizedBox(),
            Align(
              alignment: Alignment.topLeft,
              child: TextButton(
                onPressed: pollConversation!.poll!.toShowResult!
                    ? () {
                        router.push(pollResultRoute, extra: pollConversation!);
                      }
                    : () {
                        if (pollConversation!.poll!.isAnonymous != true) {
                          showDialog(
                              context: context,
                              builder: (context) => LMCustomDialog(
                                    title: "Anonymous poll",
                                    showCancel: false,
                                    content:
                                        "This being an anonymous poll, the names of the voters can not be disclosed",
                                    actionText: "Okay",
                                    onActionPressed: () {},
                                  ));
                        }
                      },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                ),
                child: Text(
                  pollConversation!.poll!.pollAnswerText!,
                  style: LMTheme.medium.copyWith(
                    color: LMTheme.buttonColor,
                    fontSize: 8.sp,
                  ),
                ),
              ),
            ),
            !(isSubmitted && pollConversation!.poll!.pollType == 0) &&
                    pollConversation!.poll!.multipleSelectState != null &&
                    !isPollEnded(DateTime.fromMillisecondsSinceEpoch(
                        pollConversation!.poll!.expiryTime!))
                ? getSubmitButton(
                    text:
                        isSubmitted && !isEditing ? "Edit Vote" : "SUBMIT VOTE",
                    textStyle: LMTheme.medium.copyWith(
                        color: isEnabled ? LMTheme.buttonColor : kGrey2Color),
                    borderRadius: 16.0,
                    enabledColor: isEnabled ? LMTheme.buttonColor : kGrey2Color,
                    border: Border.all(
                      color: isEnabled ? LMTheme.buttonColor : kGrey2Color,
                      width: 1.5,
                    ),
                    onTap: () async {
                      if (!isEditing) {
                        isEditing = true;
                        setState(() {});
                      }
                      if (isEnabled && (!isSubmitted || isEditing)) {
                        SubmitPollRequest request = (SubmitPollRequestBuilder()
                              ..conversationId(pollConversation!.id)
                              ..polls(selectedOptions))
                            .build();
                        pollBloc.add(SubmitPoll(submitPollRequest: request));
                        isEditing = false;
                        setState(() {});
                      }
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
