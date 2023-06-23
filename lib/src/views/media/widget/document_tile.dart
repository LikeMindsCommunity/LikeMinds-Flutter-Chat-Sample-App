import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:likeminds_chat_mm_fl/src/utils/constants/asset_constants.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/views/media/widget/document_shimmer.dart';
import 'package:path/path.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentThumbnailFile extends StatefulWidget {
  final String? url;
  final String type;
  final String size;
  final File? docFile;
  final int? index;
  final Function(int)? removeAttachment;
  const DocumentThumbnailFile({
    Key? key,
    this.docFile,
    this.url,
    this.removeAttachment,
    this.index,
    required this.size,
    required this.type,
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
    if (widget.url != null) {
      final String url = widget.url!;
      file = await DefaultCacheManager().getSingleFile(url);
    } else {
      file = widget.docFile!;
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
              if (widget.url != null) {
                debugPrint(widget.url);
                Uri fileUrl = Uri.parse(widget.url!);
                launchUrl(fileUrl, mode: LaunchMode.externalApplication);
              } else {
                OpenFilex.open(widget.docFile!.path);
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
  final String? url;
  final String type;
  final String size;
  final File? docFile;
  final int? index;
  final Function(int)? removeAttachment;

  const DocumentTile({
    super.key,
    this.docFile,
    this.url,
    this.removeAttachment,
    this.index,
    required this.size,
    required this.type,
  });

  @override
  State<DocumentTile> createState() => _DocumentTileState();
}

class _DocumentTileState extends State<DocumentTile> {
  String? _fileName;
  String? _fileExtension;
  String? _fileSize;
  String? url;
  File? file;
  Future? loadedFile;

  Future loadFile() async {
    File file;
    if (widget.url != null) {
      final String url = widget.url!;
      file = File(url);
    } else {
      file = widget.docFile!;
    }
    _fileExtension = widget.type;
    _fileSize = widget.size;
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
                if (widget.url != null) {
                  debugPrint(widget.url);
                  Uri fileUrl = Uri.parse(widget.url!);
                  launchUrl(fileUrl, mode: LaunchMode.externalApplication);
                } else {
                  OpenFilex.open(widget.docFile!.path);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: kPaddingSmall),
                child: Container(
                  height: 65,
                  width: 60.w,
                  decoration: BoxDecoration(
                      border: Border.all(color: kGreyWebBGColor, width: 1),
                      borderRadius: BorderRadius.circular(kBorderRadiusMedium)),
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
                              children: [
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
                                  _fileExtension!.toUpperCase(),
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
                      widget.docFile != null
                          ? GestureDetector(
                              onTap: () {
                                widget.removeAttachment!(widget.index!);
                              },
                              child: const CloseButtonIcon())
                          : const SizedBox.shrink()
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
