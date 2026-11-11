---
name: bonfire-player
description: Build and control the Bonfire player — SimplePlayer / RotationPlayer / PlatformPlayer, sprite animations, joystick and keyboard input, melee and ranged attacks, life, and HUD interface. Use when implementing or fixing player movement, animations, attacks, damage or on-screen controls.
---

# Bonfire — Player (4.x)

`Player` is a `GameComponent` with `Movement`, `WithLife`, `WithVision`,
`PlayerControllerListener` and `MovementByJoystick`. Prefer the ready-made
subclasses; extend `Player` directly only for a custom movement model.

| Class | Perspective | Required animation |
|---|---|---|
| `SimplePlayer` | 45° / 67.5° (RPG) | `SimpleDirectionAnimation(idleRight:, runRight:)` |
| `RotationPlayer` | 90° top-down | `animIdle:`, `animRun:` (rotates to angle) |
| `PlatformPlayer` | side-view platformer | `PlatformAnimations()` + gravity force |

## SimplePlayer

```dart
class Knight extends SimplePlayer with WithCollision {
  Knight(Vector2 position)
      : super(
          position: position,       // required
          size: Vector2.all(32),     // required
          life: 200,
          speed: 100,
          animation: SimpleDirectionAnimation(
            idleRight: PlayerSpriteSheet.idleRight,
            runRight: PlayerSpriteSheet.runRight,
            // optional: idleUp, idleDown, runUp, runDown, diagonals...
          ),
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(size: size / 2, position: size / 4));
    return super.onLoad();
  }
}
```

Movement itself is automatic — the player listens to the controller. You only
hook input to react to actions:

```dart
@override
void onJoystickAction(JoystickActionEvent event) {
  if (event.event == ActionEvent.DOWN && event.id == 1) {
    attack.melee(damage: 20, size: Vector2.all(32));
  }
  super.onJoystickAction(event);
}
```

`event.id` is whatever you set as `actionId` on the `JoystickAction`, or a
`LogicalKeyboardKey` when the input came from `Keyboard()` (the example uses
`LogicalKeyboardKey.space`).

## Attack API

`GameComponent` already mixes `WithAttack`, so every player/enemy has `attack`.

```dart
// melee hitbox in front of the component
attack.melee(
  damage: 20,
  size: Vector2.all(32),
  animation: CommonSpriteSheet.whiteAttackEffectRight,
  withPush: true,
  sizePush: 16,
);

// projectile: creates a FlyingAttackGameObject
attack.range(
  animation: CommonSpriteSheet.fireBallRight,
  animationDestroy: CommonSpriteSheet.explosionAnimation,
  size: Vector2.all(16),
  damage: 30,
  speed: 200,
  useAngle: true, // fire toward the player/current angle
  collision: RectangleHitbox(size: Vector2.all(8)),
);
```

Damage is applied to whatever `WithLife` component the hitbox/projectile hits;
the target decides whether it accepts that origin (`life.receivesAttackFrom`).
Rate-limit repeated attacks with `IntervalTick` — the engine no longer throttles
attacks for you:

```dart
final _attackTick = IntervalTick(400);

void tryAttack(double dt) {
  if (_attackTick.update(dt)) {
    attack.melee(damage: 10, size: Vector2.all(32));
  }
}
```

## Life and damage feedback

```dart
@override
void onMount() {
  life.onDieListener(_onDie);
  life.onRemoveLifeListener((amount) {
    util.showDamage(amount); // floating damage text
  });
  super.onMount();
}

void _onDie() => removeFromParent();

// healing / damage
life.remove(10);
life.add(10);
life.value; // current
life.max;   // max
life.isDead;
```

`life.handleAttack(AttackOriginEnum.ENEMY, damage, id)` applies damage only if
the component accepts that attacker — use it from traps/sensors.

## Input controllers

Pass controllers to `BonfireWidget.playerControllers`:

```dart
playerControllers: [
  Joystick(
    directional: JoystickDirectional(size: 100),
    actions: [
      JoystickAction(
        actionId: 1,
        margin: const EdgeInsets.all(50),
        enableDirection: true, // also reports the action direction
      ),
    ],
  ),
  Keyboard(), // arrows by default; KeyboardConfig(directionalKeys: [KeyboardDirectionalKeys.wasd()])
],
```

To drive another component with the same controller, pass `observer:`.

For a custom control scheme implement `PlayerController` and emit
`JoystickDirectionalEvent` / `JoystickActionEvent`, or add the
`PlayerControllerListener` mixin to a component and register it with
`gameRef.addJoystickObserver(component)`.

## HUD

Two different things:

- **Bar above the character** — add `WithLifeBar` to the component and
  optionally style it:
  ```dart
  class Goblin extends SimpleEnemy with WithLifeBar {
    Goblin(Vector2 p) : super(position: p, size: Vector2.all(32)) {
      lifeBar.setup(borderRadius: BorderRadius.circular(2), borderWidth: 2);
    }
  }
  ```
- **Screen UI** — subclass `GameInterface` and pass it as
  `BonfireWidget(interface: MyInterface())`; add `InterfaceComponent`
  (buttons) and `TextInterfaceComponent` inside `onMount`. See
  `example/lib/shared/interface/knight_interface.dart`.

## Changing animation at runtime

```dart
directionAnimation.replaceAnimation(
  SimpleDirectionAnimation(idleRight: ..., runRight: ...),
);

// one-shot (attack, hurt, emote)
animation.playOnce(
  CommonSpriteSheet.whiteAttackEffectRight,
  onFinish: () => animation.play(SimpleAnimationEnum.idleRight),
  runToTheEnd: true,
);
```

For `RotationPlayer`, assign `animIdle` / `animRun`; for `PlatformPlayer`,
`replacePlatformAnimation(...)`.

## Pitfalls

- `SimpleDirectionAnimation` requires `idleRight` **and** `runRight`; left is
  flipped automatically (`enabledFlipX: true`).
- `speed` is in world units/second, not pixels/frame. A `speed: 100` component
  crosses 100 units per second.
- Player `life` must be initialized through the constructor (`life:` param) or
  `life.initial(...)`; `life.add` alone can never exceed `max`.
- `gameRef.player` is `Player?` — null during teardown.
- Don't mutate `position` by hand for movement; use `moveByAngle` /
  `moveFromDirection` or the controllers, otherwise collision response is skipped.
- In 4.x it is `player.jumper.jump()`, **not** `player.jump()`.

## Repo references

- `example/lib/shared/player/knight.dart`
- `example/lib/pages/player/simple/human.dart`
- `example/lib/pages/player/rotation/human_topdown_player.dart`
- `example/lib/pages/player/platform/simple_fox_player.dart`
- `example/lib/pages/input/` and `example/lib/pages/player_controllers/`
