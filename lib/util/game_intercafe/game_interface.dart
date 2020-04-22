import 'dart:ui';

import 'package:bonfire/util/game_component.dart';
import 'package:bonfire/util/game_intercafe/component_interface.dart';
import 'package:flutter/widgets.dart';

class GameInterface extends GameComponent {
  List<ComponentInterface> _components = List();

  @override
  bool isTouchable = true;

  @override
  int priority() => 20;

  @override
  void render(Canvas c) {
    _components.forEach((i) => i.render(c));
  }

  @override
  void update(double t) {}
}
