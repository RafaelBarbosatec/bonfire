---
name: bonfire-dialog-ui
description: Build Bonfire dialogs and screen UI — TalkDialog with Say lines, camera zoom during conversations, GameInterface HUD with buttons and text, TypeWriter text, and MiniMap. Use when adding NPC conversations, on-screen buttons/life bars, or typewriter text.
---

# Bonfire — Dialogs and UI (4.x)

Two layers, two tools:

| Layer | Tool |
|---|---|
| Conversation / narrative box | `TalkDialog.show(context, [...])` |
| Persistent screen UI (HUD) | `GameInterface` + `InterfaceComponent` |

## 1. TalkDialog

```dart
TalkDialog.show(
  gameRef.context,
  [
    Say(
      text: [const TextSpan(text: 'Would you tell me which way I ought to go?')],
      person: SizedBox(
        width: 100,
        height: 100,
        child: PlayerSpriteSheet.idleRight.asWidget(),
      ),
    ),
    Say(
      text: [const TextSpan(text: 'That depends on where you want to get to.')],
      person: SizedBox(
        width: 100,
        height: 100,
        child: WizardSpriteSheet.idle.asWidget(),
      ),
      personSayDirection: PersonSayDirection.RIGHT,
    ),
  ],
  onFinish: () => debugPrint('dialog finished'),
  onClose: () => debugPrint('dialog dismissed'),
  dismissible: true,
  logicalKeyboardKeysToNext: [LogicalKeyboardKey.space, LogicalKeyboardKey.enter],
  talkAlignment: Alignment.bottomCenter,
  speed: 50, // ms per character
);
```

Signature highlights:

```dart
static Future<T?> TalkDialog.show<T>(
  BuildContext context,
  List<Say> sayList, {
  VoidCallback? onFinish,
  VoidCallback? onClose,
  ValueChanged<int>? onChangeTalk,
  Color? backgroundColor,
  double boxTextHeight = 100,
  List<LogicalKeyboardKey> logicalKeyboardKeysToNext = const [],
  EdgeInsetsGeometry? padding,
  bool dismissible = false,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  Alignment talkAlignment = Alignment.bottomCenter,
  TextStyle? style,
  int speed = 50,
});
```

`Say` fields: `text` (List<TextSpan>, required), `person`, `personSayDirection`,
`background`, `header`, `bottom`, `boxDecoration`, `padding`, `margin`, `speed`.

Typical NPC flow (from `wizard.dart`): move the camera in, then open the dialog:

```dart
void execShowTalk(GameComponent target) {
  final lastZoom = gameRef.camera.zoom;
  gameRef.camera.moveToTargetAnimated(
    target: target,
    effectController: EffectController(duration: 0.5, curve: Curves.easeInOut),
    zoom: 2,
    onComplete: _showTalk,
  );
}
```

To freeze the player during a dialog, `stop()` the player and guard input
methods while the dialog is open; restore with `gameRef.camera.moveToPlayerAnimated(...)`.

## 2. TypeWriter

Standalone widget that reveals a `List<TextSpan>` progressively — good for
dialog boxes you build yourself or overlay screens:

```dart
TypeWriter(
  text: [const TextSpan(text: 'Loading the dungeon...')],
  speed: 50,           // ms per character
  autoStart: true,
  style: const TextStyle(color: Colors.white, fontSize: 16),
  onFinish: () => debugPrint('done'),
)
```

## 3. GameInterface (HUD)

`GameInterface` is a `GameComponent` rendered in the HUD priority layer.
Subclass it and add children in `onMount`:

```dart
class MyHud extends GameInterface {
  @override
  void onMount() async {
    await add(InterfaceComponent(
      id: 1,
      size: Vector2(48, 48),
      position: Vector2(200, 20),
      spriteUnselected: Sprite.load('ui/button.png'),
      spriteSelected: Sprite.load('ui/button_pressed.png'),
      selectable: true,
      onTapComponent: (selected) {
        (gameRef.player as Knight).execShowEmote();
      },
    ));

    await add(TextInterfaceComponent(
      id: 2,
      position: Vector2(20, 20),
      text: 'Coins: 0',
      textConfig: const TextStyle(color: Colors.white, fontSize: 18),
    ));
  }
}
```

Mount it with `BonfireWidget(interface: MyHud())`.

- `InterfaceComponent` = sprite button; `selectable: true` keeps the pressed
  state until tapped again.
- `TextInterfaceComponent` has zero size and paints text at `position`.
- Components added to the interface are not affected by the camera.
- For custom widgets (Flutter UI, not canvas), use `overlayBuilderMap` +
  `initialActiveOverlays` on `BonfireWidget`.

## 4. MiniMap

```dart
BonfireWidget(
  overlayBuilderMap: {
    'miniMap': (context, game) => MiniMap(
          game: game,
          size: Vector2(120, 120),
          margin: const EdgeInsets.only(top: 16, right: 16),
          borderRadius: BorderRadius.circular(8),
          playerColor: Colors.green,
          enemyColor: Colors.red,
        ),
  },
  initialActiveOverlays: const ['miniMap'],
)
```

## Pitfalls

- `TalkDialog.show` uses `showDialog` — it needs a `BuildContext`
  (`gameRef.context`). Do not call it before the first frame.
- `Say.text` is `List<TextSpan>`, **not** a `String`.
- `person` is a `Widget`; use `SpriteAnimation.asWidget()` to animate it.
- A dialog does not pause the game by itself. Stop movement/AI explicitly if
  that is the intent (and resume on `onClose`/`onFinish`).
- `GameInterface` children must be `InterfaceComponent`-like HUD components;
  regular game components added there are drawn in screen space.
- Overlay builders receive `BonfireGame`, not `BonfireGameInterface`.
- Don't hold a stale `BuildContext` across async gaps when opening dialogs.

## Repo references

- `example/lib/shared/npc/wizard/wizard.dart` — camera + dialog
- `example/lib/shared/player/player_dialog.dart`
- `example/lib/shared/interface/knight_interface.dart` — HUD buttons
- `example/lib/pages/mini_games/tiled_map/game_tiled_map.dart` — minimap comment
