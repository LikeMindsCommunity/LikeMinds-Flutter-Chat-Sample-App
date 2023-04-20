import 'package:get_it/get_it.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';

final GetIt locator = GetIt.instance;

void setupChat({required String apiKey, required LMSdkCallback lmCallBack}) {
  locator.registerSingleton(LikeMindsService(
    apiKey: apiKey,
    lmCallBack: lmCallBack,
  ));
}
