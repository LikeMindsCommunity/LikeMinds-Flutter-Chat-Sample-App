import 'package:flutter/material.dart';

import 'constants/ui_constants.dart';

//Generic method for getting height
double getHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

//Generic method for getting width
double getWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

//Utils method for getting initials of a name (or first letter of every word)
String getInitials(String? name) {
  if (name == null || name == "") {
    return "";
  }

  List<String> parts = name.split(' '); // Split on whitespace
  if (parts.last.characters.first == "(") {
    // Check if last part is a parantheses
    parts.remove(parts.last); // Remove parantheses
  }
  String initials = parts
      .map((e) => e.characters.first) // Get first char of each name
      .reduce((_, e) => _ + e) // Reduce into single string
      .toUpperCase(); // Capitalize
  return initials;
}

extension StringColor on String {
  Color? toColor() {
    // if (primaryColor != null) {
    if (int.tryParse(this) != null) {
      return Color(int.tryParse(this)!);
    } else {
      return kPrimaryColor;
    }
  }
}
