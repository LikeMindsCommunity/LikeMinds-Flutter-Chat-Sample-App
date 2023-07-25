import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/constants/string_constant.dart';

int toIntPollType(bool dontShowLiveResults) {
  return dontShowLiveResults ? 1 : 0;
}

int toIntPollMultiSelectState(String toIntPollMultiSelectState) {
  switch (toIntPollMultiSelectState) {
    case PollCreationStringConstants.exactlyVotes:
      return 0;
    case PollCreationStringConstants.atMaxVotes:
      return 1;
    case PollCreationStringConstants.atLeastVotes:
      return 2;
    default:
      return 0;
  }
}

String toStringMultiSelectState(int multipleSelectState) {
  switch (multipleSelectState) {
    case 0:
      return PollCreationStringConstants.exactlyVotes;
    case 1:
      return PollCreationStringConstants.atMaxVotes;
    case 2:
      return PollCreationStringConstants.atLeastVotes;
    default:
      return PollCreationStringConstants.exactlyVotes;
  }
}

int? noOfVotes(String selectedCount) {
  int selectedCountInt = 1;
  for (int i = 0; i < numOfVotes.length; i++) {
    if (numOfVotes[i] == selectedCount) {
      selectedCountInt = i;
    }
  }
  if (selectedCountInt == 0) {
    return 1;
  } else {
    return selectedCountInt;
  }
}
