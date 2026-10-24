---
name: bonfire-getting-started
description: Bootstrap a Bonfire 4.x game (Flutter + Flame) — install the package, declare assets, mount the BonfireWidget, add a Tiled map, a player and input controllers. Use when creating a new Bonfire project, wiring the game widget, or when nothing renders / assets fail to load.
---

# Bonfire — Getting Started (4.x)

Bonfire is an RPG game engine built on top of Flame. You do **not** create a
`FlameGame` yourself: the entry point is the `BonfireWidget`, which builds the
game, the map, the camera and the player for you.

**Target version: Bonfire 4.x.** In 4.x almost every mixin exposes an API
object (`player.jumper.jump()`, `enemy.vision...`, `comp.util...`). If you
remember 3.x APIs, read `bonfire-v4-api` before writing code.

## 1. Install

```yaml
dependencies:
  bonfire: ^4.0.0
  flutter:
    sdk: flutter
```

```dart
import 'package:bonfire/bonfire.dart';
```

## 2. Declare assets

Every image is loaded **relative to `assets/images/`**. Register that folder
(and subfolders you use) in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/images/player/
    - assets/images/tiled/
```

A file at `assets/images/player/knight.png` is referenced as
`'player/knight.png'`. The Tiled map JSON goes in the same tree, e.g.
`assets/images/tiled/map.json` → `'tiled/map.json'`.

## 3. Minimal runnable game

```dart
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: BonfireWidget(
          map: WorldMapByTiled(
            WorldMapReader.fromAsset('tiled/map.json'),
            objectsBuilder: {
              // object layer name in Tiled -> component factory
              'goblin': (TiledObjectProperties p) => Goblin(p.position),
            },
          ),
          player: Knight(Vector2(64, 64)),
          playerControllers: [
            Joystick(directional: JoystickDirectional()),
            Keyboard(), // WASD/arrows on desktop
          ],
          cameraConfig: CameraConfig(
            moveOnlyMapArea: true,
            zoom: getZoomFromMaxVisibleTile(context, 32, 15),
          ),
          lightingColorGame: Colors.black.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
```

`BonfireWidget` is the only required widget. `map` is required; `player`,
`playerControllers`, `interface`, `components`, `hudComponents` and
`cameraConfig` are optional but you normally want at least `player` +
one controller.

## 4. Minimal player

```dart
class Knight extends SimplePlayer {
  Knight(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(32),
          life: 100,
          speed: 100,
          animation: SimpleDirectionAnimation(
            idleRight: PlayerSpriteSheet.idleRight,
            runRight: PlayerSpriteSheet.runRight,
          ),
        );
}

class PlayerSpriteSheet {
  static Future<SpriteAnimation> get idleRight => SpriteAnimation.load(
        'player/knight_idle.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2.all(16),
        ),
      );

  static Future<SpriteAnimation> get runRight => SpriteAnimation.load(
        'player/knight_run.png',
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.1,
          textureSize: Vector2.all(16),
        ),
      );
}
```

Only `idleRight` and `runRight` are required: `SimpleDirectionAnimation`
flips the right animation for the left direction by default
(`enabledFlipX = true`). Add `idleLeft/runLeft` only if the art is not
mirrorable.

## 5. Verify before you say it works

1. `flutter analyze` — no errors.
2. Run the app: the map renders, the joystick appears, the player moves.
3. If the screen is black, check the asset paths and the `assets:` list
   first — a missing image throws on load, it does not fall back silently.

## Pitfalls

- **Do not** `extends FlameGame` and try to add Bonfire components manually.
  Always mount `BonfireWidget`.
- `SimplePlayer` without `animation` renders nothing and movement has no
  visual feedback.
- `size` is the render/hit size; if it does not match the sprite frame ratio
  the art stretches. Use `size: Vector2.all(tileSize)` for tile-based games.
- Tiled maps must be exported as **JSON** (`.json`), not TMX.
- Asset paths never include the `assets/images/` prefix.
- A component added to the world with `gameRef.add(...)` must be added after
  the game is mounted; inside `onLoad`/`onMount` it is safe.
- Don't call `gameRef.player!` blindly — it is nullable and null while the
  player is being removed.

## Reference files in the repo

- `example/lib/pages/mini_games/simple_example/simple_example_game.dart` — widget + map + spawner
- `example/lib/pages/mini_games/top_down_game/top_down_game.dart` — 90° game with lighting
- `example/lib/shared/player/knight.dart` — player with input, attacks, life

## Next skills

`bonfire-player`, `bonfire-map-world`, `bonfire-collision-sensor`,
`bonfire-enemy-ai`, `bonfire-decoration-items`, `bonfire-dialog-ui`.
