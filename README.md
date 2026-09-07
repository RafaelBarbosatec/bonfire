[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue.svg)](https://flutter.dev/)
[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://opensource.org/licenses/mit-license.php)
[![pub package](https://img.shields.io/pub/v/bonfire.svg)](https://pub.dev/packages/bonfire)
![GitHub stars](https://img.shields.io/github/stars/RafaelBarbosatec/bonfire?style=flat)
[![pub points](https://img.shields.io/pub/points/bonfire?logo=dart)](https://pub.dev/packages/bonfire/score)
[![Telegram](https://img.shields.io/endpoint?style=flat-square&url=https%3A%2F%2Frunkit.io%2Fdamiankrawczyk%2Ftelegram-badge%2Fbranches%2Fmaster%3Furl%3Dhttps%3A%2F%2Ft.me%2Fbonfire_engine)](https://t.me/bonfire_engine)
[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/rafaelbarbosatec)


[![bonfire](https://raw.githubusercontent.com/RafaelBarbosatec/bonfire/master/media/bonfire.gif)](https://bonfire-engine.github.io/)


# Bonfire

Build **RPG-style games** (and beyond) with the power of [FlameEngine](https://flame-engine.org/)! 🎮

|   |    |
| ------------------- | ------------------- |
| ![](https://raw.githubusercontent.com/RafaelBarbosatec/bonfire/master/media/video.gif) |  ![](https://raw.githubusercontent.com/RafaelBarbosatec/bonfire/master/media/sunnyplace.gif) |
| ![](https://raw.githubusercontent.com/RafaelBarbosatec/bonfire/master/media/multi_biome.gif) | ![](https://raw.githubusercontent.com/RafaelBarbosatec/bonfire/master/media/defector.gif) |


## 📚 Documentation

Complete documentation with examples: [**docs.page/rafaelbarbosatec/bonfire**](https://docs.page/rafaelbarbosatec/bonfire)

## ✨ Features

- 🧙 **RPG-ready components** — `Player`, `Enemy`, `Ally`, `Npc`, `GameDecoration` and a complete `GameComponent` API.
- 🗺️ **Maps** — Tiled map support, multi-map worlds, custom/matrix maps, collisions and portals.
- 🕹️ **Input** — Joystick, keyboard and mouse controls with 8-direction movement.
- ⚔️ **Combat** — melee and ranged attacks, projectiles, damage feedback and life bars.
- 🧠 **Behaviors & AI** — behavior trees (`BSelector`, `BParallel`, `BOnce`), pathfinding, random movement, sensors and vision.
- 🎨 **Effects & polish** — particles, lighting, shaders, camera effects, parallax, color filters and force physics.
- 🖥️ **Game interface** — life bars, dialogs, text effects, minimap and HUD components.
- 📱 **Multi-platform** — mobile, desktop and web with [Flame](https://flame-engine.org/).


## 🎮 Bonfire 4.0 — what's new

Version 4.0 is a **major restructuring of the API surface**, focused on developer experience when building complex game components.

In previous versions each mixin added methods and fields **directly** to the component. With several mixins (`Movement`, `Jumper`, `Sensor`, `PathFinding`, `Pushable`, `RandomMovement`...), the component namespace became crowded and autocomplete less useful.

Starting with 4.0, mixins follow a consistent **`WithFeature` + `feature.{resource}`** pattern:

```dart
class MyEnemy extends SimpleEnemy
    with Movement, WithCollision, WithRandomMovement, WithPathFinding {
  @override
  void update(double dt) {
    super.update(dt);
    randomMovement.update(dt, speed: 20, maxDistance: 64);
  }
}
```

Highlights of the release:

- **API-first mixins** — `WithJumper` (`jumper`), `WithSensor` (`sensor`), `WithRandomMovement` (`randomMovement`), `WithPathFinding` (`pathFinding`), `WithCollision` (`collision`), `WithAttack` (`attack`), `WithVision` (`vision`), `WithLighting` (`lighting`), `WithShader` (`shader`), `WithUtil` (`util`), plus `WithFollower`, `WithPushable`, `WithFlipRender`, `WithMovePerCell`, `WithAssetsLoader` and `WithLifeBar`.
- **Simplified, velocity-based `Movement`** — the only mixin that keeps its direct access style, but was rewritten: `direction`/`hDirection`/`vDirection` now reflect the current velocity, `stop()`/`idle()` replace the old stop helpers and legacy members (`lastDirection`, `stopMove`, `setZeroVelocity`, `moveFromAngle`, `*Once`, `acceleration`...) were removed.
- **Event-driven collision** — `WithCollision` exposes `collision.onBlockMovementListener(...)` and a `bodyType` API instead of the old `BlockMovementCollision` overrides.
- **Direction animations** — `SimplePlayer`/`SimpleEnemy` drive their 8-direction sprite animations (`SimpleDirectionAnimation`) from `direction` automatically.
- **Behavior trees** — brand-new behavior system (`BSelector`, `BParallel`, `BOnce`) with debugging support.
- **Better intervals** — `IntervalTick` replaces the old `InternalChecker`/`checkInterval`.
- **Bug fixes & correctness** — exact diagonal normalization (`sqrt(2)/2`), forces default to no drag, no double damage on `FlyingAttackGameObject`, modern `Color` API (`withValues`).
- **Upgraded to [Flame](https://flame-engine.org/) `^1.38.0`**, with `example/` and `awesome/` updated to the new APIs and analyzed by CI.

> **Migrating from Bonfire 3.x?** Read the [Migration Guide from 3.x to 4.0](MIGRATION_3_TO_4.md) — it has the full breaking-change tables. Every pre-release change is also listed in the [CHANGELOG](CHANGELOG.md).


## 🚀 Getting started

Add Bonfire to your `pubspec.yaml`:

```yaml
dependencies:
  bonfire: ^4.0.0
```

Then create your first map + character and run it inside a `BonfireWidget`. The quickest way to see everything working is to open the bundled **[example app](example/)** — a complete, runnable project with maps, players, enemies, attacks, life bars and interface.

Run it:

```sh
cd example
flutter pub get
flutter run
```

Bonfire is ideal for building games from the following perspectives:

![](https://raw.githubusercontent.com/RafaelBarbosatec/bonfire/master/media/perspectiva.jpg)

Test our online [DEMO](https://bonfire-engine.github.io/examples/bonfire-v3/) or [Download APK](https://raw.githubusercontent.com/RafaelBarbosatec/bonfire/develop/media/example.apk).


## 📚 Documentation

[bonfire-engine.github.io](https://bonfire-engine.github.io)


## 🧩 Bonfire Awesome

[Link](awesome)

If you build a game using Bonfire, you can open a PR to add your game here.


## Useful packages

| Name |  Link  |
|:-----|:--------:|
| bonfire_bloc   | [![pub package](https://img.shields.io/pub/v/bonfire_bloc.svg)](https://pub.dev/packages/bonfire_bloc) |
| bonfire_spine  | [![pub package](https://img.shields.io/pub/v/bonfire_spine.svg)](https://pub.dev/packages/bonfire_spine) |


## Encourage my work

[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86&style=for-the-badge)](https://github.com/sponsors/rafaelbarbosatec)


## Credits

 * The entire [FlameEngine](https://flame-engine.org/) team.
 * And thanks to everyone who contributes and has already contributed.


## Contribution

If you find any errors or want to add improvements, you can open an issue or develop the fix and open a pull request. Thank you for your cooperation!

[Documentation repository](https://github.com/bonfire-engine/bonfire-engine.github.io)
