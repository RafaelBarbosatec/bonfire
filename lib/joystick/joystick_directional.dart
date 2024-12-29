import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/extensions/color_extensions.dart';
import 'package:flame/camera.dart' as camera;
import 'package:flutter/material.dart';

class JoystickDirectional {
  final double size;
  final bool isFixed;
  final EdgeInsets margin;
  final Color color;

  Paint? _paintBackground;
  Paint? _paintKnob;

  Rect? _backgroundRect;
  Sprite? _backgroundSprite;

  Rect? _knobRect;
  Sprite? _knobSprite;

  bool _dragging = false;

  Offset? _dragPosition;

  late double _tileSize;

  int _pointerDragging = 0;

  late PlayerControllerListener _controller;

  late camera.Viewport _viewPort;

  Vector2 _screenSize = Vector2.zero();

  AssetsLoader? _loader = AssetsLoader();

  /// Use to enable diagonal input events
  final bool enableDiagonalInput;
  final Alignment alignment;

  JoystickDirectional({
    Future<Sprite>? spriteBackgroundDirectional,
    Future<Sprite>? spriteKnobDirectional,
    this.isFixed = true,
    this.margin = const EdgeInsets.all(100),
    this.alignment = Alignment.bottomLeft,
    this.size = 80,
    this.color = Colors.blueGrey,
    this.enableDiagonalInput = true,
  }) {
    _loader?.add(
      AssetToLoad<Sprite>(spriteBackgroundDirectional, (value) {
        _backgroundSprite = value;
      }),
    );

    _loader?.add(
      AssetToLoad<Sprite>(spriteKnobDirectional, (value) {
        _knobSprite = value;
      }),
    );

    _tileSize = size / 2;
  }

  Offset getViewportPosition(Offset position) {
    return _viewPort.globalToLocal(position.toVector2()).toOffset();
  }

  void initialize(
    PlayerControllerListener controller,
    camera.Viewport viewPort,
  ) {
    if (_screenSize == viewPort.virtualSize) {
      return;
    }
    _viewPort = viewPort;
    _screenSize = viewPort.virtualSize.clone();
    _controller = controller;
    final radius = size / 2;

    final screenRect = Rect.fromLTRB(
      margin.left + radius,
      margin.top + radius,
      _screenSize.x - margin.right - radius,
      _screenSize.y - margin.bottom - radius,
    );

    final osBackground = alignment.withinRect(screenRect);

    _backgroundRect = Rect.fromCircle(
      center: osBackground,
      radius: radius,
    );

    final osKnob = Offset(
      _backgroundRect!.center.dx,
      _backgroundRect!.center.dy,
    );

    _knobRect = Rect.fromCircle(
      center: osKnob,
      radius: size / 4,
    );

    _dragPosition = _knobRect!.center;
  }

  void render(Canvas canvas) {
    _backgroundRect?.let((background) {
      if (_backgroundSprite != null) {
        _backgroundSprite?.renderRect(
          canvas,
          background,
        );
      } else {
        _paintBackground?.let((paintBg) {
          final radiusBackground = background.width / 2;
          canvas.drawCircle(
            Offset(
              background.left + radiusBackground,
              background.top + radiusBackground,
            ),
            radiusBackground,
            paintBg,
          );
        });
      }
    });

    _knobRect?.let((knobRect) {
      if (_knobSprite != null) {
        _knobSprite?.renderRect(canvas, knobRect);
      } else {
        _paintKnob?.let((paintKnob) {
          final radiusKnob = knobRect.width / 2;
          canvas.drawCircle(
            Offset(
              knobRect.left + radiusKnob,
              knobRect.top + radiusKnob,
            ),
            radiusKnob,
            paintKnob,
          );
        });
      }
    });
  }

