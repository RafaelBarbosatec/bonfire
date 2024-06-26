import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flame/camera.dart' as camera;
import 'package:flutter/material.dart';

class JoystickAction {
  final dynamic actionId;

  // strongly typed joystic/keyboard key
  // Source is [`KeyEvent`.logicalKey.keyId]
  // example: LogicalKeyboardKey.keyZ.keyId or your own keyId
  final int logicalKeyboardKey;

  Sprite? sprite;
  Sprite? spritePressed;
  Sprite? spriteBackgroundDirection;
  final double sizeFactorBackgroundDirection;
  final double size;
  final EdgeInsets margin;
  final bool enableDirection;
  final Color color;
  final double opacityBackground;
  final double opacityKnob;
  final Alignment alignment;

  late double _sizeBackgroundDirection;
  late double _tileSize;

  int? _pointer;
  Rect? _rect;
  Rect? _rectBackgroundDirection;
  bool _dragging = false;
  Sprite? _spriteToRender;
  Offset? _dragPosition;
  Paint? _paintBackground;
  Paint? _paintAction;
  Paint? _paintActionPressed;
  late PlayerControllerListener _controller;
  Vector2 _screenSize = Vector2.zero();
  late camera.Viewport _viewport;
  bool isPressed = false;

  AssetsLoader? _loader = AssetsLoader();

  JoystickAction({
    required this.actionId,
    this.logicalKeyboardKey = -1, // -1 for unused
    Future<Sprite>? sprite,
    Future<Sprite>? spritePressed,
    Future<Sprite>? spriteBackgroundDirection,
    this.enableDirection = false,
    this.size = 50,
    this.sizeFactorBackgroundDirection = 1.5,
    this.margin = const EdgeInsets.all(50),
    this.color = Colors.blueGrey,
    this.alignment = Alignment.bottomRight,
    this.opacityBackground = 0.5,
    this.opacityKnob = 0.8,
  }) {
    _loader?.add(AssetToLoad(sprite, (value) {
      this.sprite = value;
    }));
    _loader?.add(AssetToLoad(spritePressed, (value) {
      this.spritePressed = value;
    }));
    _loader?.add(AssetToLoad(spriteBackgroundDirection, (value) {
      this.spriteBackgroundDirection = value;
    }));
    _sizeBackgroundDirection = sizeFactorBackgroundDirection * size;
    _tileSize = _sizeBackgroundDirection / 2;
  }

  Offset getViewportPosition(Offset position) {
    return _viewport.globalToLocal(position.toVector2()).toOffset();
  }

  void initialize(
    PlayerControllerListener controller,
    camera.Viewport viewport,
  ) {
    if (_screenSize == viewport.virtualSize) return;
    _viewport = viewport;
    _screenSize = viewport.virtualSize.clone();
    _controller = controller;
    double radius = size / 2;
    final screenRect = Rect.fromLTRB(
      margin.left + radius,
      margin.top + radius,
      _screenSize.x - margin.right - radius,
      _screenSize.y - margin.bottom - radius,
    );

    Offset osBackground = alignment.withinRect(screenRect);
    _rect = Rect.fromCircle(
      center: osBackground,
      radius: radius,
    );

    _rectBackgroundDirection = Rect.fromCircle(
      center: osBackground,
      radius: _sizeBackgroundDirection / 2,
    );

    _dragPosition = _rect!.center;
  }

  void render(Canvas c) {
    if (_rectBackgroundDirection != null && _dragging && enableDirection) {
      if (spriteBackgroundDirection == null) {
        _paintBackground?.let((paintBackground) {
          double radiusBackground = _rectBackgroundDirection!.width / 2;
          c.drawCircle(
            Offset(
              _rectBackgroundDirection!.left + radiusBackground,
              _rectBackgroundDirection!.top + radiusBackground,
            ),
            radiusBackground,
            paintBackground,
          );
        });
      } else {
        spriteBackgroundDirection?.renderRect(
          c,
          _rectBackgroundDirection!,
        );
      }
    }

    _rect?.let((rect) {
      if (_spriteToRender != null) {
        _spriteToRender?.renderRect(
          c,
          rect,
        );
      } else {
        double radiusAction = rect.width / 2;
        c.drawCircle(
          Offset(
            rect.left + radiusAction,
            rect.top + radiusAction,
          ),
          radiusAction,
          (isPressed ? _paintActionPressed : _paintAction) ?? Paint(),
        );
      }
    });
  }

