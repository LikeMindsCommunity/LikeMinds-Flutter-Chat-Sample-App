import 'dart:io';
import 'dart:ui' as ui;
import 'package:likeminds_chat_mm_fl/src/utils/credentials/credentials.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:path/path.dart';

import 'package:simple_s3/simple_s3.dart';

enum MediaType { photo, video, document, audio, poll }

MediaType mapIntToMediaType(int mediaType) {
  switch (mediaType) {
    case 1:
      return MediaType.photo;
    case 2:
      return MediaType.video;
    case 3:
      return MediaType.document;
    case 4:
      return MediaType.audio;
    case 5:
      return MediaType.poll;
    default:
      return MediaType.photo;
  }
}

int mapMediaTypeToInt(MediaType mediaType) {
  switch (mediaType) {
    case MediaType.photo:
      return 1;
    case MediaType.video:
      return 2;
    case MediaType.document:
      return 3;
    default:
      return -1;
  }
}

class Media {
  File? mediaFile;
  MediaType mediaType;
  String? mediaUrl;
  int? width;
  int? height;
  String? thumbnailUrl;
  File? thumbnailFile;
  int? pageCount;
  int? size; // In bytes

  Media({
    this.mediaFile,
    required this.mediaType,
    this.mediaUrl,
    this.height,
    this.pageCount,
    this.size,
    this.thumbnailFile,
    this.thumbnailUrl,
    this.width,
  });
}

class MediaService {
  late final String _bucketName;
  late final String _poolId;
  final _region = AWSRegions.apSouth1;
  final SimpleS3 _s3Client = SimpleS3();

  MediaService(bool isProd) {
    _bucketName = isProd ? CredsProd.bucketName : CredsDev.bucketName;
    _poolId = isProd ? CredsProd.poolId : CredsDev.poolId;
  }

  Future<String?> uploadFile(
    File file,
    int chatroomId,
    int conversationId,
  ) async {
    try {
      String fileName = basenameWithoutExtension(file.path);
      String currTimeInMilli = DateTime.now().millisecondsSinceEpoch.toString();

      String result = await _s3Client.uploadFile(
        file,
        _bucketName,
        _poolId,
        _region,
        s3FolderPath:
            "files/collabcard/$chatroomId/conversation/$conversationId/",
      );
      return result;
    } on SimpleS3Errors catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
