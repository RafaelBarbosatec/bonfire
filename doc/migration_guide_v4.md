# Migration Guide: v3.x → v4.0.0

This guide covers all breaking changes and improvements introduced in Bonfire v4.0.0. Read through each section that applies to your project before upgrading.

---

## Table of Contents

1. [Dependency version](#dependency-version)
2. [Collision System](#collision-system)
3. [Physics / Forces System](#physics--forces-system)
4. [Movement Mixin](#movement-mixin)
5. [FlyingAttackGameObject](#flyingattackgameobject)
6. [Jumper Mixin](#jumper-mixin)
7. [Platform Characters (PlatformPlayer / PlatformEnemy)](#platform-characters-platformplayer--platformenemy)
8. [Player & NPC initial direction](#player--npc-initial-direction)
9. [DirectionAnimation](#directionanimation)
10. [PathFinding](#pathfinding)
11. [BonfireWidget — globalForces parameter](#bonfirewidget--globalforces-parameter)
12. [Exports / import paths](#exports--import-paths)

---

## Dependency version

Update `pubspec.yaml`:

```yaml
# v3.x
bonfire: ^3.17.0

# v4.0.0
bonfire: ^4.0.0
```

---

## Collision System

### `BlockMovementCollision` → `SimpleCollision`

The old `BlockMovementCollision` mixin has been replaced by the new unified `SimpleCollision` mixin.

**Before (v3.x):**

```dart
class MyEnemy extends SimpleEnemy with BlockMovementCollision {
  // ...
}
```

**After (v4.0.0):**

```dart
class MyEnemy extends SimpleEnemy with SimpleCollision {
  // ...
}
```

`SimpleCollision` also exposes a `BodyType` enum that lets you mark a component as `static` (immovable) or `dynamic` (the default):

```dart
class MyWall extends GameDecoration with Movement, SimpleCollision {
  MyWall({required super.position, required super.size}) {
    bodyType = BodyType.static;
  }
}
```

### `setupCollision` — new signature

```dart
// v3.x
setupBlockMovementCollision(enabled: true);

// v4.0.0
setupCollision(enabled: true, bodyType: BodyType.dynamic);
```

### Collision callback — `onMovementBlocked`

The collision callback now receives a `CollisionData` object with richer information (depth, normal vector, collision direction):

```dart
// v3.x
@override
bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
  return true; // true = block, false = allow pass
}

// v4.0.0
@override
void onMovementBlocked(PositionComponent other, CollisionData collisionData) {
  super.onMovementBlocked(other, collisionData);
  // collisionData.depth     – penetration depth
  // collisionData.normal    – surface normal
  // collisionData.direction – side of impact
}

// onBlockMovement is still available to allow/deny the block:
@override
bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
  return true;
}
```

### `ElasticCollision` → `SimpleElasticCollision`

The bouncing mixin has been renamed and now depends on `SimpleCollision` instead of `BlockMovementCollision`. The `restitution` parameter was renamed to `bounciness`:

```dart
// v3.x
class MyBall extends GameDecoration
    with Movement, BlockMovementCollision, ElasticCollision {
  MyBall() {
    setupElasticCollision(restitution: 2.0);
  }
}

// v4.0.0
class MyBall extends GameDecoration
    with Movement, SimpleCollision, SimpleElasticCollision {
  MyBall() {
    setupElasticCollision(bounciness: 2.0);
  }
}
```

---

## Physics / Forces System

The entire forces API has been redesigned to be simpler and more intuitive.

### `HandleForces` → `Forces`

The old `HandleForces` mixin (backed by the `Force2D` class hierarchy) is replaced by the built-in `Forces` mixin.

**Before (v3.x):**

```dart
class MyCrate extends GameDecoration
    with Movement, BlockMovementCollision, HandleForces {
  MyCrate({required super.position, required super.size}) {
    addForce(GravityForce2D());
    addForce(ResistanceForce2D(id: 'friction', value: Vector2(3, 3)));
  }
}
```

**After (v4.0.0):**

```dart
class MyCrate extends GameDecoration
    with Movement, SimpleCollision, Forces {
  MyCrate({required super.position, required super.size}) {
    enableEarthGravity();    // built-in 300 px/s² gravity
    enableNormalFriction();  // built-in normal friction preset
  }
}
```

### `setupPhysics` — configure physics at once

```dart
setupPhysics(
  mass: 2.0,
  dragCoefficient: 0.02,
  gravity: Vector2(0, 300),
  friction: Vector2(0.1, 0.0),
);
```

### `addForce` / `removeForce` — new signature

Custom forces now use a `String` name key instead of a typed `Force2D` object:

```dart
// v3.x
addForce(AccelerationForce2D(id: 'wind', value: Vector2(50, 0)));
removeForce('wind');

// v4.0.0
addForce('wind', Vector2(50, 0));
removeForce('wind');
```

### Convenience preset methods on `Forces`

| Method | Description |
|---|---|
| `enableEarthGravity()` | `gravity = Vector2(0, 300)` |
| `enableMoonGravity()` | `gravity = Vector2(0, 50)` |
| `enableZeroGravity()` | gravity = zero |
| `enableIceFriction()` | very slippery surface |
| `enableNormalFriction()` | standard friction |
| `enableHighFriction()` | rough surface |
| `makeProjectile()` | small gravity + no friction |
| `makeFlyingObject()` | wind only, no gravity |
| `makeGroundObject()` | earth gravity + normal friction |
| `makeSpaceObject()` | zero gravity + no friction |

---

## Movement Mixin

The `Movement` mixin has been simplified and cleaned up.

### Renamed fields

| v3.x | v4.0.0 |
|---|---|
| `lastDirection` | `direction` |
| `lastDirectionHorizontal` | `hDirection` |
| `lastDirectionVertical` | `vDirection` |
| `speedDefault` (const) | `defaultSpeed` (const) |
| `diaginalReduction` (const) | `diagonalFactor` (const, value `0.7071`) |

**Before:**

```dart
if (lastDirection == Direction.left) { ... }
if (lastDirectionHorizontal == Direction.right) { ... }
```

**After:**

```dart
if (direction == Direction.left) { ... }
if (hDirection.isRightSide) { ... }
```

### Renamed / replaced methods

| v3.x | v4.0.0 |
|---|---|
| `moveFromAngle(angle)` | `moveByAngle(angle)` |
| `stopMove()` | `stop()` |
| `setZeroVelocity()` | `velocity = Vector2.zero()` |

### `moveFromDirection` parameter renamed

```dart
// v3.x
moveFromDirection(Direction.right, enabledDiagonal: true);

// v4.0.0
moveFromDirection(Direction.right, useDiagonal: true);
```

### Removed properties / methods

The following members were removed. Update your code to avoid referencing them:

| Removed | Alternative |
|---|---|
| `displacement` | compute it yourself (`velocity * dt`) |
| `velocityRadAngle` | use `velocity.angleTo(...)` |
| `acceleration` | compute it yourself (`velocity / dt`) |
| `dtSpeed`, `dtDiagonalSpeed`, `diagonalSpeed` | use `speed * dt` directly |
| `minDisplacementToConsiderMove` | removed |
| `moveLeftOnce()`, `moveRightOnce()`, `moveUpOnce()`, `moveDownOnce()` | use regular `moveLeft()` etc. with custom logic |
| `translate(displacement)` | use `position += displacement` |
| `onVelocityUpdate(dt, velocity)` | override `update(dt)` instead |
| `onApplyDisplacement(dt)` | override `update(dt)` instead |
| `correctPositionFromCollision(position)` | handled internally |
| `onMove(speed, displacement, direction, angle)` | `onMove()` — no parameters |

### New additions

| Addition | Description |
|---|---|
| `isMoving` getter | `true` when velocity is non-zero (opposite of `isIdle`) |
| `moveToward(Vector2 target)` | moves the component toward a world position |
| `resetCrossAxis` param | available on `moveUp/Down/Left/Right` — zeroes the perpendicular axis |
| `idle()` callback | called once when the component becomes idle |

---

## FlyingAttackGameObject

Two method renames affect `FlyingAttackGameObject` (and any subclass):

```dart
// v3.x
moveFromAngle(angle);
moveFromDirection(dir, enabledDiagonal: true);

// v4.0.0
moveByAngle(angle);
moveFromDirection(dir, useDiagonal: true);
```

`FlyingAttackGameObject` now uses `SimpleCollision` internally instead of `BlockMovementCollision`. No change is needed unless you were overriding collision behaviour directly.

---

## Jumper Mixin

`Jumper` now requires `SimpleCollision` instead of `BlockMovementCollision`:

```dart
// v3.x
class MyPlayer extends SimplePlayer
    with BlockMovementCollision, Jumper, JumperAnimation { ... }

// v4.0.0
class MyPlayer extends SimplePlayer
    with SimpleCollision, Jumper, JumperAnimation { ... }
```

---

## Platform Characters (PlatformPlayer / PlatformEnemy)

`PlatformPlayer` and `PlatformEnemy` have been updated internally to use `SimpleCollision`. If you extend them, remove the manual `BlockMovementCollision` mixin:

```dart
// v3.x
class MyPlatformPlayer extends PlatformPlayer
    with BlockMovementCollision { ... }

// v4.0.0 — SimpleCollision is already provided by PlatformPlayer/PlatformEnemy
class MyPlatformPlayer extends PlatformPlayer { ... }
```

---

## Player & NPC initial direction

Setting the initial direction no longer uses `lastDirection` / `lastDirectionHorizontal`:

```dart
// v3.x (inside constructor body)
lastDirection = initDirection;
lastDirectionHorizontal = Direction.left;

// v4.0.0
direction = initDirection;
// hDirection / vDirection are derived automatically
```

---

## DirectionAnimation

Internal property references were updated to match the new `Movement` field names. If you override `DirectionAnimation` callbacks or reference its fields, update them:

```dart
// v3.x                    // v4.0.0
lastDirection           →  direction
lastDirectionHorizontal →  hDirection
```

No API changes to `SimpleDirectionAnimation` or `PlatformAnimations`.

---

## PathFinding

`stopMove()` calls inside `PathFinding` have been replaced with `stop()`. If you override path-finding callbacks in your own code, apply the same rename:

```dart
// v3.x
stopMove();

// v4.0.0
stop();
```

---

## BonfireWidget — globalForces parameter

```dart
// v3.x
BonfireWidget(
  globalForces: [
    GravityForce2D(),
    ResistanceForce2D(id: 'air', value: Vector2(3, 0)),
  ],
  // ...
)

// v4.0.0
BonfireWidget(
  globalForces: GlobalForcesSettings(
    gravity: Vector2(0, 300),
    dragCoefficient: 0.01,
    // wind: Vector2(10, 0),
    // friction: Vector2(0.1, 0.0),
  ),
  // ...
)
```

> **Note:** `GlobalForcesSettings` applies physics defaults to every component that uses the `Forces` mixin. Components can still override these defaults individually via `setupPhysics()`.

---

## Exports / import paths

Several files were reorganised. **If you only import `package:bonfire/bonfire.dart` you do not need to change any import.** However, if you import internal paths directly, update them:

| v3.x | v4.0.0 |
|---|---|
| `package:bonfire/collision/block_movement_collision.dart` | `package:bonfire/collision/collision.dart` |
| `package:bonfire/forces/forces_2d.dart` | `package:bonfire/forces/forces.dart` |
| `package:bonfire/forces/handle_forces.dart` | `package:bonfire/forces/forces.dart` |
| `package:bonfire/mixins/elastic_collision.dart` | `package:bonfire/collision/elastic_collision.dart` |

A new convenience barrel is also available:

```dart
// Re-exports SimpleCollision, SimpleElasticCollision, and Forces together
import 'package:bonfire/mixins/mixins.dart';
```

---

## Quick Reference Cheat-Sheet

```
BlockMovementCollision        →  SimpleCollision
ElasticCollision              →  SimpleElasticCollision  (restitution: → bounciness:)
HandleForces                  →  Forces
Force2D / GravityForce2D      →  enableEarthGravity() / addForce(name, vector)
globalForces: [...]           →  globalForces: GlobalForcesSettings(...)
lastDirection                 →  direction
lastDirectionHorizontal       →  hDirection
lastDirectionVertical         →  vDirection
moveFromAngle()               →  moveByAngle()
stopMove()                    →  stop()
setZeroVelocity()             →  velocity = Vector2.zero()
enabledDiagonal:              →  useDiagonal:
onMove(speed, disp, dir, ang) →  onMove()
```
