import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_chat_example/isolate_screen.dart';
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const IsolatePage(),
      home: BlocProvider(
        create: (context) => HomeBloc()..add(InitHomeEvent()),
        child: const HomePage(),
      ),
    );
  }
}