  void update(double dt) {
    if (_dragPosition == null ||
        _rectBackgroundDirection == null ||
        _rect == null) return;
    if (_dragging) {
      double radAngle = atan2(
        _dragPosition!.dy - _rectBackgroundDirection!.center.dy,
        _dragPosition!.dx - _rectBackgroundDirection!.center.dx,
      );

      // Distance between the center of joystick background & drag position
      Vector2 centerPosition = _rectBackgroundDirection!.center.toVector2();
      Vector2 dragPosition = _dragPosition!.toVector2();
      double dist = centerPosition.distanceTo(dragPosition);

      // The maximum distance for the knob position the edge of
      // the background + half of its own size. The knob can wander in the
      // background image, but not outside.
      dist = min(dist, _tileSize);

      // Calculation the knob position
      double nextX = dist * cos(radAngle);
      double nextY = dist * sin(radAngle);
      Offset nextPoint = Offset(nextX, nextY);

      Offset diff = Offset(
            _rectBackgroundDirection!.center.dx + nextPoint.dx,
            _rectBackgroundDirection!.center.dy + nextPoint.dy,
          ) -
          _rect!.center;
      _rect = _rect!.shift(diff);

      double intensity = dist / _tileSize;

      _controller.onJoystickAction(
        JoystickActionEvent(
          id: actionId,
          event: ActionEvent.MOVE,
          intensity: intensity,
          radAngle: radAngle,
          logicalKeyboardKey: logicalKeyboardKey,
        ),
      );
    } else {
      Offset diff = _dragPosition! - _rect!.center;
      _rect = _rect!.shift(diff);
    }
  }

  void actionDown(int pointer, Offset localPosition) {
    final pos = getViewportPosition(localPosition);
    if (!_dragging && _rect != null && _rect!.contains(pos)) {
      _pointer = pointer;
      if (enableDirection) {
        _dragPosition = pos;
        _dragging = true;
      }
      _controller.onJoystickAction(
        JoystickActionEvent(
          id: actionId,
          event: ActionEvent.DOWN,
          logicalKeyboardKey: logicalKeyboardKey,
        ),
      );
      pressed();
    }
  }

  void actionMove(int pointer, Offset localPosition) {
    if (pointer == _pointer) {
      if (_dragging) {
        _dragPosition = getViewportPosition(localPosition);
      }
    }
  }

  void actionUp(int pointer) {
    if (pointer == _pointer) {
      _dragging = false;

      _rectBackgroundDirection?.let((rectBackgroundDirection) {
        _dragPosition = rectBackgroundDirection.center;
      });

      _controller.onJoystickAction(
        JoystickActionEvent(
          id: actionId,
          event: ActionEvent.UP,
          logicalKeyboardKey: logicalKeyboardKey,
        ),
      );
      unPressed();
    }
  }

  void pressed() {
    isPressed = true;
    if (spritePressed != null) {
      _spriteToRender = spritePressed;
    }
  }

  void unPressed() {
    isPressed = false;
    _spriteToRender = sprite;
  }

  Future<void> onLoad() async {
    await _loader?.load();

    _spriteToRender = sprite;

    if (spriteBackgroundDirection == null) {
      _paintBackground = Paint()
        ..color = color.withOpacity(opacityBackground)
        ..style = PaintingStyle.fill;
    }

    if (sprite == null) {
      _paintAction = Paint()
        ..color = color.withOpacity(opacityKnob)
        ..style = PaintingStyle.fill;
    }

    if (spritePressed == null) {
      _paintActionPressed = Paint()
        ..color = color.withOpacity(opacityBackground)
        ..style = PaintingStyle.fill;
    }

    _loader = null;
  }
}
