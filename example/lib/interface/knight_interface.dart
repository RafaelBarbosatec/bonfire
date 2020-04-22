import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:example/interface/bar_life_component.dart';
import 'package:flutter/material.dart';

class KnightInterface extends GameInterface {
  @override
  void resize(Size size) {
    add(BarLifeComponent());
    super.resize(size);
  }
}
