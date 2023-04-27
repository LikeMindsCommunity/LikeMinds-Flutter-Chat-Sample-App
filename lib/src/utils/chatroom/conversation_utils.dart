import 'dart:collection';

import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';

List<Conversation> addTimeStampInConversationList(
    List<Conversation> conversationList, int communityId) {
  LinkedHashMap<String, List<Conversation>> mappedConversations =
      LinkedHashMap<String, List<Conversation>>();

  for (Conversation conversation in conversationList) {
    if (conversation.isTimeStamp == null || !conversation.isTimeStamp!) {
      if (mappedConversations.containsKey(conversation.date)) {
        mappedConversations[conversation.date]!.add(conversation);
      } else {
        mappedConversations[conversation.date!] = <Conversation>[conversation];
      }
    }
  }
  List<Conversation> conversationListWithTimeStamp = <Conversation>[];
  mappedConversations.forEach(
    (key, value) {
      conversationListWithTimeStamp.addAll(value);
      conversationListWithTimeStamp.add(
        Conversation(
          isTimeStamp: true,
          answer: key,
          communityId: communityId,
          createdAt: key,
          header: key,
          id: 0,
          pollAnswerText: key,
        ),
      );
    },
  );
  return conversationListWithTimeStamp;
}
