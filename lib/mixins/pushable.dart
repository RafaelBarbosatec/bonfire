import 'package:bonfire/bonfire.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 23/12/21

/// This mixin give to the component the pushable behavior.
/// To use this mixin the Component must have a `Movement` mixin.
mixin Pushable on Movement {
  bool enablePushable = true;

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (enablePushable && other is! Sensor) {
      if (other is GameComponent) {
        GameComponent component = other;
        if (component is Movement && onPush(component)) {
          Vector2 displacement = absoluteCenter - component.absoluteCenter;
          if (displacement.x.abs() > displacement.y.abs()) {
            if (displacement.x < 0) {
              if (this is HandleForces) {
                moveLeft(speed: component.speed / (this as HandleForces).mass);
              } else {
                moveLeftOnce();
              }
            } else {
              if (this is HandleForces) {
                moveRight(speed: component.speed / (this as HandleForces).mass);
              } else {
                moveRightOnce();
              }
            }
          } else {
            if (displacement.y < 0) {
              if (this is HandleForces) {
                moveUp(speed: component.speed / (this as HandleForces).mass);
              } else {
                moveUpOnce();
              }
            } else {
              if (this is HandleForces) {
                moveDown(speed: component.speed / (this as HandleForces).mass);
              } else {
                moveDownOnce();
              }
            }
          }
        }
      }
    }
  }

  /// Returning true if the component is pushable, false otherwise.
  bool onPush(GameComponent component) {
    return true;
  }
}
