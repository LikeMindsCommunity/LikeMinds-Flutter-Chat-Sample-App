import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/navigation/router.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/asset_constants.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/bloc/poll_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/constants/string_constant.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/helper_widgets.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/picture_or_initial.dart';
import 'package:swipe_to_action/swipe_to_action.dart';

class PollResult extends StatefulWidget {
  final Conversation pollConversation;
  const PollResult({Key? key, required this.pollConversation})
      : super(key: key);

  @override
  State<PollResult> createState() => _PollResultState();
}

class _PollResultState extends State<PollResult> {
  Conversation? pollConversation;
  PollBloc pollBloc = PollBloc();
  List<Widget> tabs = [];
  List<Widget> pages = [];
  int? selectedPollId;
  int? selectedIndex = 0;
  int? noOfOptions;

  Widget getPollResultTab(
    PollViewData pollViewData,
    int noOfOptions,
    int selectedPollId,
  ) {
    double widthOfTab = 0;
    if (noOfOptions == 2) {
      widthOfTab = 50.w;
    } else if (noOfOptions >= 3) {
      widthOfTab = 33.w;
    } else {
      widthOfTab = 30.w;
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: widthOfTab,
      decoration: BoxDecoration(
          border: selectedPollId == pollViewData.id
              ? Border(
                  bottom: BorderSide(color: LMTheme.buttonColor, width: 1.5))
              : null),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widthOfTab / 1.5,
            child: Text(
              pollViewData.text,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: LMTheme.medium.copyWith(
                color: kGreyColor,
                fontSize: 8.sp,
              ),
            ),
          ),
          kVerticalPaddingMedium,
          Text(
            "${pollViewData.noVotes ?? 0}",
            style: LMTheme.medium.copyWith(
              color: kGreyColor,
              fontSize: 10.sp,
            ),
          ),
          kVerticalPaddingSmall,
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    pollConversation = widget.pollConversation;
    selectedPollId = pollConversation!.poll!.pollViewDataList![0].id!;
    selectedIndex = 0;
    noOfOptions = pollConversation!.poll!.pollViewDataList!.length;
    pollBloc.add(GetPollUsers(
        getPollUsersRequest: (GetPollUsersRequestBuilder()
              ..conversationId(widget.pollConversation.id)
              ..pollId(selectedPollId!))
            .build()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        router.pop();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              router.pop();
            },
            child: Icon(
              Icons.arrow_back,
              color: kGrey2Color,
              size: 14.sp,
            ),
          ),
          backgroundColor: kWhiteColor,
          title: Text(
            PollBubbleStringConstants.pollResults,
            style: LMTheme.medium,
          ),
        ),
        body: Container(
          color: kWhiteColor,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: kWhiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: kGreyColor.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                width: 100.w,
                height: 50,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: pollConversation!.poll!.pollViewDataList!.length,
                    itemBuilder: (context, index) => GestureDetector(
                          onTap: () {
                            selectedPollId = pollConversation!
                                .poll!.pollViewDataList![index].id!;
                            pollBloc.add(GetPollUsers(
                                getPollUsersRequest:
                                    (GetPollUsersRequestBuilder()
                                          ..conversationId(
                                              widget.pollConversation.id)
                                          ..pollId(selectedPollId!))
                                        .build()));
                            setState(() {});
                          },
                          child: getPollResultTab(
                            pollConversation!.poll!.pollViewDataList![index],
                            pollConversation!.poll!.pollViewDataList!.length,
                            selectedPollId!,
                          ),
                        )),
              ),
              Expanded(
                child: Swipeable(
                  key: Key("${pollConversation!.id}"),
                  onSwipe: (SwipeDirection direction) {
                    if (direction == SwipeDirection.startToEnd &&
                        selectedIndex! > 0) {
                      selectedIndex = selectedIndex! - 1;
                      selectedPollId = pollConversation!
                          .poll!.pollViewDataList![selectedIndex!].id!;
                      pollBloc.add(GetPollUsers(
                          getPollUsersRequest: (GetPollUsersRequestBuilder()
                                ..conversationId(widget.pollConversation.id)
                                ..pollId(selectedPollId!))
                              .build()));
                      setState(() {});
                    } else if (direction == SwipeDirection.endToStart &&
                        selectedIndex! < noOfOptions! - 1) {
                      selectedIndex = selectedIndex! + 1;
                      selectedPollId = pollConversation!
                          .poll!.pollViewDataList![selectedIndex!].id!;
                      pollBloc.add(GetPollUsers(
                          getPollUsersRequest: (GetPollUsersRequestBuilder()
                                ..conversationId(widget.pollConversation.id)
                                ..pollId(selectedPollId!))
                              .build()));
                      setState(() {});
                    }
                  },
                  background: Container(color: Colors.transparent),
                  child: BlocConsumer(
                    bloc: pollBloc,
                    listener: (context, state) {},
                    builder: (context, state) {
                      if (state is PollUsers) {
                        if (state.getPollUsersResponse.data == null ||
                            state.getPollUsersResponse.data!.isEmpty) {
                          return Container(
                            color: Colors.transparent,
                            width: 100.w,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Image.asset(
                                  kAssetEmptyScreenIcon,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                kVerticalPaddingLarge,
                                Text(
                                  "No Response",
                                  style: LMTheme.medium,
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                            itemCount: state.getPollUsersResponse.data!.length,
                            itemBuilder: (context, index) => getPollResultTile(
                                state.getPollUsersResponse.data![index]));
                      } else if (state is PollUsersLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: LMTheme.buttonColor,
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
