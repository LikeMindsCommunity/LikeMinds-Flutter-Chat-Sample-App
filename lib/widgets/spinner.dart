import 'package:flutter/material.dart';
import 'package:group_chat_example/constants.dart';

class Spinner extends StatelessWidget {
  final Color? color;

  const Spinner({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: color ?? primaryColor,
      ),
    );
  }
}
