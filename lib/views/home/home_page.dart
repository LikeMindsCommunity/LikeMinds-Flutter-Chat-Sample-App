import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:group_chat_example/constants.dart';
import 'package:group_chat_example/utils/ui_utils.dart';
import 'package:group_chat_example/views/chatroom/bloc/chatroom_bloc.dart';
import 'package:group_chat_example/views/chatroom/chatroom_page.dart';
import 'package:group_chat_example/views/explore/bloc/explore_bloc.dart';
import 'package:group_chat_example/views/explore/explore_page.dart';
import 'package:group_chat_example/views/home/bloc/home_bloc.dart';
import 'package:group_chat_example/views/home/home_components/chat_item.dart';
import 'package:group_chat_example/views/profile/bloc/profile_bloc.dart';
import 'package:group_chat_example/views/profile/profile_page.dart';
import 'package:group_chat_example/widgets/spinner.dart';

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
                return const Spinner();
              }

              if (state is HomeLoaded) {
                List<ChatItem> chatItems = getChats(context);
                return Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    itemCount: chatItems.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return SizedBox(
                          height: 90,
                          width: getWidth(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: GestureDetector(
                              onTap: () {
                                Route route = MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      BlocProvider<ExploreBloc>(
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
        Route route = MaterialPageRoute(
          builder: (BuildContext context) => BlocProvider<ChatroomBloc>(
            create: (BuildContext context) =>
                ChatroomBloc()..add(InitChatroomEvent(i)),
            child: const ChatroomPage(),
          ),
        );
        Navigator.push(context, route);
      },
    ));
  }

  return chats;
}
