import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';

class PollHeader extends StatelessWidget {
  final PollInfoData poll;
  const PollHeader({Key? key, required this.poll}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.w,
      child: Row(children: <Widget>[
        Text(
          poll.pollTypeText ?? '',
          style: LMTheme.medium.copyWith(
            color: kGreyColor,
            fontSize: 8.sp,
          ),
        ),
        kHorizontalPaddingMedium,
        Text(
          "⬤",
          style: LMTheme.medium.copyWith(
            color: kGreyColor,
            fontSize: 8.sp,
          ),
        ),
        kHorizontalPaddingMedium,
        Text(
          poll.submitTypeText ?? '',
          style: LMTheme.medium.copyWith(
            color: kGreyColor,
            fontSize: 8.sp,
          ),
        )
      ]),
    );
  }
}
