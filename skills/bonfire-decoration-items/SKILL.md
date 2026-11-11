---
name: bonfire-decoration-items
description: Add Bonfire decorations and interactive objects — sprites and animations, tap/drag gestures, pickups, chests, torches, visual effects, particles and lighting. Use when adding scenery, consumables, interactive props, torches/light sources or hit/explosion effects.
---

# Bonfire — Decorations, Items and Effects (4.x)

`GameDecoration` is an `AnimatedGameObject`: a component that renders a sprite
or animation and can interact with the player. It is the base for scenery,
pickups, chests, torches and NPC-like props.

## 1. Creating decorations

```dart
// static sprite
GameDecoration.withSprite(
  sprite: Sprite.load('itens/crate.png'),
  position: Vector2(100, 100),
  size: Vector2.all(32),
)

// animated
GameDecoration.withAnimation(
  animation: SpriteAnimation.load(
    'itens/chest.png',
    SpriteAnimationData.sequenced(
      amount: 8,
      stepTime: 0.1,
      textureSize: Vector2.all(16),
    ),
  ),
  position: position,
  size: Vector2.all(32),
)
```

Subclass it when you need state:

```dart
class Chest extends GameDecoration with TapGesture, WithVision {
  bool _observedPlayer = false;
  final _tick = IntervalTick(500);

  Chest(Vector2 position)
      : super.withAnimation(
          animation: CommonSpriteSheet.chestAnimated,
          position: position,
          size: Vector2.all(32),
        );

  @override
  void update(double dt) {
    if (gameRef.player != null && _tick.update(dt)) {
      vision.seeComponent(
        gameRef.player!,
        radiusVision: 32,
        observed: (_) => _observedPlayer = true,
        notObserved: () => _observedPlayer = false,
      );
    }
    super.update(dt);
  }

  @override
  void onTap() {
    if (!_observedPlayer) return;
    gameRef.add(PotionLife(position.translated(16, 16), 30));
    removeFromParent();
  }

  @override
  void onTapCancel() {}
}
```

## 2. Gestures

```dart
class Lever extends GameDecoration with TapGesture { ... }

class Rock extends GameDecoration with DragGesture { ... }
```

`TapGesture` callbacks: `onTapDown(GestureEvent) -> bool`, `onTapUp`,
`onTapCancel`, `onTap`, plus screen-level `onTapDownScreen` / `onTapUpScreen`.
`DragGesture` provides `startDrag`, `moveDrag`, `endDrag`; adding the mixin is
enough to make the component draggable.

## 3. Pickups with sensors

Use `WithSensor<T>` so the player can walk over the item (no blocking):

```dart
class PotionLife extends GameDecoration with WithSensor<Player> {
  final double life;

  PotionLife(Vector2 position, this.life)
      : super.withSprite(
          sprite: CommonSpriteSheet.potionLifeSprite,
          position: position,
          size: Vector2.all(16),
        ) {
    sensor.onContactListener((player) {
      player.life.add(life);
      removeFromParent();
    });
  }
}
```

For a floating/bobbing effect attach a Flame effect in `onMount` or animate
`spriteOffset` with `gameRef.generateValues(...)` (see the repo example).

## 4. One-shot visual effects

`AnimatedGameObject` is the right tool for explosions, smoke, hit sparks:

```dart
gameRef.add(
  AnimatedGameObject(
    animation: CommonSpriteSheet.smokeExplosion,
    position: position,
    size: Vector2.all(32),
    loop: false, // removes itself when the animation ends
  ),
);
```

For generic tweens use Flame effects (re-exported by Bonfire):

```dart
add(ScaleEffect.by(Vector2.all(1.5), EffectController(duration: 0.5, alternate: true, infinite: true)));
add(OpacityEffect.fadeOut(EffectController(duration: 1), onComplete: removeFromParent));
```

## 5. Lighting

Enable the ambient darkness (the layer that lights cut holes in) on the widget:

```dart
BonfireWidget(lightingColorGame: Colors.black.withValues(alpha: 0.7), ...)
```

Then any `GameObject` (and therefore any `GameDecoration`) can be a light
source through the `lightingConfig:` constructor parameter — the `lighting` API
is already mixed in:

