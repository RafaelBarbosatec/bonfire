// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';

enum PersonSayDirection { LEFT, RIGHT }

class Say {
  /// List of TextSpans to be shown in a TalkDialog.
  /// Example:
  /// ```dart
  /// [
  ///   TextSpan(text: 'New'),
  ///   TextSpan(text: ' item ', style: TextStyle(color: Colors.red)),
  ///   TextSpan(text: 'unlocked!'),
  /// ]
  /// ```
  final List<TextSpan> text;
  final Widget? person;
  final PersonSayDirection personSayDirection;
  final BoxDecoration? boxDecoration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? background;
  final Widget? header;
  final Widget? bottom;

  /// How long each character takes to be shown, in milliseconds.
  /// Defaults to 50.
  final int? speed;

  /// Create a text animation to be shown inside `TalkDialog.show`
  Say({
    required this.text,
    this.personSayDirection = PersonSayDirection.LEFT,
    this.boxDecoration,
    this.padding,
    this.margin,
    this.person,
    this.background,
    this.header,
    this.bottom,
    this.speed,
  });
}
