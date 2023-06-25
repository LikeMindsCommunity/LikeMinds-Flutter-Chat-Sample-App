import 'package:likeminds_chat_mm_fl/src/service/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/media_utils.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/widget/document_tile.dart';

// ChatBubble for Single Document Attachment
Widget getSingleDocPreview(Media media) {
  return DocumentThumbnailFile(
    size: getFileSizeString(bytes: media.size!),
    type: 'pdf',
    url: media.mediaUrl,
    docFile: media.mediaFile,
    index: 1,
  );
}

// ChatBubble for Two Document Attachment
Widget getDualDocPreview(List<Media> mediaList) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      DocumentTile(
        size: getFileSizeString(bytes: mediaList[0].size!),
        type: 'pdf',
        url: mediaList[0].mediaUrl,
        docFile: mediaList[0].mediaFile,
        index: 1,
      ),
      DocumentTile(
        size: getFileSizeString(bytes: mediaList[1].size!),
        type: 'pdf',
        url: mediaList[1].mediaUrl,
        docFile: mediaList[1].mediaFile,
        index: 1,
      )
    ],
  );
}

// ChatBubble for more than two Document Attachment

class GetMultipleDocPreview extends StatefulWidget {
  final List<Media> mediaList;
  const GetMultipleDocPreview({
    Key? key,
    required this.mediaList,
  }) : super(key: key);

  @override
  State<GetMultipleDocPreview> createState() => GgetMultipleDocPreviewState();
}

class GgetMultipleDocPreviewState extends State<GetMultipleDocPreview> {
  List<Media>? mediaList;
  ValueNotifier<bool> rebuildCurr = ValueNotifier<bool>(false);
  int length = 2;

  void onMoreButtonTap() {
    length = mediaList!.length;
    rebuildCurr.value = !rebuildCurr.value;
  }

  @override
  Widget build(BuildContext context) {
    mediaList = widget.mediaList;
    return ValueListenableBuilder(
      valueListenable: rebuildCurr,
      builder: (context, _, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: length,
              itemBuilder: (context, index) => DocumentTile(
                size: getFileSizeString(bytes: mediaList![index].size!),
                type: 'pdf',
                url: mediaList![index].mediaUrl,
                index: 1,
              ),
            ),
            mediaList!.length > 2 && mediaList!.length != length
                ? GestureDetector(
                    onTap: onMoreButtonTap,
                    behavior: HitTestBehavior.translucent,
                    child: SizedBox(
                      width: 60,
                      height: 15,
                      child: Text(
                        '+ ${mediaList!.length - 2} more',
                        style: LMTheme.medium.copyWith(
                            color: LMTheme.textLinkColor, fontSize: 9.sp),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        );
      },
    );
  }
}
