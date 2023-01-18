import 'package:get_it/get_it.dart';
import 'package:group_chat_example/services/likeminds_service.dart';

GetIt locator = GetIt.I;

void setupLocator() {
  locator.registerLazySingleton(() => LikeMindsService());
}
