import 'package:flame/extensions.dart';

abstract class Shape {
  Vector2 _position;

  Shape(Vector2 position) : _position = position;

  // ignore: unnecessary_getters_setters
  set position(Vector2 value) {
    _position = value;
  }

  // ignore: unnecessary_getters_setters
  Vector2 get position => _position;
}
