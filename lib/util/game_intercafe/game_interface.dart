import 'dart:ui';

import 'package:bonfire/util/game_component.dart';
import 'package:bonfire/util/game_intercafe/interface_component.dart';
import 'package:flutter/widgets.dart';

class GameInterface extends GameComponent {
  List<InterfaceComponent> _components = List();

  @override
  bool isHud() => true;

  @override
  bool isTouchable = true;

  @override
  int priority() => 20;

  @override
  void render(Canvas c) {
    _components.forEach((i) => i.render(c));
  }

  @override
  void update(double t) {
    _components.forEach((i) {
      i.gameRef = gameRef;
      i.update(t);
    });
  }

  void add(InterfaceComponent component) {
    removeById(component.id);
    _components.add(component);
  }

  void removeById(int id) {
    if (_components.isEmpty) return;
    _components.removeWhere((i) => i.id == id);
  }

  @override
  void handlerTabDown(int pointer, Offset position) {
    _components.forEach((i) => i.handlerTabDown(pointer, position));
    super.handlerTabDown(pointer, position);
  }

  @override
  void handlerTabUp(int pointer, Offset position) {
    _components.forEach((i) => i.handlerTabUp(pointer, position));
    super.handlerTabUp(pointer, position);
  }
}
