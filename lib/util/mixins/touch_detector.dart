import 'package:flame/components.dart';
import 'package:flutter/gestures.dart';

mixin TouchDetector {
  void onDragStart(int pointerId, Vector2 startPosition) {}
  void onDragUpdate(int pointerId, DragUpdateDetails details) {}
  void onDragEnd(int pointerId, DragEndDetails details) {}
  void onDragCancel(int pointerId) {}

  void onTap(int pointerId) {}
  void onTapCancel(int pointerId) {}
  void onTapDown(int pointerId, TapDownDetails details) {}
  void onTapUp(int pointerId, TapUpDetails details) {}
  void onLongTapDown(int pointerId, TapDownDetails details) {}
}
