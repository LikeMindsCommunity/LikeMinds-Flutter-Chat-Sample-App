import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chatroom_bloc.dart';
// import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_page.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/bloc/home_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/home_components/chat_item.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/home_components/explore_spaces_bar.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/home_components/skeleton_list.dart';
import 'package:likeminds_chat_mm_fl/src/views/profile/bloc/profile_bloc.dart';
import 'package:likeminds_chat_mm_fl/src/views/profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 72),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Community",
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Route route = MaterialPageRoute(
                      builder: (BuildContext context) =>
                          BlocProvider<ProfileBloc>(
                        create: (BuildContext context) =>
                            ProfileBloc()..add(InitProfileEvent()),
                        child: const ProfilePage(
                          isSelf: true,
                        ),
                      ),
                    );
                    Navigator.push(context, route);
                  },
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 74, 0, 201),
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: Center(
                      child: Text(
                        "KA",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          // const SizedBox(height: 18),
          BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is HomeLoaded) {
                Fluttertoast.showToast(msg: "Chats loaded");
              }
            },
            builder: (context, state) {
              if (state is HomeLoading) {
                return const SkeletonChatList();
              }

              if (state is HomeLoaded) {
                List<ChatItem> chatItems = getChats(context);
                return Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: chatItems.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const ExploreSpacesBar();
                      }
                      return chatItems[index];
                    },
                  ),
                );
              }

              return const Center(
                child: Text("Something went wrong"),
              );
            },
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

List<ChatItem> getChats(BuildContext context) {
  List<ChatItem> chats = [];

  for (int i = 0; i < 10; i++) {
    chats.add(ChatItem(
      name: "Testy $i",
      message:
          "Lorem ipsum message $i dolor sit amet, consectetur adipiscing elit.",
      time: "11:1$i",
      avatarUrl: "https://www.picsum.photos/200/300",
      onTap: () {
        // Route route = MaterialPageRoute(
        //   builder: (BuildContext context) => BlocProvider<ChatroomBloc>(
        //     create: (BuildContext context) =>
        //         ChatroomBloc()..add(InitChatroomEvent(i)),
        //     child: const ChatroomPage(),
        //   ),
        // );
        // Navigator.push(context, route);
      },
    ));
  }

  return chats;
}
