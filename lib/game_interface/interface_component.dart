import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/gestures/tap_gesture.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

class InterfaceComponent extends GameComponent with TapGesture {
  final int id;
  Sprite sprite;
  Sprite spriteSelected;
  final VoidCallback onTapComponent;
  final double width;
  final double height;
  Sprite spriteToRender;

  @override
  bool get isHud => true;

  InterfaceComponent({
    @required this.id,
    @required Vector2 position,
    @required this.width,
    @required this.height,
    Future<Sprite> sprite,
    Future<Sprite> spriteSelected,
    this.onTapComponent,
  }) {
    sprite?.then((value) {
      this.sprite = value;
      spriteToRender = this.sprite;
    });
    spriteSelected?.then((value) {
      this.spriteSelected = value;
    });
    this.position = Vector2Rect.fromRect(
      Rect.fromLTWH(
        position.x,
        position.y,
        width,
        height,
      ),
    );
  }

  void render(Canvas canvas) {
    if (spriteToRender != null && this.position != null) {
      spriteToRender.renderFromVector2Rect(canvas, this.position);
    }
  }

  @override
  void handlerTapDown(int pointer, Offset position) {
    if (this.position.rect.contains(position)) {
      spriteToRender = spriteSelected ?? spriteToRender;
    }
    super.handlerTapDown(pointer, position);
  }

  @override
  void onTapCancel() {
    spriteToRender = sprite;
  }

  @override
  void onTap() {
    if (onTapComponent != null) onTapComponent();
    spriteToRender = sprite;
  }

  @override
  void update(double t) {}
}