```dart
class Torch extends GameDecoration {
  Torch(Vector2 position)
      : super.withSprite(
          sprite: Sprite.load('itens/torch.png'),
          position: position,
          size: Vector2.all(16),
          lightingConfig: LightingConfig(
            radius: 96,
            color: Colors.orange.withValues(alpha: 0.4),
            blurBorder: 20,             // MaskFilter blur edge
            type: LightingType.circle,  // also .arc / .rect(size) / .polygon(points)
            align: Vector2(0, -6),      // offset from the component center
          ),
        );
}
```

Components that are not a `GameObject` (players, enemies, custom components)
become lights with `with WithLighting` + `lighting.setup(LightingConfig(...))`,
or by creating a detached `LightSource`.

Common variations:

```dart
// Soft gradient edge instead of blur, with a full-intensity core
LightingConfig(
  radius: 120,
  color: Colors.orange,
  falloff: LightFalloff.linear, // or .smooth
  innerRadius: 0.45,
  intensity: 0.8,               // multiplies the color alpha
)

// Emissive light (glow added on top, readable even with no ambient darkness)
LightingConfig(radius: 84, color: Colors.cyan, mode: LightingMode.additive)

// Candle behaviour
LightingConfig(
  radius: 96,
  color: Colors.orange,
  withPulse: true, pulseVariation: 0.12, pulseCurve: Curves.easeInOut,
  flicker: const LightFlicker(frequency: 2, amplitude: 0.05, seed: 3),
)
```

**Shadows.** Set `castShadows: true` on the light and register what blocks it:

```dart
// static geometry (walls), in world coordinates
gameRef.lighting.addOccluder(LightingOccluder.rect(Rect.fromLTWH(64, 32, 16, 96)));
gameRef.lighting.quality = LightingQuality.high; // low 24 / medium 64 / high 160 rays
gameRef.lighting.debug = true;                   // light outline, shadow clip, occluders
```

Moving obstacles use the `WithLightingOcclusion` mixin (`lightingOccluders`
getter). With Tiled maps, declare the occluders in the map instead of in code:
a tile/object layer (or object) with class `lighting_occluder` is registered by
`WorldMapByTiled` automatically. In an object layer you can combine roles:

```text
collision,lighting_occluder
```

**Ambient presets and transitions:**

```dart
LightingPreset.night.apply(gameRef.lighting);      // day | dusk | night | dungeon
gameRef.lighting.animateToColor(Colors.blue.withValues(alpha: 0.7));
gameRef.lighting.fadeOut();                        // back to a fully lit scene
```

**Detached lights** (explosions, muzzle flashes) do not need a component:

```dart
final light = gameRef.lighting.addLight(
  LightSource(position: position, config: LightingConfig(radius: 170, color: Colors.white)),
);
gameRef.lighting.removeLight(light);
```

`lighting.enabled = false/true` toggles a component light at runtime. Projectiles
also accept `lightingConfig:` in `attack.range(...)`. Lights follow the camera
transform, so they stay aligned when the camera is rotated.

Color filter: `gameRef.colorFilter.animateTo(Colors.red, blendMode: BlendMode.colorBurn)`.

## 6. Spawning items over time

```dart
ComponentSpawner(
  position: position,
  area: area,             // required spawn area (ShapeHitbox)
  interval: 500,          // ms
  builder: (pos) => PotionLife(pos, 5),
  spawnCondition: (game) => game.query<PotionLife>().length < 10,
)
```

Query components at runtime with `gameRef.query<T>()`.

## Pitfalls

- Decorations render sorted by their Y position (`priority`); if a prop covers
  the player incorrectly, adjust its `position`/`size`, not `renderAboveComponents`
  (that flag is for HUD-like overlays).
- `GameDecoration` has no life or hitbox by default — add `WithLife` /
  `RectangleHitbox` explicitly if it must be damageable.
- Remove one-shot effects/components with `removeFromParent()`; leaving them
  alive leaks animations.
- Sprites are loaded through Bonfire's asset loader (`assets/images/` prefix).
- Cutout lights (the default `LightingMode.cutout`) only show when there is
  ambient darkness (`lightingColorGame`); `LightingMode.additive` glows even
  without it.
- Don't instantiate `Sprite.load` in `render()`; load once (constructor or
  static getter).

## Repo references

- `example/lib/shared/decoration/chest.dart`
- `example/lib/shared/decoration/potion_life.dart`
- `example/lib/shared/decoration/torch.dart`
- `example/lib/shared/decoration/barrel_dragable.dart`
- `example/lib/pages/lighting/` and `example/lib/pages/shader/`
