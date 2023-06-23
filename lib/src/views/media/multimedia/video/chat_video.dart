import 'package:flick_video_player/flick_video_player.dart';
import 'package:likeminds_chat_mm_fl/src/service/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';

class ChatVideo extends StatefulWidget {
  final Media media;
  final FlickManager flickManager;
  final bool showControls;
  const ChatVideo(
      {Key? key,
      required this.media,
      required this.flickManager,
      this.showControls = false})
      : super(key: key);

  @override
  State<ChatVideo> createState() => _ChatVideoState();
}

class _ChatVideoState extends State<ChatVideo> {
  FlickManager? flickManager;
  Media? media;
  bool? showControls;
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
    showControls = widget.showControls;
    return Expanded(
      child: showControls!
          ? FlickVideoPlayer(
              flickManager: flickManager!,
              flickVideoWithControls: const FlickVideoWithControls(
                controls: FlickPortraitControls(),
                videoFit: BoxFit.fitWidth,
              ),
            )
          : FlickVideoPlayer(
              flickManager: flickManager!,
              flickVideoWithControls: FlickVideoWithControls(
                controls: FlickShowControlsAction(
                  child: FlickSeekVideoAction(
                    child: Center(
                      child: FlickVideoBuffer(
                        child: FlickAutoHideChild(
                          showIfVideoNotInitialized: false,
                          child: FlickPlayToggle(
                            size: 30,
                            color: kBlackColor,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kWhiteColor.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                videoFit: BoxFit.fitWidth,
              ),
            ),
    );
  }
}
