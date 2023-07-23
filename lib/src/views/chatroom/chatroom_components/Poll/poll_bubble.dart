import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/packages/expandable_text/expandable_text.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/local_preference/local_prefs.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/constants/string_constant.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/add_option_bottom_sheet.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/helper_widgets.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/poll_end_tile.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/poll_header.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/poll_option.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/poll_submission_bottom_sheet.dart';
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
  User user = UserLocalPreference.instance.fetchUserData();

  void initialise() {
    pollConversation = widget.pollConversation;
  }

  @override
  Widget build(BuildContext context) {
    initialise();
    return Container(
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
          PollOptionList(pollConversation: pollConversation!),
          pollConversation!.poll!.allowAddOption!
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
                                // TODO: Call addPoll api
                                if (true) {
                                  PollViewData newPollOption = PollViewData(
                                    text: value,
                                    conversationId: pollConversation!.id,
                                    noVotes: 0,
                                    isSelected: false,
                                    percentage: 0,
                                    memberId: user.id,
                                  );
                                  pollConversation!.poll!.pollViewDataList!.add(
                                    newPollOption,
                                  );
                                } else {
                                  // TODO: Show error toast
                                  toast("An error occured");
                                }
                              },
                            ));
                    setState(() {});
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
              onPressed: () {},
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
          pollConversation!.poll!.multipleSelectNum != null &&
                  pollConversation!.poll!.multipleSelectNum! > 1
              ? getTextButton(
                  text: "SUBMIT VOTE",
                  borderRadius: 16.0,
                  border: Border.all(
                    color: LMTheme.buttonColor,
                    width: 1.2,
                  ),
                  onTap: () async {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      elevation: 5,
                      enableDrag: true,
                      useSafeArea: true,
                      isScrollControlled: true,
                      builder: (context) => const PollSubmissionBottomSheet(),
                    );
                  },
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0))
              : const SizedBox(),
        ],
      ),
    );
  }
}
