# Migration Guide: Bonfire 3.x to 4.0

Bonfire 4.0 introduces a new API-first architecture for mixins. The main goal is to improve developer experience by grouping related functionality under a named API object, avoiding polluted component namespaces when many mixins are used together.

## Why this change?

In previous versions, mixins exposed methods and variables directly on the component. When a component used several mixins (`Movement`, `Jumper`, `Sensor`, `PathFinding`, `Pushable`, etc.), the component ended up with dozens of members mixed in the same scope, making autocomplete and code discovery harder.

Starting with Bonfire 4.0, most mixins follow this pattern:

- The mixin is named `WithFeature`.
- The mixin exposes a single API object: `feature`.
- All related methods, listeners and state are accessed through `component.feature.method()`.

```dart
// Bonfire 3.x
player.jump();
player.runRandomMovement(dt, speed: 20);
player.setupPathFinding(linePathEnabled: true);

// Bonfire 4.0
player.jumper.jump();
player.randomMovement.update(dt, speed: 20);
player.pathFinding.setup(linePathEnabled: true);
```

## What didn't change?

The `Movement` mixin is the only mixin that keeps its original **access style** — it remains the central movement interface for components and does not follow the `WithFeature` + `feature.{resource}` pattern.

```dart
class MyPlayer extends SimplePlayer with Movement, WithJumper, WithSensor {
  @override
  void update(double dt) {
    super.update(dt);
    // Movement continues to be accessed directly:
    moveLeft();
    stop();
    if (isMoving) { ... }

    // Other mixins use the API object:
    jumper.jump();
    sensor.enabled = false;
  }
}
```

> **Note:** All other mixins were migrated to the API-first pattern. `Movement` stays direct because it is the foundation used by almost every other mixin and by user code.

