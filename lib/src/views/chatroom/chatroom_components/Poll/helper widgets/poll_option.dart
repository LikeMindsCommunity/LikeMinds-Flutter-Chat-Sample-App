import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';

class PollOptionList extends StatefulWidget {
  final Conversation pollConversation;
  final Function(PollViewData) onTap;
  final bool isSubmitted;
  const PollOptionList({
    Key? key,
    required this.pollConversation,
    required this.isSubmitted,
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
        pollConversation: pollConversation,
        onTap: widget.onTap,
      ),
    );
  }
}

class PollOption extends StatefulWidget {
  final PollViewData pollViewData;
  final Conversation? pollConversation;
  final Function(PollViewData) onTap;
  const PollOption({
    Key? key,
    required this.pollViewData,
    required this.pollConversation,
    required this.onTap,
  }) : super(key: key);

  @override
  State<PollOption> createState() => _PollOptionState();
}

class _PollOptionState extends State<PollOption> {
  @override
  Widget build(BuildContext context) {
    widget.pollViewData;
    return InkWell(
      onTap: () {
        widget.pollViewData.isSelected = !widget.pollViewData.isSelected!;
        widget.onTap(widget.pollViewData);
        setState(() {});
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                clipBehavior: Clip.none,
                height: 45,
                width: widget.pollConversation!.poll!.toShowResult!
                    ? widget.pollViewData.percentage == null
                        ? 0
                        : widget.pollViewData.percentage! * 60.w
                    : 0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: widget.pollConversation!.poll!.toShowResult!
                      ? LMTheme.buttonColor.withOpacity(0.3)
                      : null,
                ),
              ),
              Container(
                width: 60.w,
                height: 45,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.pollViewData.isSelected!
                        ? LMTheme.buttonColor
                        : kGreyColor,
                    width: widget.pollViewData.isSelected! ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40.w,
                      child: Text(
                        widget.pollViewData.text,
                        style: LMTheme.medium.copyWith(
                          color: kGreyColor,
                          fontSize: 8.sp,
                        ),
                      ),
                    ),
                    const Spacer(),
                    widget.pollViewData.isSelected!
                        ? Icon(
                            Icons.check_circle,
                            color: LMTheme.buttonColor,
                          )
                        : const SizedBox(),
                    kHorizontalPaddingSmall,
                  ],
                ),
              ),
            ],
          ),
          kVerticalPaddingXSmall,
          widget.pollConversation!.poll!.toShowResult!
              ? Text(
                  "${widget.pollViewData.noVotes!} ${widget.pollViewData.noVotes! > 1 ? "votes" : "vote"}",
                  style: LMTheme.medium.copyWith(
                    color: kGreyColor,
                    fontSize: 8.sp,
                  ),
                )
              : const SizedBox(),
          kVerticalPaddingMedium,
        ],
      ),
    );
  }
}