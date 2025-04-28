import 'package:flutter/material.dart';

class Style {
  // Colors
  static const Color orange = Colors.orange;
  static const Color secondaryColor = Colors.orangeAccent;
  static const Color textColor = Colors.orange;
  static Color cardColorOrange = Colors.orange[100]!;
  static const Color dividerColor = Colors.grey;
  // TODO: change card text size
  static const double cardTextSize = 18;
  static const double cardSubTextSize = 14;

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerLow;
  }

  // Text Styles
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: orange,
  );

  static const TextStyle subtitleTextStyle = TextStyle(
    fontSize: 18,
    fontStyle: FontStyle.italic,
    color: orange,
  );

  static const TextStyle cardTextStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: cardTextSize,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
