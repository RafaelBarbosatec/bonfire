import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/collision/object_collision.dart';

mixin Sensor {
  void onContact(ObjectCollision collision);
  Rect _areaSensor;

  Rect get areaSensor {
    if (_areaSensor != null) {
      return _areaSensor;
    } else {
      if (this is GameComponent) {
        if (this is ObjectCollision &&
            (this as ObjectCollision).collisions != null) {
          return (this as ObjectCollision)
              .getRectCollision((this as GameComponent).position);
        } else {
          return (this as GameComponent).position;
        }
      }
      return Rect.zero;
    }
  }

  set areaSensor(Rect s) => _areaSensor = s;
}
