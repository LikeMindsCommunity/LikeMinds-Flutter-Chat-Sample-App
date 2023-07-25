import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/packages/expandable_text/expandable_text.dart';
import 'package:likeminds_chat_mm_fl/src/navigation/router.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/utils/utils.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/bloc/poll_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/constants/string_constant.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/add_option_bottom_sheet.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/helper_widgets.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/poll_end_tile.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/poll_header.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/poll_option.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/poll_submission_bottom_sheet.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/utils/poll_submit_validator.dart';
import 'package:overlay_support/overlay_support.dart';

class PollBubble extends StatefulWidget {
  final Conversation pollConversation;
  const PollBubble({Key? key, required this.pollConversation})
      : super(key: key);

  @override
  State<PollBubble> createState() => _PollBubbleState();
}

class _PollBubbleState extends State<PollBubble> {
  Conversation? pollConversation;
  bool isSubmitted = false;
  List<PollViewData> selectedOptions = [];

  User user = UserLocalPreference.instance.fetchUserData();

  void initialise() {
    pollConversation = widget.pollConversation;
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0;
        i < widget.pollConversation.poll!.pollViewDataList!.length;
        i++) {
      if (widget.pollConversation.poll!.pollViewDataList![i].isSelected!) {
        isSubmitted = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    initialise();
    PollBloc pollBloc = BlocProvider.of<PollBloc>(context);
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
        if (state is SubmittedPoll) {
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
        if (state is PollSubmitError) {
          toast(state.errorMessage);
        }
      },
      child: Container(
        width: 60.w,
        padding: const EdgeInsets.all(12.0),
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
            kVerticalPaddingLarge,
            PollOptionList(
              pollConversation: pollConversation!,
              isSubmitted: isSubmitted,
              onTap: (PollViewData selectedOption) {
                if (selectedOptions.contains(selectedOption)) {
                  selectedOptions.remove(selectedOption);
                } else {
                  if ((pollConversation!.poll!.multipleSelectState == 0 ||
                          pollConversation!.poll!.multipleSelectState == 1) &&
                      selectedOptions.length ==
                          pollConversation!.poll!.multipleSelectNum) {
                    toast("");
                  } else {
                    selectedOptions.add(selectedOption);
                  }
                }
                if (pollConversation!.poll!.pollType == 0) {
                  PollSubmitValidator.checkInstantPollSubmittion(
                      context, pollConversation!.poll!, selectedOptions);
                } else {
                  PollSubmitValidator.checkDeferredPollSubmition(
                      pollConversation!.poll!, selectedOptions);
                }
              },
            ),
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
                    : null,
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
            pollConversation!.pollType == 1 &&
                    !isPollEnded(DateTime.fromMillisecondsSinceEpoch(
                        pollConversation!.poll!.expiryTime!))
                ? getTextButton(
                    text: "SUBMIT VOTE",
                    borderRadius: 16.0,
                    border: Border.all(
                      color: LMTheme.buttonColor,
                      width: 1.2,
                    ),
                    onTap: () async {
                      SubmitPollRequest request = (SubmitPollRequestBuilder()
                            ..conversationId(pollConversation!.id)
                            ..polls(selectedOptions))
                          .build();
                      pollBloc.add(SubmitPoll(submitPollRequest: request));
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
