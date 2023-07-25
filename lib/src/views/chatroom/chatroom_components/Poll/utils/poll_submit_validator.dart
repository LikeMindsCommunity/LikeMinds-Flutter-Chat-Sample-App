import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';
import 'package:likeminds_chat_mm_fl/src/views/chatroom/chatroom_components/Poll/bloc/poll_bloc.dart';
import 'package:overlay_support/overlay_support.dart';

class PollSubmitValidator {
  static void checkInstantPollSubmittion(BuildContext context,
      PollInfoData pollInfoData, List<PollViewData> selectedOptions) {
    PollBloc pollBloc = BlocProvider.of<PollBloc>(context);
    // multi select state = exactly
    SubmitPollRequest request = (SubmitPollRequestBuilder()
          ..conversationId(pollInfoData.conversationId!)
          ..polls(selectedOptions))
        .build();
    if (pollInfoData.multipleSelectState == 0) {
      if (selectedOptions.length == pollInfoData.multipleSelectNum!) {
        pollBloc.add(SubmitPoll(submitPollRequest: request));
      } else {
        toast("Please select ${pollInfoData.multipleSelectNum} options");
      }
    }
    // multi select state = at max
    else if (pollInfoData.multipleSelectState == 1) {
      if (selectedOptions.length <= pollInfoData.multipleSelectNum!) {
        pollBloc.add(SubmitPoll(submitPollRequest: request));
      } else {
        toast("Please select ${pollInfoData.multipleSelectNum} options");
      }
    }
    // multi select state = at least
    else if (pollInfoData.multipleSelectState == 2) {
      if (selectedOptions.length >= pollInfoData.multipleSelectNum!) {
        pollBloc.add(SubmitPoll(submitPollRequest: request));
      } else {
        toast(
            "Please select at least ${pollInfoData.multipleSelectNum} options");
      }
    }
  }

  static bool checkDeferredPollSubmition(
      PollInfoData pollInfoData, List<PollViewData> selectedOptions) {
    // multi select state = exactly
    if (pollInfoData.multipleSelectState == 0) {
      if (selectedOptions.length == pollInfoData.multipleSelectNum!) {
        return true;
      } else {
        toast("Please select ${pollInfoData.multipleSelectNum} options");
        return false;
      }
    }
    // multi select state = at max
    else if (pollInfoData.multipleSelectState == 1) {
      if (selectedOptions.length <= pollInfoData.multipleSelectNum!) {
        return true;
      } else {
        toast("Please select ${pollInfoData.multipleSelectNum} options");
        return false;
      }
    }
    // multi select state = at least
    else if (pollInfoData.multipleSelectState == 2) {
      if (selectedOptions.length >= pollInfoData.multipleSelectNum!) {
        return true;
      } else {
        toast(
            "Please select at least ${pollInfoData.multipleSelectNum} options");
        return false;
      }
    }
    return false;
  }
}
