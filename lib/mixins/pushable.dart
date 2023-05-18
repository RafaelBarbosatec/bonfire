import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/movement_v2.dart';

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
mixin Pushable on MovementV2 {
  bool enablePushable = true;

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (enablePushable) {
      if (other is GameComponent) {
        GameComponent component = other;
        if (component is MovementV2) {
          if (!onPush(component)) {
            return;
          }
          Vector2 displacement = center - component.center;
          if (displacement.x.abs() > displacement.y.abs()) {
            if (displacement.x < 0) {
              moveLeftOneShot(speed);
            } else {
              moveRightOneShot(speed);
            }
          } else {
            if (displacement.y < 0) {
              moveUpOneShot(speed);
            } else {
              moveDownOneShot(speed);
            }
          }
        }
      } else {
        // ignore: avoid_print
        print(
            'The mixin Pushable not working in ($this) because this component don`t have the `Movement` mixin');
      }
    }
  }

  /// Returning true if the component is pushable, false otherwise.
  bool onPush(GameComponent component) {
    return true;
  }
}
