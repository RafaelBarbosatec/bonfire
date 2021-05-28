import 'package:flutter/material.dart';

enum PersonSayDirection { LEFT, RIGHT }

class Say {
  final String text;
  final Widget? person;
  final PersonSayDirection personSayDirection;
  final TextStyle? textStyle;
  final BoxDecoration? boxDecoration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? background;
  final Widget? header;
  final Widget? bottom;

  Say(
    this.text, {
    this.personSayDirection = PersonSayDirection.LEFT,
    this.textStyle,
    this.boxDecoration,
    this.padding,
    this.margin,
    this.person,
    this.background,
    this.header,
    this.bottom,
  });
}
