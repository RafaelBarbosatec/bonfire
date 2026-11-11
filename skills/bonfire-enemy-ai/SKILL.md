---
name: bonfire-enemy-ai
description: Implement Bonfire enemies and NPC AI — SimpleEnemy / RotationEnemy, vision radius, the declarative Behaviors system (chase, attack, flee, random patrol), damage, death and spawning. Use when adding enemies, NPCs, patrols, chase/attack logic or "the enemy does nothing" issues.
---

# Bonfire — Enemies and AI (4.x)

Enemies are `Npc` subclasses (`Movement` + `WithVision` + `WithLife`).
`SimpleEnemy` covers 45°/67.5° RPG views, `RotationEnemy` covers 90°,
`PlatformEnemy` covers side-view.

**Prefer `UseBehavior` over a pile of `if`s in `update()`.** The behavior
manager runs one behavior per frame and keeps internal state
(`BInterval`, `BList`, `BOnce`) — build the list once in a `late final` field.

## 1. Enemy class

```dart
class Goblin extends SimpleEnemy
    with WithCollision, WithLifeBar, WithRandomMovement, UseBehavior {
  Goblin(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(32),
          life: 100,
          speed: 64,
          animation: EnemySpriteSheet.simpleDirectionAnimation,
        ) {
    lifeBar.setup(borderRadius: BorderRadius.circular(2), borderWidth: 2);
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(size: size * 0.8));
    return super.onLoad();
  }

  @override
  void onMount() {
    life.onDieListener(_onDie);
    life.onRemoveLifeListener((amount) => util.showDamage(amount));
    super.onMount();
  }

  void _onDie() {
    gameRef.add(AnimatedGameObject(
      animation: CommonSpriteSheet.smokeExplosion,
      position: position,
      size: Vector2.all(32),
      loop: false,
    ));
    removeFromParent();
  }
}
```

`life` comes from `WithLife` and is initialized by the `life:` constructor
parameter. `Enemy` defaults `receivesAttackFrom` to
`AcceptableAttackOriginEnum.PLAYER_AND_ALLY`.

## 2. Behaviors

```dart
@override
late final List<Behavior> behaviors = [
  BCondition(
    condition: (_, __, game) => game.player != null && game.player!.isDead == false,
    doBehavior: BSeeAndMoveToTarget(
      target: gameRef.player!,
      radiusVision: 64,
      onClose: (dt, _) => execAttack(dt),           // melee when close
      doElseBehavior: BSeeAndPositioned(
        target: gameRef.player!,
        radiusVision: 192,
        positioned: (_, dt) => execAttackRange(dt), // shoot from range
        doElseBehavior: BRandomMovement(speed: speed / 2, maxDistance: 96),
      ),
    ),
    doElseBehavior: BRandomMovement(speed: speed / 2, maxDistance: 96),
  ),
];
```

Contract: `process()` returns `true` = finished (advance), `false` = keep
running this frame. Built-ins:

| Behavior | Purpose |
|---|---|
| `BCondition` | if/else on a predicate |
| `BList` | sequence, advances as each child finishes |
| `BSelector` | runs the first active child each frame |
| `BParallel` | runs all children, finishes when all finish |
| `BAction` | callback every frame (stays active) |
| `BOnce` | callback exactly once |
| `BInterval` | throttles an inner behavior (e.g. attack every 1s) |
| `BCanSee` / `BCanSeeType<T>` | visibility gate |
| `BSeeAndMoveToTarget` | chase + `onClose` callback |
| `BSeeAndPositioned` | keep attack distance + `positioned` callback |
| `BMoveToComponent` | walk to a component |
| `BRandomMovement` | wander inside `maxDistance` |
| `BCustom` | full control via a callback |

Runtime control: `pauseBehaviors()`, `resumeBehaviors()`, `toggleBehavior()`,
`behaviorIsRunning`, `updateBehaviors([...])`, `currentBehaviorId`.
Set `debugBehaviors = true` to log transitions.

## 3. Attack rate

Attacks are not throttled by the engine. Use `IntervalTick` (milliseconds):

```dart
final _meleeTick = IntervalTick(400, tickFirstUpdate: true);

void execAttack(double dt) {
  if (!_meleeTick.update(dt)) return;
  attack.melee(size: Vector2.all(width), damage: 10, sizePush: 8);
}

void execAttackRange(double dt) {
  if (!_rangeTick.update(dt)) return;
  attack.range(
    animation: CommonSpriteSheet.fireBallRight,
    animationDestroy: CommonSpriteSheet.explosionAnimation,
    size: Vector2.all(width * 0.9),
    damage: 10,
    speed: 192,
    useAngle: true,
    collision: RectangleHitbox(size: Vector2.all(width / 2)),
  );
}
```

## 4. Vision (without behaviors)

`Npc` already mixes `WithVision`:

```dart
vision.seePlayer(
  radiusVision: 128,
  visionAngle: 1.5,             // optional cone, radians
  observed: (player) => stop(),
  notObserved: () => resumeMovement(),
);

vision.seeAndMoveToPlayer(closePlayer: (p) => attack.melee(...));
vision.seeAndMoveToAttackRange<Player>(positioned: (p) => attack.range(...));
vision.seeEnemy(observed: (enemies) {...}); // allies
```

Do not run vision every frame when you have many enemies — wrap it in an
`IntervalTick(200..500)`.

## 5. Spawning

- From Tiled: declare an object layer and map its names in
  `WorldMapByTiled(objectsBuilder: {'goblin': (p) => Goblin(p.position)})`.
- At runtime: `gameRef.add(Goblin(position))`.
- Periodically: `ComponentSpawner` with `interval`, `area`, `builder` and
  `spawnCondition` (see `simple_example_game.dart`).
- Query existing instances: `gameRef.query<Goblin>()`.

## Pitfalls

- **Vision-driven enemies only act while visible in the camera.** The
  `vision.seeAndMoveToPlayer` / `seeAndMoveToAttackRange` helpers take
  `runOnlyVisibleInScreen` (default `true`) and return early when the
  component is off-screen. Pass `runOnlyVisibleInScreen: false` if the enemy
  must keep acting outside the viewport (costly with many enemies).
- Don't recreate `behaviors` inside `update()` — state resets every frame.
- `gameRef.player!` can be null before the player mounts; guard it.
- `util.showDamage(amount)` is the idiomatic floating damage number; don't
  draw it manually.
- `WithLifeBar` requires `WithLife` (it is `mixin WithLifeBar on WithLife`).
- An `Enemy` defaults to receiving damage only from player/ally attacks; use
  `receivesAttackFrom` if your traps must hurt it.
- Behavior closures capture `gameRef.player!` at list creation — if the player
  can be replaced, reference `gameRef.player` inside the callback instead.

## Repo references

- `example/lib/shared/enemy/goblin.dart` — full behaviors AI + melee/range
- `example/lib/pages/mini_games/simple_example/my_enemy.dart`
- `example/lib/pages/mini_games/top_down_game/robot_enemy.dart`
- `example/lib/shared/npc/wizard/wizard.dart` — NPC with dialog
