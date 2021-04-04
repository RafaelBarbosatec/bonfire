import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class JoystickDirectional {
  final double size;
  final bool isFixed;
  final EdgeInsets margin;
  final Color color;

  Paint? _paintBackground;
  Paint? _paintKnob;

  Vector2Rect? _backgroundRect;
  Sprite? _backgroundSprite;

  Vector2Rect? _knobRect;
  Sprite? _knobSprite;

  bool _dragging = false;

  Offset? _dragPosition;

  late double _tileSize;

  int _pointerDragging = 0;

  JoystickController? _joystickController;

  Vector2? _screenSize;

  final _loader = AssetsLoader();

  JoystickDirectional({
    Future<Sprite>? spriteBackgroundDirectional,
    Future<Sprite>? spriteKnobDirectional,
    this.isFixed = true,
    this.margin = const EdgeInsets.only(left: 100, bottom: 100),
    this.size = 80,
    this.color = Colors.blueGrey,
  }) {
    _loader.add(AssetToLoad(spriteBackgroundDirectional, (value) {
      _backgroundSprite = value;
    }));

    _loader.add(AssetToLoad(spriteKnobDirectional, (value) {
      _knobSprite = value;
    }));

    _tileSize = size / 2;
  }

  void initialize(Vector2 _screenSize, JoystickController joystickController) {
    this._screenSize = _screenSize;
    _joystickController = joystickController;
    Offset osBackground = Offset(
      margin.left,
      _screenSize.y - margin.bottom,
    );
    _backgroundRect = Rect.fromCircle(
      center: osBackground,
      radius: size / 2,
    ).toVector2Rect();

    Offset osKnob = Offset(
      _backgroundRect!.center.dx,
      _backgroundRect!.center.dy,
    );

    _knobRect = Rect.fromCircle(
      center: osKnob,
      radius: size / 4,
    ).toVector2Rect();

    _dragPosition = _knobRect!.center;
  }

  void render(Canvas canvas) {
    _backgroundRect?.let((background) {
      if (_backgroundSprite != null) {
        _backgroundSprite?.renderFromVector2Rect(
          canvas,
          background,
        );
      } else {
        _paintBackground?.let((paintBg) {
          double radiusBackground = background.rect.width / 2;
          canvas.drawCircle(
            Offset(background.rect.left + radiusBackground,
                background.rect.top + radiusBackground),
            radiusBackground,
            paintBg,
          );
        });
      }
    });

    _knobRect?.let((knobRect) {
      if (_knobSprite != null) {
        _knobSprite?.renderFromVector2Rect(canvas, knobRect);
      } else {
        _paintKnob?.let((paintKnob) {
          double radiusKnob = knobRect.rect.width / 2;
          canvas.drawCircle(
            Offset(knobRect.rect.left + radiusKnob,
                knobRect.rect.top + radiusKnob),
            radiusKnob,
            paintKnob,
          );
        });
      }
    });
  }

  void update(double t) {
    if (_dragPosition == null || _backgroundRect == null || _knobRect == null)
      return;

    if (_dragging) {
      double _radAngle = atan2(
        _dragPosition!.dy - _backgroundRect!.center.dy,
        _dragPosition!.dx - _backgroundRect!.center.dx,
      );

      double degrees = _radAngle * 180 / pi;

      // Distance between the center of joystick background & drag position
      Vector2 centerPosition = _backgroundRect!.center.toVector2();
      Vector2 dragPosition = _dragPosition!.toVector2();
      double dist = centerPosition.distanceTo(dragPosition);

      // The maximum distance for the knob position the edge of
      // the background + half of its own size. The knob can wander in the
      // background image, but not outside.
      dist = min(dist, _tileSize);

      // Calculation the knob position
      double nextX = dist * cos(_radAngle);
      double nextY = dist * sin(_radAngle);
      Offset nextPoint = Offset(nextX, nextY);

      Offset diff = Offset(
            _backgroundRect!.center.dx + nextPoint.dx,
            _backgroundRect!.center.dy + nextPoint.dy,
          ) -
          _knobRect!.center;
      _knobRect = _knobRect!.shift(diff);

      double _intensity = dist / _tileSize;

      if (_intensity == 0) {
        _joystickController?.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.IDLE,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
        return;
      }

      if (degrees > -22.5 && degrees <= 22.5) {
        _joystickController?.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_RIGHT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > 22.5 && degrees <= 67.5) {
        _joystickController?.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_DOWN_RIGHT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > 67.5 && degrees <= 112.5) {
        _joystickController?.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_DOWN,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > 112.5 && degrees <= 157.5) {
        _joystickController?.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_DOWN_LEFT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if ((degrees > 157.5 && degrees <= 180) ||
          (degrees >= -180 && degrees <= -157.5)) {
        _joystickController?.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_LEFT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > -157.5 && degrees <= -112.5) {
        _joystickController?.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_UP_LEFT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > -112.5 && degrees <= -67.5) {
        _joystickController?.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_UP,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > -67.5 && degrees <= -22.5) {
        _joystickController?.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_UP_RIGHT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }
    } else {
      if (_knobRect != null) {
        Offset diff = _dragPosition! - _knobRect!.center;
        _knobRect = _knobRect!.shift(diff);
      }
    }
  }

  void directionalDown(int pointer, Offset localPosition) {
    if (_backgroundRect == null) return;

    _updateDirectionalRect(localPosition);

    _backgroundRect?.let((backgroundRect) {
      Rect directional = Rect.fromLTWH(
        backgroundRect.rect.left - 50,
        backgroundRect.rect.top - 50,
        backgroundRect.rect.width + 100,
        backgroundRect.rect.height + 100,
      );
      if (!_dragging && directional.contains(localPosition)) {
        _dragging = true;
        _dragPosition = localPosition;
        _pointerDragging = pointer;
      }
    });
  }

  void directionalMove(int pointer, Offset localPosition) {
    if (pointer == _pointerDragging) {
      if (_dragging) {
        _dragPosition = localPosition;
      }
    }
  }

  void directionalUp(int pointer) {
    if (pointer == _pointerDragging) {
      _dragging = false;
      _dragPosition = _backgroundRect?.center;
      _joystickController?.joystickChangeDirectional(
        JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.IDLE,
          intensity: 0.0,
          radAngle: 0.0,
        ),
      );
    }
  }

  void _updateDirectionalRect(Offset position) {
    if (_screenSize != null &&
        (position.dx > _screenSize!.x / 3 ||
            position.dy < _screenSize!.y / 3 ||
            isFixed)) return;

    _backgroundRect = Rect.fromCircle(
      center: position,
      radius: size / 2,
    ).toVector2Rect();

    Offset osKnob = Offset(
      _backgroundRect!.center.dx,
      _backgroundRect!.center.dy,
    );
    _knobRect = Rect.fromCircle(
      center: osKnob,
      radius: size / 4,
    ).toVector2Rect();
  }

  Future<void> onLoad() async {
    await _loader.load();
    if (_backgroundSprite == null) {
      _paintBackground = Paint()
        ..color = color.withOpacity(0.5)
        ..style = PaintingStyle.fill;
    }

    if (_paintKnob == null) {
      _paintKnob = Paint()
        ..color = color.withOpacity(0.8)
        ..style = PaintingStyle.fill;
    }
  }
}
