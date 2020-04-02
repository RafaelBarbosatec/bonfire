import 'package:flutter/material.dart';

enum PersonDirection { LEFT, RIGHT }

class Say {
  final String text;
  final Widget person;
  final PersonDirection personDirection;
  Say(this.text, this.person, {this.personDirection = PersonDirection.LEFT});
}
