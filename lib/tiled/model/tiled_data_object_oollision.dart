import 'package:bonfire/collision/collision_area.dart';

class TiledDataObjectCollision {
  final List<CollisionArea>? collisions;
  final String type;
  final Map<String, dynamic>? properties;

  TiledDataObjectCollision({this.collisions, this.type = '', this.properties});
}
