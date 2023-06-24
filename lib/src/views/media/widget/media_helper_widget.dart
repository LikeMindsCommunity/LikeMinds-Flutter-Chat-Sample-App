import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:likeminds_chat_mm_fl/src/utils/branding/theme.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/service/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/media_constant.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/media_utils.dart';
import 'package:pdf_bitmaps/pdf_bitmaps.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

Widget getChatItemAttachmentTile(List<Media> mediaFiles) {
  if (mediaFiles.isEmpty) {
    return const SizedBox();
  } else {
    IconData iconData = Icons.camera_alt;
    String text = '';
    if (mediaFiles.first.mediaType == MediaType.document) {
      iconData = Icons.insert_drive_file;
      text =
          "${mediaFiles.length} ${mediaFiles.length > 1 ? "Documents" : "Document"}";
    } else {
      int videoCount = 0;
      int imageCount = 0;
      for (Media media in mediaFiles) {
        if (media.mediaType == MediaType.video) {
          videoCount++;
        } else {
          imageCount++;
        }
      }
      if (videoCount != 0 && imageCount != 0) {
        return Row(
          children: <Widget>[
            Icon(
              Icons.video_camera_back,
              color: kGreyColor,
              size: 12.sp,
            ),
            kHorizontalPaddingSmall,
            Text(
              videoCount.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LMBranding.instance.fonts.regular.copyWith(
                fontSize: 10.sp,
                fontWeight: FontWeight.normal,
              ),
            ),
            kHorizontalPaddingMedium,
            Icon(
              Icons.camera_alt,
              color: kGreyColor,
              size: 12.sp,
            ),
            kHorizontalPaddingSmall,
            Text(
              imageCount.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LMBranding.instance.fonts.regular.copyWith(
                fontSize: 10.sp,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        );
      } else if (videoCount == 0) {
        iconData = Icons.camera_alt;
        text =
            "${mediaFiles.length} ${mediaFiles.length > 1 ? "Images" : "Image"}";
      } else if (imageCount == 0) {
        iconData = Icons.video_camera_back;
        text =
            "${mediaFiles.length} ${mediaFiles.length > 1 ? "Videos" : "Video"}";
      }
    }
    return Row(
      children: <Widget>[
        Icon(
          iconData,
          color: kGreyColor,
          size: 12.sp,
        ),
        kHorizontalPaddingSmall,
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: LMBranding.instance.fonts.regular.copyWith(
            fontSize: 10.sp,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

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

Future<File?> getVideoThumbnail(Media media) async {
  String? thumbnailPath = await VideoThumbnail.thumbnailFile(
    video: media.mediaFile!.path,
    imageFormat: ImageFormat.JPEG,
    maxWidth: 300,
    quality: 50,
    timeMs: 100,
  ).onError((error, stackTrace) {
    debugPrint(error.toString());
  });

  File? thumbnailFile;
  if (thumbnailPath != null) {
    thumbnailFile = File(thumbnailPath);
    ui.Image image = await decodeImageFromList(thumbnailFile.readAsBytesSync());
    media.width = image.width;
    media.height = image.height;
    media.thumbnailFile ??= thumbnailFile;
  }

  return thumbnailFile;
}

MediaType getMediaTypeFromExtention(String extention) {
  if (videoExtentions.contains(extention)) {
    return MediaType.video;
  } else {
    return MediaType.photo;
  }
}

Future<List<Media>> pickMediaFiles() async {
  FilePickerResult? pickedFiles = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: mediaExtentions,
  );
  List<Media> mediaList = <Media>[];
  if (pickedFiles == null) {
    return [];
  }
  if (pickedFiles.files.isNotEmpty) {
    for (int i = 0; i < pickedFiles.files.length; i++) {
      File file = File(pickedFiles.paths[i]!);
      MediaType mediaType =
          getMediaTypeFromExtention(pickedFiles.files[i].extension!);
      Media media;
      if (mediaType == MediaType.photo) {
        ui.Image image = await decodeImageFromList(file.readAsBytesSync());
        media = Media(
          mediaType: mediaType,
          height: image.height,
          width: image.width,
          mediaFile: file,
          size: pickedFiles.files[i].size,
        );
      } else {
        media = Media(
          mediaType: mediaType,
          mediaFile: file,
          size: pickedFiles.files[i].size,
        );
      }
      getVideoThumbnail(media);
      mediaList.add(media);
    }
  }
  return mediaList;
}

Future<List<Media>> pickDocumentFiles() async {
  FilePickerResult? pickedFiles = await FilePicker.platform.pickFiles(
      allowMultiple: true, type: FileType.custom, allowedExtensions: ['pdf']);
  if (pickedFiles == null) {
    return [];
  }
  List<Media> mediaList = <Media>[];
  if (pickedFiles.files.isNotEmpty) {
    for (int i = 0; i < pickedFiles.files.length; i++) {
      File file = File(pickedFiles.paths[i]!);
      int? pageCount = await PdfBitmaps().pdfPageCount(
        params: PDFPageCountParams(pdfPath: file.path),
      );
      Media media = Media(
        mediaType: MediaType.document,
        mediaFile: file,
        size: pickedFiles.files[i].size,
        pageCount: pageCount,
      );
      mediaList.add(media);
    }
  }
  return mediaList;
}
