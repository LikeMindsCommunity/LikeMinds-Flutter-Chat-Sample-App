import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_chat_example/service_locator.dart';
import 'package:group_chat_example/views/home/bloc/home_bloc.dart';
import 'package:group_chat_example/views/home/home_page.dart';

void main() {
  runApp(const MyApp());
  setupLocator();
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
      // home: const ProfilePage(),
      home: BlocProvider(
        create: (context) => HomeBloc()..add(InitHomeEvent()),
        child: const HomePage(),
      ),
    );
  }
}
