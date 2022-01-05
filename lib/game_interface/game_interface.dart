import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

/// The way you cand raw things like life bars, stamina and settings. In another words, anything that you may add to the interface to the game.
class GameInterface extends GameComponent {
  /// textConfig used to show FPS
  final textConfigGreen = TextPaint(
    style: TextStyle(color: Colors.green, fontSize: 14),
  );

  /// textConfig used to show FPS
  final textConfigYellow = TextPaint(
    style: TextStyle(color: Colors.yellow, fontSize: 14),
  );

  /// textConfig used to show FPS
  final textConfigRed = TextPaint(
    style: TextStyle(color: Colors.red, fontSize: 14),
  );

  @override
  PositionType get positionType => PositionType.viewport;

  @override
  int get priority {
    return LayerPriority.getInterfacePriority(gameRef.highestPriority);
  }

  @override
  void render(Canvas c) {
    super.render(c);
    _drawFPS(c);
  }

  /// Used to add components in your interface like a Button.
  Future<void> add(Component component) {
    if (component is InterfaceComponent) {
      removeById(component.id);
    }
    return super.add(component);
  }

  /// Used to remove component of the interface by id
  void removeById(int id) {
    if (children.isEmpty) return;

    children.removeWhere((element) {
      return element is InterfaceComponent && element.id == id;
    });
  }

  void _drawFPS(Canvas c) {
    if (gameRef.showFPS == true) {
      double? fps = (gameRef as BonfireGame).fps(100);
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
  bool hasGesture() => true;

  bool get receiveInteraction => children.where((element) {
        return element is InterfaceComponent && element.receiveInteraction;
      }).isNotEmpty;
}
