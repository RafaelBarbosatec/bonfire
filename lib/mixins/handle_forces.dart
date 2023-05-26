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
  Vector2 onApplyVelocity(Vector2 velocity, double dt) {
    var oldVel = velocity.clone();
    List margeForces = [..._forces, ...gameRef.globalForces];
    this.velocity =
        margeForces.where((element) => element is! LinearForce2D).fold<Vector2>(
              velocity,
              (previousValue, element) => element.transform(previousValue, dt),
            );
    var newLiVel = margeForces.whereType<LinearForce2D>().fold<Vector2>(
          this.velocity,
          (previousValue, element) => element.transform(previousValue, dt),
        );
    return (oldVel + newLiVel) * 0.5 * dt;
  }
}