> **⚠️ Important:** although `Movement` is still accessed directly, it was **rewritten and simplified** in 4.0. Several public members were removed, renamed or had their signatures changed. See the [Movement migration table](#movement) below before upgrading.

## Movement

Even though `Movement` keeps the direct-access style, it was heavily simplified. The following table lists every public API change you need to be aware of:

### Removed

| Bonfire 3.x | Bonfire 4.0 |
|-------------|-------------|
| `displacement` (Vector2 moved last frame) | Removed. Track it yourself if needed: `final moved = velocity * dt;` in `update()` |
| `lastDirection` / `lastDirectionHorizontal` / `lastDirectionVertical` | Removed. Use `direction`, `hDirection`, `vDirection` (these now reflect the current velocity) |
| `acceleration` | Removed |
| `velocityRadAngle` | Removed |
| `minDisplacementToConsiderMove` | Removed. `isMoving` now uses an internal frame counter |
| `diagonalSpeed` / `dtSpeed` / `dtDiagonalSpeed` | Removed. Use `speed` (or `speed * diagonalFactor`) directly |
| `setVelocityAxis({x, y})` | Removed. Assign `velocity` directly |
| `moveLeftOnce()` / `moveRightOnce()` / `moveUpOnce()` / `moveDownOnce()` / diagonal `*Once` variants | Removed. Use the regular `moveLeft()`, etc. and stop when you want to halt |
| `stopMove({forceIdle, isX, isY})` | Removed. Use `stop()` |
| `onVelocityUpdate(dt, velocity)` | Removed |
| `onApplyDisplacement(dt)` | Removed |
| `correctPositionFromCollision(position)` | Removed |
| `static const speedDefault` | Removed. Use `Movement.defaultSpeed` (or just `speed`) |

### Renamed / changed signature

| Bonfire 3.x | Bonfire 4.0 |
|-------------|-------------|
| `moveFromAngle(angle, {speed})` | `moveByAngle(angle, {speed})` |
| `moveFromDirection(dir, {enabledDiagonal})` | `moveFromDirection(dir, {useDiagonal})` |
| `onMove(double speed, Vector2 displacement, Direction direction, double angle)` | `onMove()` — no arguments. Override it to react to any movement; read `velocity`, `direction`, `hDirection`, `vDirection` for details |
| `position` setter (with collision correction side-effects) | Removed custom setter — `position` behaves like a plain `PositionComponent` |

### Added in 4.0

- `moveByAngle(double angleRadians, {double? speed})`
- `moveToward(Vector2 target, {double? speed})`
- `isMoving` / `isIdle` getters
- `hDirection` / `vDirection` getters
- `onMove()` hook (no args)

## Migration table

### Follower

| Bonfire 3.x | Bonfire 4.0 |
|-------------|-------------|
| `Follower` mixin | `WithFollower` mixin |
| `setupFollower(target: ..., offset: ...)` | `follower.setup(target: ..., offset: ...)` |
| `removeFollowerTarget()` | `follower.removeTarget()` |
| `followerTarget` | `follower.target` |
| `followerOffset` | `follower.offset` |

### Jumper

| Bonfire 3.x | Bonfire 4.0 |
|-------------|-------------|
| `Jumper` mixin | `WithJumper` mixin |
| `jump()` | `jumper.jump()` |
| `setMaxJump(2)` | `jumper.setMaxJump(2)` |
| `onJumpStateChangedListener(...)` | `jumper.onJumpStateChangedListener(...)` |
| `isJumping` | `jumper.isJumping` |

### Sensor

| Bonfire 3.x | Bonfire 4.0 |
|-------------|-------------|
| `Sensor` mixin | `WithSensor` mixin |
| `onContactListener(...)` | `sensor.onContactListener(...)` |
| `onContactEndListener(...)` | `sensor.onContactEndListener(...)` |
| `enabled` | `sensor.enabled` |

### Life

| Bonfire 3.x | Bonfire 4.0 |
|-------------|-------------|
| `Life` mixin | `WithLife` mixin |
| `initial(200)` | `life.initial(200)` |
| `add(50)` | `life.add(50)` |
| `remove(25)` | `life.remove(25)` |
| `onDieListener(...)` | `life.onDieListener(...)` |

### Pushable

| Bonfire 3.x | Bonfire 4.0 |
|-------------|-------------|
| `Pushable` mixin | `WithPushable` mixin |
| `setupPushable(...)` | `pushable.setup(...)` |
| override `bool onPush(component)` | `pushable.onPushListener((component) => ...)` |

`PushableFromEnum` keeps the same name and values.

### RandomMovement

| Bonfire 3.x | Bonfire 4.0 |
|-------------|-------------|
| `RandomMovement` mixin | `WithRandomMovement` mixin |
| `runRandomMovement(dt, ...)` | `randomMovement.update(dt, ...)` |
| `onStartMove` / `onStopMove` parameters | `randomMovement.onStartMoveListener(...)` / `randomMovement.onStopMoveListener(...)` |
| `randomMovementArea` | `randomMovement.area` |

### PathFinding

| Bonfire 3.x | Bonfire 4.0 |
|-------------|-------------|
| `PathFinding` mixin | `WithPathFinding` mixin |
| `setupPathFinding(...)` | `pathFinding.setup(...)` |
| `moveToPositionWithPathFinding(...)` | `pathFinding.moveToPosition(...)` |
| `moveAlongThePath(...)` | `pathFinding.moveAlongThePath(...)` |
| `getPathToPosition(...)` | `pathFinding.getPathToPosition(...)` |
| `stopMoveAlongThePath()` | `pathFinding.stop()` |
| `isMovingAlongThePath` | `pathFinding.isMoving` |

### FlipRender

| Bonfire 3.x | Bonfire 4.0 |
|-------------|-------------|
| `FlipRender` mixin | `WithFlipRender` mixin |
| `flipRenderVertically = true` | `flipRender.flipVertically()` |
| `flipRenderHorizonally = true` | `flipRender.flipHorizontally()` |

### MovePerCell

| Bonfire 3.x | Bonfire 4.0 |
|-------------|-------------|
| `MovePerCell` mixin | `WithMovePerCell` mixin |
| `setupMovePerCell(...)` | `movePerCell.setup(...)` |
| `cellSize` | `movePerCell.cellSize` |

### AssetsLoader

| Bonfire 3.x | Bonfire 4.0 |
|-------------|-------------|
| `UseAssetsLoader` mixin | `WithAssetsLoader` mixin |
| `loader?.add(AssetToLoad(...))` | `assetsLoader.add(AssetToLoad(...))` |

`AssetsLoader` and `AssetToLoad` classes are still public and exported.

### LifeBar

| Bonfire 3.x | Bonfire 4.0 |
|-------------|-------------|
| `UseLifeBar` mixin | `WithLifeBar` mixin |
| `setupLifeBar(...)` | `lifeBar.setup(...)` |

### Interval / `checkInterval`

The `InternalChecker` mixin and the `checkInterval` method were removed. Instead of relying on internal timers keyed by `String`, you now manage your own `IntervalTick` instances. `IntervalTick` is public and can be created anywhere (field, constructor, `onLoad`).

| Bonfire 3.x | Bonfire 4.0 |
|-------------|-------------|
| `checkInterval('key', 1000, dt)` | `final _tick = IntervalTick(1000);` … `_tick.update(dt)` |
| `checkInterval('key', 1000, dt, firstCheckIsTrue: true)` | `IntervalTick(1000, tickFirstUpdate: true)` |
| `resetInterval('key')` | `_tick.reset()` |
| `pauseInterval('key')` | `_tick.pause()` |
| `playInterval('key')` | `_tick.play()` |
| `tickInterval('key')` | `_tick.tick()` |
| `invervalIsRunning('key')` | `_tick.running` |

> **Note:** The `interval` and `execute` parameters were removed from the Enemy and Ally attack extensions — `simpleAttackMelee` and `simpleAttackRange` no longer control the execution frequency for you (and no longer accept an `execute` callback). You should control it yourself with an `IntervalTick`:

```dart
// Bonfire 3.x
class MyEnemy extends SimpleEnemy {
  @override
  void update(double dt) {
    super.update(dt);
    simpleAttackMelee(
      damage: 10,
      size: Vector2(20, 20),
      interval: 1000,
    );
  }
}

// Bonfire 4.0
class MyEnemy extends SimpleEnemy {
  final _attackTick = IntervalTick(1000);

  @override
  void update(double dt) {
    super.update(dt);
    if (_attackTick.update(dt)) {
      simpleAttackMelee(damage: 10, size: Vector2(20, 20));
    }
  }
}
```

## Internal cleanup

- `CustomQuadTreeBroadphase` was removed. `CustomQuadTreeCollisionDetection` now uses `QuadTreeBroadphase` directly.
- `InternalChecker` mixin and the `checkInterval` method were removed. Use `IntervalTick` directly (see the migration table above).

## FlyingAttackGameObject

| Bonfire 3.x | Bonfire 4.0 |
|-------------|-------------|
| `FlyingAttackGameObject(... collision: ...)` | `FlyingAttackGameObject(... shapeCollision: ...)` — parameter renamed |
| `moveFromAngle(angle)` | `moveByAngle(angle)` |
| `moveFromDirection(dir, enabledDiagonal: ...)` | `moveFromDirection(dir, useDiagonal: ...)` — parameter renamed |

## Quick checklist

1. Update `pubspec.yaml` to `bonfire: ^4.0.0`.
2. Replace mixin names with the `With` prefix.
3. Replace direct method calls with calls through the API object.
4. Replace direct property assignments with API methods or setters.
5. Replace `checkInterval(...)` calls with your own `IntervalTick` instance.
6. Review your `Movement` overrides (`onMove`, `displacement`, `lastDirection`, `stopMove`, `*Once` methods) against the [Movement table](#movement).
7. Run `flutter analyze` and fix remaining issues.
