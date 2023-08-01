import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/constants/poll_mapping.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/constants/string_constant.dart';

String getMultiSelectNoString(PollInfoData pollInfoData) {
  return "Select ${toStringMultiSelectState(pollInfoData.multipleSelectState!)} ${numOfVotes[pollInfoData.multipleSelectNum!]}*";
}
