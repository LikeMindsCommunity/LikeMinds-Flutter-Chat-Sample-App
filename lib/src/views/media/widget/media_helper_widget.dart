import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/service/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/media_utils.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

Widget getDocumentThumbnail(File document) {
  return PdfDocumentLoader.openFile(
    document.path,
    onError: (error) {},
    pageNumber: 1,
    pageBuilder: (context, textureBuilder, pageSize) {
      return textureBuilder();
    },
  );
}

Widget getDocumentDetails(Media document) {
  return SizedBox(
    width: 80.w,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '${document.pageCount ?? 0} ${(document.pageCount ?? 0) > 1 ? 'pages' : 'page'} ● ${getFileSizeString(bytes: document.size!)} ● PDF',
          style: LMTheme.medium.copyWith(
            color: kWhiteColor,
          ),
        )
      ],
    ),
  );
}

Future<List<Media>> pickDocumentFiles() async {
  FilePickerResult? pickedFiles = await FilePicker.platform.pickFiles(
      allowMultiple: true, type: FileType.custom, allowedExtensions: ['pdf']);
  if (pickedFiles == null) {
    return [];
  }
  List<Media> mediaList = <Media>[];
  if (pickedFiles != null && pickedFiles.files.isNotEmpty) {
    for (int i = 0; i < pickedFiles.files.length; i++) {
      File file = File(pickedFiles.paths[i]!);

      Media media = Media(
        mediaType: MediaType.document,
        mediaFile: file,
        size: pickedFiles.files[i].size,
      );
      mediaList.add(media);
    }
  }
  return mediaList;
}
