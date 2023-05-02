import 'package:collection/collection.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_mm_fl/src/service/likeminds_service.dart';
import 'package:likeminds_chat_mm_fl/src/service/service_locator.dart';

class TaggingHelper {
  static final RegExp tagRegExp = RegExp(r'@([a-z\sA-Z\s0-9]+)~');

  static final RegExp routeRegExp = RegExp(
      r'<<([a-z\sA-Z]+)\|route://member/([a-zA-Z\0-9]+)>>|<<([a-z\sA-Z\s0-9]+)\|route://member/([0-9]+)>>');

  /// Encodes the string with the user tags and returns the encoded string
  static String encodeString(String string, List<UserTag> userTags) {
    final Iterable<RegExpMatch> matches = tagRegExp.allMatches(string);
    for (final match in matches) {
      final String tag = match.group(1)!;
      final UserTag? userTag =
          userTags.firstWhereOrNull((element) => element.name! == tag);
      if (userTag != null) {
        string = string.replaceAll(
            '@$tag~', '<<${userTag.name}|route://member/${userTag.id}>>');
      }
    }
    return string;
  }

  /// Decodes the string with the user tags and returns the decoded string
  static Map<String, String> decodeString(String string) {
    Map<String, String> result = {};
    final Iterable<RegExpMatch> matches = routeRegExp.allMatches(string);
    for (final match in matches) {
      final String tag = match.group(1) ?? match.group(3) ?? match.group(5)!;
      final String id = match.group(2) ?? match.group(4) ?? match.group(6)!;
      string = string.replaceAll('<<$tag|route://member/$id>>', '@$tag~');
      result.addAll({'@$tag': id});
    }
    return result;
  }

  /// Matches the tags in the string and returns the list of matched tags
  static List<UserTag> matchTags(String text, List<UserTag> items) {
    final List<UserTag> tags = [];
    final Iterable<RegExpMatch> matches = tagRegExp.allMatches(text);
    for (final match in matches) {
      final String tag = match.group(1)!;
      final UserTag? userTag =
          items.firstWhereOrNull((element) => element.name! == tag);
      if (userTag != null) {
        tags.add(userTag);
      }
    }
    return tags;
  }

  static void routeToProfile(String userId) {
    print(userId);
  }

  static String? convertRouteToTag(String? text) {
    if (text == null) return null;
    final Iterable<RegExpMatch> matches = routeRegExp.allMatches(text);

    for (final match in matches) {
      final String tag = match.group(1) ?? match.group(3) ?? match.group(5)!;
      final String id = match.group(2) ?? match.group(4) ?? match.group(6)!;
      text = text!.replaceAll('<<$tag|route://member/$id>>', '@$tag');
    }
    return text;
  }

  static Map<String, dynamic> convertRouteToTagAndUserMap(String text,
      {bool withTilde = true}) {
    final Iterable<RegExpMatch> matches = routeRegExp.allMatches(text);
    List<UserTag> userTags = [];
    for (final match in matches) {
      final String tag = match.group(1) ?? match.group(3) ?? match.group(5)!;
      final String id = match.group(2) ?? match.group(4) ?? match.group(6)!;
      text = text.replaceAll('<<$tag|route://member/$id>>', '@$tag~');
      userTags.add(UserTag(userUniqueId: id, name: tag));
    }
    return {'text': text, 'userTags': userTags};
  }

  static List<UserTag> addUserTagsIfMatched(String input) {
    final Iterable<RegExpMatch> matches = routeRegExp.allMatches(input);
    List<UserTag> userTags = [];
    for (final match in matches) {
      final String tag = match.group(1) ?? match.group(3) ?? match.group(5)!;
      final String id = match.group(2) ?? match.group(4) ?? match.group(6)!;
      userTags.add(UserTag(userUniqueId: id, name: tag));
    }
    return userTags;
  }

  static String extractHeaderText(String input) {
    final RegExp headerRegex =
        RegExp(r'<<([\w\s#]+)\|.*>>\s*([\w\s]+)\s*<<([\w\s#]+)\|.*>>');
    final RegExpMatch? match = headerRegex.firstMatch(input);

    final String? userName = match?.group(1);
    final String? actionText = match?.group(2);
    final String? communityName = match?.group(3);
    return '$userName $actionText $communityName';
  }

  static String extractLeftChatroom(String input) {
    final RegExp leftChatroom =
        RegExp(r"<<([\w\s]+)\supdated\|.*>>\s*([\w\s]+)");
    final RegExpMatch? match = leftChatroom.firstMatch(input);

    final String? userName = match?.group(1);
    final String? actionText = match?.group(2);
    return '$userName $actionText';
  }

  static String extractTopicChat(String input) {
    final RegExp leftChatroom = RegExp(r"<<([\w\s]+)\|.*>>\s*(.+)");
    final RegExpMatch? match = leftChatroom.firstMatch(input);

    final String? userName = match?.group(1);
    final String? actionText = match?.group(2);
    return '$userName $actionText';
  }
}

List<String> extractLinkFromString(String text) {
  RegExp exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
  Iterable<RegExpMatch> matches = exp.allMatches(text);
  List<String> links = [];
  matches.forEach((match) {
    String link = text.substring(match.start, match.end);
    if (link.isNotEmpty) {
      links.add(link);
    }
  });
  if (links.isNotEmpty) {
    return links;
  } else {
    return [];
  }
}

String getFirstValidLinkFromString(String text) {
  try {
    List<String> links = extractLinkFromString(text);
    List<String> validLinks = [];
    String validLink = '';
    if (links.isNotEmpty) {
      for (String link in links) {
        if (Uri.parse(link).isAbsolute) {
          validLinks.add(link);
        } else {
          link = "https://$link";
          if (Uri.parse(link).isAbsolute) {
            validLinks.add(link);
          }
        }
      }
    }
    if (validLinks.isNotEmpty) {
      validLink = validLinks.first;
    }
    return validLink;
  } catch (e) {
    return '';
  }
}
