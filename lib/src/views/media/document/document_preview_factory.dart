import 'package:likeminds_chat_mm_fl/src/service/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/document/document_preview.dart';

Widget documentPreviewFactory(List<Media> mediaList) {
  switch (mediaList.length) {
    case 1:
      return getSingleDocPreview(mediaList.first);
    case 2:
      return getDualDocPreview(mediaList);
    default:
      return GetMultipleDocPreview(mediaList: mediaList);
  }
}
