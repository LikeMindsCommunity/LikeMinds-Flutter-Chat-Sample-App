import 'package:flutter_svg/svg.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/navigation/router.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/asset_constants.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';

class ExploreSpacesBar extends StatelessWidget {
  const ExploreSpacesBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        router.push(exploreRoute);
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 2.w,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 42.sp,
              width: 42.sp,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    kAssetExploreIcon,
                    color: LMTheme.buttonColor,
                    width: 8.w,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
              ),
              child: Text(
                'Explore',
                style: LMTheme.medium.copyWith(fontSize: 12.sp),
              ),
            ),
            const Spacer(),
            FutureBuilder(
                future: locator<LikeMindsService>().getExploreTabCount(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  }
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    if (snapshot.data!.success) {
                      GetExploreTabCountResponse response =
                          snapshot.data!.data!;

                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.w,
                        ),
                        decoration: BoxDecoration(
                            color: LMTheme.buttonColor,
                            borderRadius: BorderRadius.circular(4.w),
                            shape: BoxShape.rectangle),
                        child: Text(
                          response.unseenChannelCount == null ||
                                  response.unseenChannelCount == 0
                              ? '${response.totalChannelCount} Chatrooms'
                              : '${response.unseenChannelCount} New',
                          style: LMTheme.medium.copyWith(
                            color: kWhiteColor,
                            fontSize: 8.sp,
                          ),
                        ),
                      );
                    } else {
                      const SizedBox();
                    }
                  }
                  return const SizedBox();
                })
          ],
        ),
      ),
    );
  }
}
