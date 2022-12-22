import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_chat_example/views/chatroom/chatroom_components/chat_bubble.dart';
import 'package:group_chat_example/views/home/bloc/home_bloc.dart';
import 'views/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LikeMinds Group Chat Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => HomeBloc()..add(InitHomeEvent()),
        child: const HomePage(),
      ),
    );
  }
}
