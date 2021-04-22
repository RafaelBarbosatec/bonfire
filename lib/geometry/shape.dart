import 'dart:ui';

import 'package:bonfire/geometry/shape_collision.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

abstract class Shape {
  Vector2 _position;

  Shape(Vector2 position) : _position = position;

  // ignore: unnecessary_getters_setters
  set position(Vector2 value) {
    _position = value;
  }

  // ignore: unnecessary_getters_setters
  Vector2 get position => _position;

  void render(Canvas canvas, Paint paint);

  bool isCollision(Shape b) {
    return ShapeCollision.isCollision(this, b);
  }
}
