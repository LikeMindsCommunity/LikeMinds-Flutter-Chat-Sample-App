import 'package:flick_video_player/flick_video_player.dart';
import 'package:likeminds_chat_mm_fl/src/service/media_service.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/multimedia/video/chat_video_file.dart';

Widget chatVideoFactory(Media media, FlickManager flickManager) {
  if (media.mediaFile != null || media.mediaUrl != null) {
    return ChatVideoFile(media: media, flickManager: flickManager);
  }
  return const SizedBox.shrink();
}
