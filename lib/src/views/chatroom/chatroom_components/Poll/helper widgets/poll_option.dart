import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';

class PollOptionList extends StatefulWidget {
  final Conversation pollConversation;
  final Function(PollViewData) onTap;
  const PollOptionList({
    Key? key,
    required this.pollConversation,
    required this.onTap,
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
        onTap: widget.onTap,
      ),
    );
  }
}

class PollOption extends StatefulWidget {
  final PollViewData pollViewData;
  final Function(PollViewData) onTap;
  const PollOption({
    Key? key,
    required this.pollViewData,
    required this.onTap,
  }) : super(key: key);

  @override
  State<PollOption> createState() => _PollOptionState();
}

class _PollOptionState extends State<PollOption> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.pollViewData.isSelected = !widget.pollViewData.isSelected!;
        widget.onTap(widget.pollViewData);
        setState(() {});
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60.w,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color:
                  widget.pollViewData.isSelected! ? kPrimaryColor : kWhiteColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: widget.pollViewData.isSelected!
                    ? kPrimaryColor
                    : kGreyColor,
                width: 1,
              ),
            ),
            child: Text(
              widget.pollViewData.text,
              style: LMTheme.medium.copyWith(
                color:
                    widget.pollViewData.isSelected! ? kWhiteColor : kGreyColor,
                fontSize: 8.sp,
              ),
            ),
          ),
          kVerticalPaddingXSmall,
          Text(
            "${widget.pollViewData.noVotes!} ${widget.pollViewData.noVotes! > 1 ? "votes" : "vote"}",
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
