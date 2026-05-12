// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision_api.dart';

export 'body_type.dart';
export 'collision_data.dart';

/// Mixin responsible for adding stop the movement when happen collision
mixin WithCollision on Movement {
  late final CollisionApi collision = CollisionApi(this);
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    collision.onCollision(intersectionPoints, other);
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onRemove() {
    collision.dispose();
    super.onRemove();
  }
}
