---
name: bonfire-collision-sensor
description: Handle Bonfire collisions and sensors — add hitboxes, block movement with WithCollision, listen to collision callbacks, use non-blocking sensors (spikes, pickups, damage zones) and configure the collision system. Use when movement passes through walls, collisions don't fire, or you need overlap detection without blocking.
---

# Bonfire — Collision and Sensors (4.x)

Bonfire 4 uses Flame's collision detection. Two independent concepts:

| Need | Use |
|---|---|
| Physical body that stops movement | `ShapeHitbox` + `WithCollision` |
| Overlap trigger that does **not** block | `WithSensor<T>` |
| Custom reaction to a hit | override `onCollision` / `onCollisionEnd` |

## 1. Hitboxes

Add them in `onLoad`, after/before `super.onLoad()` (both work, but add before
returning):

```dart
class Crate extends GameDecoration with WithCollision {
  Crate(Vector2 position)
      : super.withSprite(
          sprite: Sprite.load('itens/crate.png'),
          position: position,
          size: Vector2.all(32),
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(size: size));
    return super.onLoad();
  }
}
```

`RectangleHitbox`, `CircleHitbox` and `PolygonHitbox` are available. The
hitbox is what participates in collision; it does not have to match `size`
(common pattern: `size / 2` centered with `position: size / 4`, so the
character's feet collide, not the whole sprite).

Tiles marked as collision in the Tiled map become barriers automatically —
don't add hitboxes for walls manually.

## 2. Blocking movement

`WithCollision` is what stops the component when a hitbox intersects another
solid hitbox:

```dart
class Player extends SimplePlayer with WithCollision { ... }
```

Without it the component still receives Flame collision callbacks but moves
through everything.

Collision API:

```dart
collision.enable();
collision.disable();
collision.bodyType = BodyType.dynamic; // dynamic | static | kinetic
collision.onBlockMovementListener((other, data) { ... });
collision.onMovementBlockedListener((other, data) { ... });
collision.reflectionResolution((velocity, normal, ...) { ... });
collision.lastCollisionData;
```

Return `false` from `collision.blockMovementHandle(points, other)` to let the
component pass through a specific object.

## 3. Reacting to collisions

```dart
@override
void onCollision(Set<Vector2> points, PositionComponent other) {
  if (other is Fireball) {
    life.remove(10);
  }
  super.onCollision(points, other);
}

@override
void onCollisionEnd(PositionComponent other) {
  // contact finished
  super.onCollisionEnd(other);
}
```

`onCollision` fires repeatedly while overlapping — always gate damage with an
`IntervalTick` or a flag, otherwise a single contact drains life every frame.

## 4. Sensors (non-blocking)

`WithSensor<T>` creates a detection shape matching the component size if none
exists, and never blocks movement. Ideal for spikes, lava, pickups, triggers.

```dart
class Spikes extends GameDecoration with WithSensor<WithLife> {
  Spikes(Vector2 position)
      : super.withSprite(
          sprite: Sprite.load('itens/spikes.png'),
          position: position,
          size: Vector2.all(32),
        ) {
    sensor.setup(interval: 500); // ms between checks
    sensor.onContactListener((component) {
      if (component is Player) {
        component.life.handleAttack(AttackOriginEnum.ENEMY, 10, 1);
      }
    });
  }
}
```

Type parameter matters: `WithSensor<Player>` only reports the player;
`WithSensor<WithLife>` reports anything with life, and you can branch inside.
`GameComponent` itself can be used for "anything".

Sensor API:

```dart
sensor.onContactListener(callback);
sensor.onContactEndListener(callback);
sensor.enabled = false;   // temporarily disable
sensor.setup(interval: 100);
```

A pickup (potion) is the same pattern: `WithSensor<Player>` + `removeFromParent()`
on contact, optionally animating with `util.generateValues(...)`.

## 5. Global configuration

```dart
BonfireWidget(
  collisionConfig: BonfireCollisionConfig.quadTree(), // many components
  showCollisionArea: true,                            // debug draw
  collisionAreaColor: Colors.red,
  ...
)
```

`BonfireCollisionConfig.quadTree()` is the recommended option when the map has
many components; `BonfireCollisionConfig.dafault()` (note the typo in the API)
uses Flame's default broadphase. `showCollisionArea: true` draws every hitbox —
use it to debug "invisible wall" reports.

## Pitfalls

- A component with a hitbox but **without** `WithCollision` does not block —
  this is the usual cause of "the player walks through walls".
- Sensors do not need `WithCollision`; adding both makes the trigger solid.
- Do not add hitboxes in the constructor (`size`/`gameRef` may not be ready);
  use `onLoad`.
- `onCollision` receives `PositionComponent`, not `GameComponent` — cast or use
  `is` checks before touching `life`.
- With many enemies, prefer `BonfireCollisionConfig.quadTree()` over the
  default to avoid O(n²) checks.
- Damage from sensors must call `life.handleAttack(...)` (respects
  `receivesAttackFrom`); `life.remove(...)` ignores attacker rules.

## Repo references

- `example/lib/shared/decoration/spikes.dart` — sensor causing damage
- `example/lib/shared/decoration/potion_life.dart` — pickup sensor
- `example/lib/shared/decoration/chest.dart` — tap + vision interaction
- `example/lib/pages/collision/` — collision demo page
