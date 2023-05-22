import 'package:bonfire/bonfire.dart';
import 'package:bonfire/forces/forces_2d.dart';

mixin HandleForces on Movement {
  final Forces2D _forces = Forces2D();

  void addForce(Force2D force) {
    _forces.addForce(force);
  }

  void addResistence(Force2D resistence) {
    _forces.addResistence(resistence);
  }

  void removeForce(dynamic id) {
    _forces.removeForce(id);
  }

  void removeResistence(dynamic id) {
    _forces.removeResistence(id);
  }

  @override
  Vector2 onApplyVelocity(Vector2 velocity, double dt) {
    Vector2 allForces = _forces.forces.fold<Vector2>(
      Vector2.zero(),
      (previousValue, element) => previousValue + element.value,
    );
    var oldVel = velocity.clone();
    this.velocity = velocity + allForces * dt;
    return (oldVel + this.velocity) * 0.5 * dt;
  }
}
