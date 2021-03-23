import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/vector2rect.dart';

mixin Sensor on GameComponent {
  void onContact(ObjectCollision collision);
  Vector2Rect _areaSensor;

  Vector2Rect get areaSensor {
    if (_areaSensor != null) {
      return _areaSensor;
    } else {
      if (this is ObjectCollision) {
        return (this as ObjectCollision).getRectCollision(this.position);
      } else {
        return this.position;
      }
    }
  }

  set areaSensor(Vector2Rect s) => _areaSensor = s;
}
