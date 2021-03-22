import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/collision/object_collision.dart';

mixin Sensor on GameComponent {
  void onContact(ObjectCollision collision);
  Rect _areaSensor;

  Rect get areaSensor {
    if (_areaSensor != null) {
      return _areaSensor;
    } else {
      if (this is ObjectCollision) {
        return (this as ObjectCollision).getRectCollision(this.position.rect);
      } else {
        return this.position.rect;
      }
    }
  }

  set areaSensor(Rect s) => _areaSensor = s;
}
