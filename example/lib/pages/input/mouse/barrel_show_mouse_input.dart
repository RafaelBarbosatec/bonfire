import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:flutter/material.dart';

class BarrelShowMouseInput extends GameDecoration with MouseEventListener {
  late TextPaint _textPaint;
  final String base =
      'Mouse screen position: {screenPosition} \nMouse click in screen: {buttonScreenClicked} \nMouse click in barrel: {buttonCompClicked} \nMouse scroll middle in screen: {mouseScrollDelta}';
  String text = '';
  Vector2 mousePosition = Vector2.zero();
  Vector2 mouseScrollDelta = Vector2.zero();
  MouseButton? buttonScreenClicked;
  MouseButton? buttonCompClicked;
  BarrelShowMouseInput({required Vector2 position})
      : super.withSprite(
          sprite: CommonSpriteSheet.barrelSprite,
          position: position,
          size: Vector2.all(16),
        ) {
    _textPaint = TextPaint(
      style: TextStyle(
        fontSize: size.x / 4,
        color: Colors.white,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    _textPaint.render(canvas, text, Vector2(0, size.y));
    super.render(canvas);
  }

  @override
  void update(double dt) {
    text = base.replaceAll('{screenPosition}', mousePosition.toString());
    text = text.replaceAll(
        '{buttonScreenClicked}', buttonScreenClicked.toString());
    text = text.replaceAll('{buttonCompClicked}', buttonCompClicked.toString());
    text = text.replaceAll('{mouseScrollDelta}', mouseScrollDelta.toString());
    super.update(dt);
  }

  @override
  void onMouseTap(MouseButton button) {
    buttonCompClicked = button;
  }

  @override
  void onMouseScreenTapDown(int pointer, Vector2 position, MouseButton button) {
    buttonScreenClicked = button;
    super.onMouseScreenTapDown(pointer, position, button);
  }

  @override
  void onMouseHoverScreen(int pointer, Vector2 position) {
    mousePosition = position;
    super.onMouseHoverScreen(pointer, position);
  }

  @override
  void onMouseScrollScreen(int pointer, Vector2 position, Vector2 scrollDelta) {
    mouseScrollDelta = scrollDelta;
    super.onMouseScrollScreen(pointer, position, scrollDelta);
  }
}
