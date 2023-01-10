import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat_example/constants.dart';
import 'package:group_chat_example/utils/ui_utils.dart';
import 'package:group_chat_example/views/explore/bloc/explore_bloc.dart';
import 'package:group_chat_example/views/explore/explore_page.dart';

class ExploreSpacesBar extends StatelessWidget {
  const ExploreSpacesBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: getWidth(context),
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
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.navigation_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Text(
                "Explore Spaces",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                height: 28,
                width: 64,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "3 NEW",
                    style: GoogleFonts.montserrat(
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
