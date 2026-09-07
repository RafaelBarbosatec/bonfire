import 'package:bonfire/bonfire.dart';
import 'package:bonfire/forces/forces_api.dart';

export 'forces_ext.dart';
export 'global_forces_settings.dart';

/// Simple physics forces for SimpleMovement
///
/// This mixin adds realistic physics forces like gravity, friction, wind, etc.
/// It's much simpler than the original HandleForces but covers most common cases.
mixin WithForces on Movement {
  late final ForcesApi forces = ForcesApi(this);

  @override
  void update(double dt) {
    forces.update(dt);
    super.update(dt);
  }
}
