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

The `Movement` mixin is the only mixin that keeps its original API. It remains the central movement interface for components and does not follow the `WithFeature` + `feature.{resource}` pattern.

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

## Internal cleanup

- `CustomQuadTreeBroadphase` was removed. `CustomQuadTreeCollisionDetection` now uses `QuadTreeBroadphase` directly.

## Quick checklist

1. Update `pubspec.yaml` to `bonfire: ^4.0.0`.
2. Replace mixin names with the `With` prefix.
3. Replace direct method calls with calls through the API object.
4. Replace direct property assignments with API methods or setters.
5. Run `flutter analyze` and fix remaining issues.
