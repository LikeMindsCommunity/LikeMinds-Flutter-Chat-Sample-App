import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:likeminds_chat_mm_fl/src/service/media_service.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/asset_constants.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/media_utils.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/widget/document_shimmer.dart';
import 'package:path/path.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentThumbnailFile extends StatefulWidget {
  final int? index;
  final Media media;

  const DocumentThumbnailFile({
    Key? key,
    required this.media,
    this.index,
  }) : super(key: key);

  @override
  State<DocumentThumbnailFile> createState() => _DocumentThumbnailFileState();
}

class _DocumentThumbnailFileState extends State<DocumentThumbnailFile> {
  String? _fileName;
  String? url;
  File? file;
  Future? loadedFile;
  Widget? documentFile;

  Future loadFile() async {
    url = widget.media.mediaUrl;
    if (url != null) {
      file = await DefaultCacheManager().getSingleFile(url!);
    } else {
      file = widget.media.mediaFile;
    }
    _fileName = basenameWithoutExtension(file!.path);
    documentFile = PdfDocumentLoader.openFile(
      file!.path,
      pageNumber: 1,
      pageBuilder: (context, textureBuilder, pageSize) => SizedBox(
        child: Container(
          height: 80,
          width: 60.w,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(
                kBorderRadiusMedium,
              ),
              topRight: Radius.circular(
                kBorderRadiusMedium,
              ),
            ),
          ),
          child: textureBuilder(
            size: Size(pageSize.width, pageSize.height),
          ),
        ),
      ),
    );
    return file;
  }

  @override
  void initState() {
    super.initState();
    loadedFile = loadFile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadedFile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return InkWell(
            onTap: () async {
              if (widget.media.mediaUrl != null) {
                debugPrint(widget.media.mediaUrl);
                Uri fileUrl = Uri.parse(widget.media.mediaUrl!);
                launchUrl(fileUrl, mode: LaunchMode.externalApplication);
              } else {
                OpenFilex.open(file!.path);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  child: documentFile!,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: kPaddingSmall),
                  child: Container(
                    height: 55,
                    width: 60.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: kGreyWebBGColor, width: 1),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(
                          kBorderRadiusMedium,
                        ),
                        bottomRight: Radius.circular(
                          kBorderRadiusMedium,
                        ),
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: kPaddingLarge),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          kAssetDocPDFIcon,
                          fit: BoxFit.contain,
                        ),
                        kHorizontalPaddingSmall,
                        Expanded(
                          child: Text(
                            _fileName ?? '',
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(fontSize: 10.sp, color: kGrey2Color),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return getDocumentTileShimmer();
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class DocumentTile extends StatefulWidget {
  final Media media;

  const DocumentTile({
    super.key,
    required this.media,
  });

  @override
  State<DocumentTile> createState() => _DocumentTileState();
}

class _DocumentTileState extends State<DocumentTile> {
  String? _fileName;
  final String _fileExtension = 'pdf';
  String? _fileSize;
  File? file;
  Future? loadedFile;

  Future loadFile() async {
    File file;
    if (widget.media.mediaUrl != null) {
      final String url = widget.media.mediaUrl!;
      file = File(url);
    } else {
      file = widget.media.mediaFile!;
    }

    _fileSize = getFileSizeString(bytes: widget.media.size!);
    _fileName = basenameWithoutExtension(file.path);
    return file;
  }

  @override
  void initState() {
    super.initState();
    loadedFile = loadFile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadedFile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return InkWell(
              onTap: () async {
                if (widget.media.mediaUrl != null) {
                  debugPrint(widget.media.mediaUrl);
                  Uri fileUrl = Uri.parse(widget.media.mediaUrl!);
                  launchUrl(fileUrl, mode: LaunchMode.externalApplication);
                } else {
                  OpenFilex.open(widget.media.mediaFile!.path);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: kPaddingSmall),
                child: Container(
                  height: 70,
                  width: 60.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: kGreyWebBGColor, width: 1),
                    borderRadius: BorderRadius.circular(kBorderRadiusMedium),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: kPaddingLarge),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        kAssetDocPDFIcon,
                        fit: BoxFit.contain,
                      ),
                      kHorizontalPaddingSmall,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fileName ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 10.sp, color: kGrey2Color),
                            ),
                            kVerticalPaddingSmall,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                widget.media.pageCount != null
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          kHorizontalPaddingXSmall,
                                          Text(
                                            "${widget.media.pageCount!} ${widget.media.pageCount! > 1 ? "Pages" : "Page"}",
                                            style: TextStyle(
                                                fontSize: 8.sp,
                                                color: kGrey3Color),
                                          ),
                                          kHorizontalPaddingXSmall,
                                          Text(
                                            '·',
                                            style: TextStyle(
                                                fontSize: 8.sp,
                                                color: kGrey3Color),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                kHorizontalPaddingXSmall,
                                Text(
                                  _fileSize!.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 8.sp, color: kGrey3Color),
                                ),
                                kHorizontalPaddingXSmall,
                                Text(
                                  '·',
                                  style: TextStyle(
                                      fontSize: 8.sp, color: kGrey3Color),
                                ),
                                kHorizontalPaddingXSmall,
                                Text(
                                  _fileExtension.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 8.sp, color: kGrey3Color),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return getDocumentTileShimmer();
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}
