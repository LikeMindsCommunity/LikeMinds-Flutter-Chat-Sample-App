import 'dart:collection';

import 'package:flutter_portal/flutter_portal.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/utils/imports.dart';

Offset getPositionOfChatBubble(GlobalKey widgetKey) {
  RenderBox? renderBox =
      widgetKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) {
    return const Offset(0, 0);
  }

  final Offset offset = renderBox.localToGlobal(Offset.zero);
  return offset;
}

Aligned getPortalOverlayAlignedFromPosition(
    double screenHeight, Offset positionOfWidget) {
  if (positionOfWidget.dy < screenHeight / 2) {
    return const Aligned(
        follower: Alignment.topCenter,
        target: Alignment.bottomCenter,
        offset: Offset(0, 10));
  } else {
    return const Aligned(
        follower: Alignment.topCenter,
        target: Alignment.topCenter,
        offset: Offset(0, -50));
  }
}

List<Conversation>? addTimeStampInConversationList(
    List<Conversation>? conversationList, int communityId) {
  if (conversationList == null) {
    return conversationList;
  }
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
          chatroomId: 0,
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
