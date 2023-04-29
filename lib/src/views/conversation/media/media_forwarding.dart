import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/media/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/bloc/chat_action_bloc/chat_action_bloc.dart';

class MediaForward extends StatefulWidget {
  File mediaFile;
  MediaType mediaType;
  MediaForward({Key? key, required this.mediaFile, required this.mediaType})
      : super(key: key);

  @override
  State<MediaForward> createState() => _MediaForwardState();
}

class _MediaForwardState extends State<MediaForward> {
  @override
  Widget build(BuildContext context) {
    ChatActionBloc chatActionBloc = BlocProvider.of<ChatActionBloc>(context);
    return Scaffold(
      backgroundColor: kBlackColor,
      appBar: AppBar(
        backgroundColor: kBlackColor,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        elevation: 0,
      ),
      bottomSheet: Container(
        color: kBlackColor,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onTap: () {},
              child: SizedBox(
                width: 10.w,
                height: 10.w,
                child: Icon(
                  Icons.add_a_photo,
                  color: kWhiteColor,
                  size: 24.sp,
                ),
              ),
            ),
            SizedBox(
              width: 60.w,
              child: TextField(),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: LMTheme.buttonColor,
                  borderRadius: BorderRadius.circular(
                    100.0,
                  ),
                ),
                child: Icon(
                  Icons.send,
                  color: kWhiteColor,
                  size: 24.sp,
                ),
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          const Spacer(),
          Align(
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.file(
                widget.mediaFile,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
