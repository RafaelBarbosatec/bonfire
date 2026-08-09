import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/extensions/color_extensions.dart';

export 'sensor_api.dart';

/// Mixin responsible for adding trigger to detect other objects above.
///
/// Access all sensor functionality through the [sensor] API object.
mixin WithSensor<T extends GameComponent> on GameComponent {
  static Color color = const Color(0xFFF44336).setOpacity(0.5);

  late final SensorApi<T> sensor = SensorApi<T>(this);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await sensor.ensureCollisionShape();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    sensor.handleCollision(other);
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    sensor.handleCollisionEnd(other);
    super.onCollisionEnd(other);
  }

  @override
  int get priority => LayerPriority.MAP + 1;

  @override
  void onRemove() {
    sensor.dispose();
    super.onRemove();
  }
}
