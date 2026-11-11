---
name: bonfire-v4-api
description: Reference for the Bonfire 4.x API-object pattern and the 3.x → 4.x migration. Use whenever you write Bonfire code from memory, when a method is "not defined", or when porting v3 snippets (jump, sensor, path finding, life, pushable, random movement) to v4.
---

# Bonfire — 4.x API Objects (anti-hallucination reference)

Bonfire 4 moved nearly every mixin to an **API object**: the mixin is
`WithFeature` and all state/methods are reached through `component.feature`.
Code generated from Bonfire 3.x training data will not compile. When in doubt,
open `lib/mixins/<feature>/` and read the `*_api.dart` file.

## Mapping table

| 3.x (wrong in v4) | 4.x (correct) | API object |
|---|---|---|
| `player.jump()` | `player.jumper.jump()` | `jumper` |
| `player.setMaxJump(2)` | `player.jumper.setMaxJump(2)` | `jumper` |
| `enemy.seePlayer(...)` | `enemy.vision.seePlayer(...)` | `vision` |
| `enemy.seeAndMoveToPlayer(...)` | `enemy.vision.seeAndMoveToPlayer(...)` | `vision` |
| `player.seeEnemy(...)` | `player.vision.seeEnemy(...)` | `vision` |
| `component.addLife(10)` | `component.life.add(10)` | `life` |
| `component.removeLife(10)` | `component.life.remove(10)` | `life` |
| `component.life = 100` | `component.life.initial(100)` | `life` |
| `component.showDamage(10)` | `component.util.showDamage(10)` | `util` |
| `component.getDirectionTo(target)` | `component.util.getDirectionToTarget(target)` | `util` |
| `component.sensor.onContact...` | same, via `sensor` object | `sensor` |
| `component.runRandomMovement(dt, speed: 20)` | `component.randomMovement.setup(speed: 20)` then `randomMovement.run(dt)` | `randomMovement` |
| `component.setupPathFinding(...)` | `component.pathFinding.setup(...)` | `pathFinding` |
| `component.moveToPosition(...)` (path) | `component.pathFinding.moveToPosition(...)` | `pathFinding` |
| `component.pushable...` | `component.pushable.setup(...)` | `pushable` |
| `component.flipVertically()` | `component.flipRender.flipVertically()` | `flipRender` |
| `component.useLifeBar` helpers | `component.lifeBar.setup(...)` | `lifeBar` |
| `component.melee(...)` | `component.attack.melee(...)` | `attack` |
| `component.range(...)` | `component.attack.range(...)` | `attack` |
| `component.shader = ...` | `component.shader.fragment = ...` | `shader` |

**Exception:** `Movement` remains directly on the component
(`moveFromDirection`, `moveByAngle`, `stop`, `position`, `speed`) because it
is the foundation of everything else. There is no `component.movement` object.

## Correct v4 snippets

```dart
// Life
class Enemy extends SimpleEnemy with WithLifeBar {
  Enemy(Vector2 p) : super(position: p, size: Vector2.all(32), life: 100) {
    life.onDieListener(_onDie);
    life.onRemoveLifeListener((amount) => util.showDamage(amount));
    lifeBar.setup(borderRadius: BorderRadius.circular(2));
    life.receivesAttackFrom = AcceptableAttackOriginEnum.ALL;
  }
}

// Vision
vision.seePlayer(
  radiusVision: 128,
  observed: (player) => attack.melee(damage: 10, size: Vector2.all(32)),
);

// Jumper (platformer)
jumper.setMaxJump(2);
jumper.jump();

// Sensor
sensor.setup(interval: 300);
sensor.onContactListener((component) {
  if (component is Player) component.life.remove(5);
});

// Random movement (or prefer BRandomMovement behavior)
randomMovement.setup(speed: 40, maxDistance: 96);
randomMovement.run(dt);
```

> **Doc bug:** `docs/mixins.mdx`, `docs/bonfire-4.mdx` and
> `MIGRATION_3_TO_4.md` mention `randomMovement.update(dt, ...)`. The real
> method in `lib/mixins/random_movement/random_movement_api.dart` is
> `run(dt)`, with configuration done through `setup(...)`. Trust the source.

## Rules that prevent most errors

1. `GameComponent` already includes `WithUtil` and `WithAttack` — every
   component has `util` and `attack`, even decorations.
2. `Player` includes `Movement`, `WithLife`, `WithVision`,
   `PlayerControllerListener`, `MovementByJoystick`.
3. `Npc` (base of `SimpleNpc`/`SimpleEnemy`) includes `Movement` + `WithVision`.
4. Mixins with listeners expose `dispose()` internally — do not keep
   references to API objects after `removeFromParent()`.
5. Attack rate limiting is **not** internal anymore: use `IntervalTick` with
   `attack.melee` / `attack.range` inside behaviors or `update`.
6. `life.initial(x)` sets current **and** max; `life.add` caps at max.
7. Prefer `life.handleAttack(origin, damage, id)` for environmental damage —
   it honors `life.receivesAttackFrom`.

## If a method seems missing

1. Check the mixin is on the class (`with WithSensor`, `with WithLifeBar`, ...).
2. Check the API object name in `lib/mixins/` (`with_life.dart` → `life`,
   `with_sensor.dart` → `sensor`).
3. Check `lib/bonfire.dart` to confirm the symbol is exported.
4. Do not invent methods: `grep -rn "class XxxApi" lib/mixins` is faster than
   guessing.

## Migration help in the repo

- `MIGRATION_3_TO_4.md` — full checklist
- `docs/bonfire-4.mdx` — rationale and examples
- `docs/mixins.mdx` — per-mixin documentation
