import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/elastic_collision_api.dart';

export 'elastic_collision_api_ext.dart';

/// Simple elastic collision system for bouncy objects
///
/// This mixin adds realistic bounce behavior to components using Collision.
/// It's much simpler and more predictable than the original ElasticCollision.
mixin WithElasticCollision on WithCollision {
  late final ElasticCollisionApi elasticCollision = ElasticCollisionApi(this);

  @override
  void onRemove() {
    elasticCollision.dispose();
    super.onRemove();
  }
}
