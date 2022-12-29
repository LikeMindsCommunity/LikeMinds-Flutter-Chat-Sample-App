import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_chat_example/utils/ui_utils.dart';
import 'package:group_chat_example/views/home/bloc/home_bloc.dart';
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
                    Fluttertoast.showToast(msg: "Add profile screen");
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
                return Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: state.chats.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return SizedBox(
                          height: 90,
                          width: getWidth(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 36),
                            child: Row(
                              children: [
                                Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 10, 24, 103),
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
                                  "Explore chatrooms",
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
                                    color: Color.fromARGB(255, 10, 24, 103),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "3 new",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return state.chats[index];
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
