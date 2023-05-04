import 'package:cached_network_image/cached_network_image.dart';
import 'package:likeminds_chat_mm_fl/likeminds_chat_mm_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/utils/ui_utils.dart';
import 'package:likeminds_chat_mm_fl/src/views/conversation/media/media_utils.dart';
import 'package:likeminds_chat_mm_fl/src/views/home/home_page.dart';
import 'package:likeminds_chat_mm_fl/src/widgets/spinner.dart';

class PictureOrInitial extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final double? size;
  final double? fontSize;
  final Color? backgroundColor;

  const PictureOrInitial({
    super.key,
    this.imageUrl,
    required this.fallbackText,
    this.size,
    this.fontSize,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size ?? 42.sp,
      width: size ?? 42.sp,
      decoration: BoxDecoration(
        color: backgroundColor ?? LMBranding.instance.headerColor,
        borderRadius: BorderRadius.circular(21.sp),
      ),
      child: Center(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                imageBuilder: (context, imageProvider) => Container(
                  height: size ?? 42.sp,
                  width: size ?? 42.sp,
                  decoration: BoxDecoration(
                    color: LMBranding.instance.headerColor,
                    borderRadius: BorderRadius.circular(21.sp),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                progressIndicatorBuilder: (context, url, progress) => Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21.sp),
                  ),
                  child: mediaShimmer(),
                ),
                errorWidget: (context, url, error) => mediaErrorWidget(),
              )
            : Text(
                getInitials(fallbackText),
                style: LMFonts.instance.bold.copyWith(
                  fontSize: fontSize ?? 12.sp,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
