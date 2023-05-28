import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/explore/bloc/explore_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/explore/explore_page.dart';

class ExploreSpacesBar extends StatelessWidget {
  const ExploreSpacesBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: 100.w,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: GestureDetector(
          onTap: () {
            Route route = MaterialPageRoute(
              builder: (BuildContext context) => BlocProvider<ExploreBloc>(
                create: (BuildContext context) =>
                    ExploreBloc()..add(InitExploreEvent()),
                child: const ExplorePage(),
              ),
            );
            Navigator.push(context, route);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: LMBranding.instance.buttonColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.navigation_outlined,
                    color: Colors.white,
                    size: 12.sp,
                  ),
                ),
              ),
              // const SizedBox(width: 24),
              Text(
                "Explore Spaces",
                style: LMBranding.instance.fonts.medium.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Container(
                height: 28,
                width: 64,
                decoration: BoxDecoration(
                  color: LMBranding.instance.buttonColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "3 NEW",
                    style: LMBranding.instance.fonts.regular.copyWith(
                      color: Colors.white,
                    ),
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
