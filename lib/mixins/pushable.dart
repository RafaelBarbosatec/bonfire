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
mixin Pushable on ObjectCollision {
  bool enablePushable = true;

  @override
  bool onCollision(GameComponent component, bool active) {
    if (enablePushable) {
      if (this is Movement) {
        if (!active && component is Movement) {
          if (!onPush(component)) {
            return super.onCollision(component, active);
          }
          Vector2 displacement = center - component.center;
          if (displacement.x.abs() > displacement.y.abs()) {
            if (displacement.x < 0) {
              (this as Movement).moveLeft((this as Movement).speed);
            } else {
              (this as Movement).moveRight((this as Movement).speed);
            }
          } else {
            if (displacement.y < 0) {
              (this as Movement).moveUp((this as Movement).speed);
            } else {
              (this as Movement).moveDown((this as Movement).speed);
            }
          }
        }
      } else {
        // ignore: avoid_print
        print(
            'The mixin Pushable not working in ($this) because this component don`t have the `Movement` mixin');
      }
    }
    return super.onCollision(component, active);
  }

  /// Returning true if the component is pushable, false otherwise.
  bool onPush(GameComponent component) {
    return true;
  }
}
