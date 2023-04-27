import 'package:go_router/go_router.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';

class BackButton extends StatelessWidget {
  const BackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        height: 24.sp,
        width: 24.sp,
        decoration: BoxDecoration(
          color: LMBranding.instance.buttonColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.arrow_back,
          size: 18.sp,
          color: Colors.white,
        ),
      ),
    );
  }
}
