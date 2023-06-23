import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_chat_mm_fl/src/service/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';

class ChatVideoFile extends StatefulWidget {
  final Media media;
  final FlickManager flickManager;
  const ChatVideoFile(
      {Key? key, required this.media, required this.flickManager})
      : super(key: key);

  @override
  State<ChatVideoFile> createState() => _ChatVideoFileState();
}

class _ChatVideoFileState extends State<ChatVideoFile> {
  FlickManager? flickManager;
  Media? media;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    media = widget.media;
    flickManager = widget.flickManager;

    return Expanded(
      child: FlickVideoPlayer(
        flickManager: flickManager!,
        flickVideoWithControls: const FlickVideoWithControls(
          controls: SizedBox(),
          videoFit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
