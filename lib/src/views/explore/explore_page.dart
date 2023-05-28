import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/views/explore/bloc/explore_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/explore/explore_components/explore_item.dart';
import 'package:likeminds_chat_mm_fl/src/views/explore/space_enum.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/bloc_error.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/page_skeleton.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/spinner.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/back_button.dart' as BB;

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late Spaces _spaces;

  @override
  void initState() {
    super.initState();
    _spaces = Spaces.newest;
  }

  String getStateSpace() {
    switch (_spaces) {
      case Spaces.newest:
        return "Newest";
      case Spaces.active:
        return "Recently Active";
      case Spaces.mostParticipants:
        return "Most Participants";
      case Spaces.mostMessages:
        return "Most Messages";
    }
  }

  Future onChoosingModal(context) => showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 30.h,
            child: Column(
              children: [
                ListTile(
                  title: const Text("Newest"),
                  onTap: () {
                    setState(() {
                      _spaces = Spaces.newest;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text("Recently Active"),
                  onTap: () {
                    setState(() {
                      _spaces = Spaces.active;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text("Most Participants"),
                  onTap: () {
                    setState(() {
                      _spaces = Spaces.mostParticipants;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text("Most Messages"),
                  onTap: () {
                    setState(() {
                      _spaces = Spaces.mostMessages;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return PageSkeleton(
      appBarChildren: [
        const BB.BackButton(),
        const SizedBox(width: 24),
        Text(
          "Explore Spaces",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
      ],
      bodyChildren: [
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              //TODO: Add popup menu for choosing space
              onTap: () async => await onChoosingModal(context),
              child: Row(
                children: [
                  Text(
                    getStateSpace(),
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_downward,
                    size: 28,
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                debugPrint("Pin button tapped");
              },
              child: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.grey[300]!,
                  ),
                ),
                child: Icon(
                  Icons.push_pin,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocConsumer<ExploreBloc, ExploreState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is ExploreLoading) {
              return const Center(child: Spinner());
            }

            if (state is ExploreLoaded) {
              return Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: state.spaces.length,
                  itemBuilder: (context, index) {
                    return ExploreItem(
                      space: state.spaces[index],
                      refresh: () => refresh(),
                      onTap: () {},
                    );
                  },
                ),
              );
            }

            return const BlocError();
          },
        ),
      ],
    );
  }

  void refresh() => setState(() {});
}
