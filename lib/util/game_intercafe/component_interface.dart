import 'package:bonfire/util/game_component.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

class ComponentInterface extends GameComponent {
  Rect _rect;
  final Sprite sprite;
  final Sprite spriteSelected;
  final VoidCallback onTapComponent;
  final double width;
  final double height;
  int _pointer;
  Sprite _spriteRender;

  ComponentInterface({
    Position position,
    this.width,
    this.height,
    this.sprite,
    this.spriteSelected,
    this.onTapComponent,
  }) {
    _rect = Rect.fromLTWH(position.x, position.y, width, height);
    _spriteRender = sprite;
  }

  void render(Canvas canvas) {
    if (_spriteRender != null && _rect != null && _spriteRender.loaded())
      _spriteRender.renderRect(canvas, _rect);
  }

  @override
  void onTapDown(int pointer, Offset position) {
    if (_rect.contains(position)) {
      _pointer = pointer;
      _spriteRender = spriteSelected;
    }
    super.handlerTabDown(pointer, position);
  }

  @override
  void onTapUp(int pointer, Offset position) {
    if (pointer == _pointer) {
      _pointer = -1;
      _spriteRender = sprite;
    }
    super.handlerTabDown(pointer, position);
  }

  @override
  void onTap() {
    if (onTapComponent != null) onTapComponent();
    super.onTap();
  }

  @override
  void update(double t) {}
}
