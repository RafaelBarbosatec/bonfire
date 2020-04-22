import 'package:bonfire/util/game_component.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

class ComponentInterface extends GameComponent {
  final int id;
  final Sprite sprite;
  final Sprite spriteSelected;
  final VoidCallback onTapComponent;
  final double width;
  final double height;
  int _pointer;
  Sprite _spriteRender;

  ComponentInterface({
    @required this.id,
    @required Position position,
    @required this.width,
    @required this.height,
    @required this.sprite,
    this.spriteSelected,
    this.onTapComponent,
  }) {
    this.position = Rect.fromLTWH(position.x, position.y, width, height);
    _spriteRender = sprite;
  }

  void render(Canvas canvas) {
    if (_spriteRender != null &&
        this.position != null &&
        _spriteRender.loaded()) _spriteRender.renderRect(canvas, this.position);
  }

  @override
  void onTapDown(int pointer, Offset position) {
    if (this.position.contains(position)) {
      _pointer = pointer;
      if (spriteSelected != null) _spriteRender = spriteSelected;
    }
    super.onTapDown(pointer, position);
  }

  @override
  void onTapUp(int pointer, Offset position) {
    if (pointer == _pointer) {
      _pointer = -1;
      _spriteRender = sprite;
    }
    super.onTapUp(pointer, position);
  }

  @override
  void onTap() {
    if (onTapComponent != null) onTapComponent();
    super.onTap();
  }

  @override
  void update(double t) {}
}
