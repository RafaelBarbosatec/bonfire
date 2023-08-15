import 'package:bonfire/bonfire.dart';

export 'package:bonfire/forces/forces_2d.dart';

/// Mixin that makes the component suffer influences from global or local forces.
/// To adds local forces just call `addForce` method. To adds global foreces use the param `globalForces` in `BonfireWidget`.
mixin HandleForces on Movement {
  Vector2 _accelerationOfForces = Vector2.zero();

  /// Mass of the Component
  double mass = 1.0;

  final List<Force2D> _forces = [];

  void addForce(Force2D force) {
    _forces.removeWhere((element) => element.id == force.id);
    _forces.add(force);
  }

  void removeForce(dynamic id) {
    _forces.removeWhere((element) => element.id == id);
  }

  @override
  Vector2 onApplyAcceleration(Vector2 acceleration, double dt) {
    final oldVelocity = velocity.clone();
    List<Force2D> mergeForces = [..._forces, ...gameRef.globalForces];
    _accelerationOfForces = _getAccelerationForces(mergeForces, dt);

    var currentVelocity = super.onApplyAcceleration(_accelerationOfForces, dt);

    Vector2 newVel = _applyResistenceForces(mergeForces, currentVelocity, dt);

    newVel = _applyLinearForces(mergeForces, newVel, dt);

    return velocity = (oldVelocity + newVel) * 0.5;
  }

  Vector2 _getAccelerationForces(List<Force2D> mergeForces, double dt) {
    return mergeForces.whereType<AccelerationForce2D>().fold<Vector2>(
          Vector2.zero(),
          (p, e) => p + e.transform(p, mass, dt),
        );
  }

  Vector2 _applyResistenceForces(
    List<Force2D> mergeForces,
    Vector2 currentVelocity,
    double dt,
  ) {
    return mergeForces.whereType<ResistenceForce2D>().fold<Vector2>(
          currentVelocity,
          (p, e) => e.transform(p, mass, dt),
        );
  }

  Vector2 _applyLinearForces(
    List<Force2D> mergeForces,
    Vector2 newVel,
    double dt,
  ) {
    return mergeForces.whereType<LinearForce2D>().fold<Vector2>(
          newVel,
          (p, e) => e.transform(p, mass, dt),
        );
  }
}
