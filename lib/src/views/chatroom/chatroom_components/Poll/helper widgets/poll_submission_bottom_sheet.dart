import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/constants/string_constant.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/helper%20widgets/helper_widgets.dart';

class PollSubmissionBottomSheet extends StatelessWidget {
  const PollSubmissionBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 50.h,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: const BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: <Widget>[
            kVerticalPaddingLarge,
            kVerticalPaddingLarge,
            Icon(
              Icons.check_circle,
              color: LMTheme.buttonColor,
              size: 45.sp,
            ),
            kVerticalPaddingLarge,
            Text(
              PollBubbleStringConstants.voteSubmissionSuccess,
              style: LMTheme.bold.copyWith(fontSize: 11.sp),
            ),
            kVerticalPaddingLarge,
            Text(
              PollBubbleStringConstants.voteSubmissionSuccessDescription,
              textAlign: TextAlign.center,
              style: LMTheme.medium.copyWith(
                color: kGrey3Color,
                fontSize: 10.sp,
              ),
            ),
            kVerticalPaddingLarge,
            Text(
              PollBubbleStringConstants.resultWillBeAnnounced,
              textAlign: TextAlign.center,
              style: LMTheme.medium.copyWith(
                color: LMTheme.buttonColor,
                fontSize: 10.sp,
              ),
            ),
            kVerticalPaddingLarge,
            kVerticalPaddingLarge,
            getTextButton(
              text: "Continue",
              borderRadius: 15.0,
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 40.0,
              ),
              onTap: () => Navigator.pop(context),
              backgroundColor: LMTheme.buttonColor,
              textAlign: TextAlign.center,
              textStyle: LMTheme.medium.copyWith(
                fontSize: 10.sp,
                color: kWhiteColor,
              ),
            ),
            kVerticalPaddingLarge,
            kVerticalPaddingLarge,
          ],
        ),
      ),
    );
  }
}
