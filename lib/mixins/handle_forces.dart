import 'package:bonfire/bonfire.dart';

export 'package:bonfire/forces/forces_2d.dart';

mixin HandleForces on Movement {
  final List<Force2D> _forces = [];

  void addForce(Force2D force) {
    _forces.removeWhere((element) => element.id == force.id);
    _forces.add(force);
  }

  void removeForce(dynamic id) {
    _forces.removeWhere((element) => element.id == id);
  }

  @override
  Vector2 onApplyAcceleration(double dt) {
    var oldVel = super.onApplyAcceleration(dt);
    Vector2 newVel = Vector2.zero();

    List margeForces = [..._forces, ...gameRef.globalForces];
    velocity =
        margeForces.where((element) => element is! LinearForce2D).fold<Vector2>(
              velocity,
              (previousValue, element) => element.transform(previousValue,dt),
            );
    newVel = margeForces.whereType<LinearForce2D>().fold<Vector2>(
          velocity,
          (p, e) => e.transform(p,dt),
        );

    return (oldVel + newVel) * 0.5;
  }
}
