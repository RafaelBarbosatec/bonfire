import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/game_interface/interface_component.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// The way you cand raw things like life bars, stamina and settings. In another words, anything that you may add to the interface to the game.
class GameInterface extends GameComponent {
  List<InterfaceComponent> _components = [];

  /// textConfig used to show FPS
  final textConfigGreen = TextPaint(
    config: TextPaintConfig(color: Colors.green, fontSize: 14),
  );

  /// textConfig used to show FPS
  final textConfigYellow = TextPaint(
    config: TextPaintConfig(color: Colors.yellow, fontSize: 14),
  );

  /// textConfig used to show FPS
  final textConfigRed = TextPaint(
    config: TextPaintConfig(color: Colors.red, fontSize: 14),
  );

  @override
  bool get isHud => true;

  @override
  int get priority =>
      LayerPriority.getInterfacePriority(gameRef.highestPriority);

  @override
  void render(Canvas c) {
    _components.forEach((i) => i.render(c));
    _drawFPS(c);
  }

  @override
  void update(double t) {
    _components.forEach((i) {
      i.gameRef = gameRef;
      i.update(t);
    });
  }

  @override
  void onGameResize(Vector2 size) {
    _components.forEach((i) => i.onGameResize(size));
    super.onGameResize(size);
  }

  /// Used to add components in your interface like a Button.
  Future<void> add(InterfaceComponent component) async {
    removeById(component.id);
    await component.onLoad();
    _components.add(component);
  }

  /// Used to remove component of the interface by id
  void removeById(int id) {
    if (_components.isEmpty) return;
    _components.removeWhere((i) => i.id == id);
  }

  @override
  void handlerPointerDown(PointerDownEvent event) {
    _components.forEach((i) => i.handlerPointerDown(event));
  }

  @override
  void handlerPointerUp(PointerUpEvent event) {
    _components.forEach((i) => i.handlerPointerUp(event));
  }

  @override
  void handlerPointerCancel(PointerCancelEvent event) {
    _components.forEach((i) => i.handlerPointerCancel(event));
  }

  void _drawFPS(Canvas c) {
    if (gameRef.showFPS == true) {
      double? fps = gameRef.fps(100);
      getTextConfigFps(fps).render(
        c,
        'FPS: ${fps.toStringAsFixed(2)}',
        Vector2((gameRef.size.x) - 100, 20),
      );
    }
  }

  TextPaint getTextConfigFps(double fps) {
    if (fps >= 58) {
      return textConfigGreen;
    }

    if (fps >= 48) {
      return textConfigYellow;
    }

    return textConfigRed;
  }

  @override
  Future<void> onLoad() {
    return Future.forEach<InterfaceComponent>(_components, (element) {
      return element.onLoad();
    });
  }

  @override
  bool hasGesture() => true;

  bool get receiveInteraction =>
      _components.where((element) => element.receiveInteraction).isNotEmpty;
}
