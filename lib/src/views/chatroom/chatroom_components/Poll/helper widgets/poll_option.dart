import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';

class PollOptionList extends StatefulWidget {
  final Conversation pollConversation;
  const PollOptionList({
    Key? key,
    required this.pollConversation,
  }) : super(key: key);

  @override
  State<PollOptionList> createState() => _PollOptionListState();
}

class _PollOptionListState extends State<PollOptionList> {
  Conversation? pollConversation;

  @override
  Widget build(BuildContext context) {
    pollConversation = widget.pollConversation;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: pollConversation!.poll!.pollViewDataList!.length,
      itemBuilder: (context, index) => PollOption(
        pollViewData: pollConversation!.poll!.pollViewDataList![index],
        onTap: (PollViewData selectedIOption) {},
      ),
    );
  }
}

class PollOption extends StatelessWidget {
  final PollViewData pollViewData;
  final Function(PollViewData) onTap;
  const PollOption({
    Key? key,
    required this.pollViewData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(pollViewData),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60.w,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: pollViewData.isSelected! ? kPrimaryColor : kWhiteColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: pollViewData.isSelected! ? kPrimaryColor : kGreyColor,
                width: 1,
              ),
            ),
            child: Text(
              pollViewData.text,
              style: LMTheme.medium.copyWith(
                color: pollViewData.isSelected! ? kWhiteColor : kGreyColor,
                fontSize: 8.sp,
              ),
            ),
          ),
          kVerticalPaddingXSmall,
          Text(
            "${pollViewData.noVotes!} ${pollViewData.noVotes! > 1 ? "votes" : "vote"}",
            style: LMTheme.medium.copyWith(
              color: kGreyColor,
              fontSize: 8.sp,
            ),
          ),
          kVerticalPaddingMedium,
        ],
      ),
    );
  }
}