  void update(double dt) {
    if (_dragPosition == null || _backgroundRect == null || _knobRect == null) {
      return;
    }

    if (_dragging) {
      final radAngle = atan2(
        _dragPosition!.dy - _backgroundRect!.center.dy,
        _dragPosition!.dx - _backgroundRect!.center.dx,
      );

      final degrees = radAngle * 180 / pi;

      // Distance between the center of joystick background & drag position
      final centerPosition = _backgroundRect!.center.toVector2();
      final dragPosition = _dragPosition!.toVector2();
      var dist = centerPosition.distanceTo(dragPosition);

      // The maximum distance for the knob position the edge of
      // the background + half of its own size. The knob can wander in the
      // background image, but not outside.
      dist = min(dist, _tileSize);

      // Calculation the knob position
      final nextX = dist * cos(radAngle);
      final nextY = dist * sin(radAngle);
      final nextPoint = Offset(nextX, nextY);

      final diff = Offset(
            _backgroundRect!.center.dx + nextPoint.dx,
            _backgroundRect!.center.dy + nextPoint.dy,
          ) -
          _knobRect!.center;
      _knobRect = _knobRect!.shift(diff);

      final intensity = dist / _tileSize;

      if (intensity == 0) {
        _controller.onJoystickChangeDirectional(
          JoystickDirectionalEvent(
            directional: JoystickMoveDirectional.IDLE,
            intensity: intensity,
            radAngle: radAngle,
          ),
        );
        return;
      }

      if (degrees > -22.5 && degrees <= 22.5) {
        _controller.onJoystickChangeDirectional(
          JoystickDirectionalEvent(
            directional: JoystickMoveDirectional.MOVE_RIGHT,
            intensity: intensity,
            radAngle: radAngle,
          ),
        );
      }

      if (enableDiagonalInput && degrees > 22.5 && degrees <= 67.5) {
        _controller.onJoystickChangeDirectional(
          JoystickDirectionalEvent(
            directional: JoystickMoveDirectional.MOVE_DOWN_RIGHT,
            intensity: intensity,
            radAngle: radAngle,
          ),
        );
      }

      if (degrees > 67.5 && degrees <= 112.5) {
        _controller.onJoystickChangeDirectional(
          JoystickDirectionalEvent(
            directional: JoystickMoveDirectional.MOVE_DOWN,
            intensity: intensity,
            radAngle: radAngle,
          ),
        );
      }

      if (enableDiagonalInput && degrees > 112.5 && degrees <= 157.5) {
        _controller.onJoystickChangeDirectional(
          JoystickDirectionalEvent(
            directional: JoystickMoveDirectional.MOVE_DOWN_LEFT,
            intensity: intensity,
            radAngle: radAngle,
          ),
        );
      }

      if ((degrees > 157.5 && degrees <= 180) ||
          (degrees >= -180 && degrees <= -157.5)) {
        _controller.onJoystickChangeDirectional(
          JoystickDirectionalEvent(
            directional: JoystickMoveDirectional.MOVE_LEFT,
            intensity: intensity,
            radAngle: radAngle,
          ),
        );
      }

      if (enableDiagonalInput && degrees > -157.5 && degrees <= -112.5) {
        _controller.onJoystickChangeDirectional(
          JoystickDirectionalEvent(
            directional: JoystickMoveDirectional.MOVE_UP_LEFT,
            intensity: intensity,
            radAngle: radAngle,
          ),
        );
      }

      if (degrees > -112.5 && degrees <= -67.5) {
        _controller.onJoystickChangeDirectional(
          JoystickDirectionalEvent(
            directional: JoystickMoveDirectional.MOVE_UP,
            intensity: intensity,
            radAngle: radAngle,
          ),
        );
      }

      if (enableDiagonalInput && degrees > -67.5 && degrees <= -22.5) {
        _controller.onJoystickChangeDirectional(
          JoystickDirectionalEvent(
            directional: JoystickMoveDirectional.MOVE_UP_RIGHT,
            intensity: intensity,
            radAngle: radAngle,
          ),
        );
      }
    } else {
      if (_knobRect != null) {
        final diff = _dragPosition! - _knobRect!.center;
        _knobRect = _knobRect!.shift(diff);
      }
    }
  }

  void directionalDown(int pointer, Offset localPosition) {
    if (_backgroundRect == null) {
      return;
    }

    final pos = getViewportPosition(localPosition);

    _updateDirectionalRect(pos);

    _backgroundRect?.let((backgroundRect) {
      final directional = Rect.fromLTWH(
        backgroundRect.left - 50,
        backgroundRect.top - 50,
        backgroundRect.width + 100,
        backgroundRect.height + 100,
      );
      if (!_dragging && directional.contains(pos)) {
        _dragging = true;
        _dragPosition = pos;
        _pointerDragging = pointer;
      }
    });
  }

  void directionalMove(int pointer, Offset localPosition) {
    if (pointer == _pointerDragging) {
      if (_dragging) {
        _dragPosition = getViewportPosition(
          localPosition,
        );
      }
    }
  }

  void directionalUp(int pointer) {
    if (pointer == _pointerDragging) {
      _dragging = false;
      _dragPosition = _backgroundRect?.center;
      _controller.onJoystickChangeDirectional(
        JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.IDLE,
        ),
      );
    }
  }

  void _updateDirectionalRect(Offset position) {
    if (isFixed) {
      return;
    }
    if (alignment.x == -1) {
      if (position.dx > _screenSize.x * 0.33) {
        return;
      }
    }

    if (alignment.x == 1) {
      if (position.dx < _screenSize.x * 0.66) {
        return;
      }
    }

    _backgroundRect = Rect.fromCircle(
      center: position,
      radius: size / 2,
    );

    final osKnob = Offset(
      _backgroundRect!.center.dx,
      _backgroundRect!.center.dy,
    );
    _knobRect = Rect.fromCircle(
      center: osKnob,
      radius: size / 4,
    );
  }

  Future<void> onLoad() async {
    await _loader?.load();
    if (_backgroundSprite == null) {
      _paintBackground = Paint()
        ..color = color.setOpacity(0.5)
        ..style = PaintingStyle.fill;
    }

    _paintKnob ??= Paint()
      ..color = color.setOpacity(0.8)
      ..style = PaintingStyle.fill;

    _loader = null;
  }
}
