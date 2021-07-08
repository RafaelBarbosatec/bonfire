# 1.2.2
- improvements in `constructionMode`
- improvements in `drawDefaultLifeBar`
- performance improvements

# 1.2.1
- improvements in `TiledWorldMap`
- add property `backgroundColor` in `TalkDialog`.
- performance improvements in `TiledWorldMap`

# 1.2.0
- add `MouseGesture` mixin to listen mouse gestures see [documentation](https://bonfire-engine.github.io/#/gestures?id=mousegesture)
- add method `worldPositionToScreen` in `BonfireGame`.
- add method `screenPositionToWorld` in `BonfireGame`.
- add method `isVisibleInCamera` in `BonfireGame`.

# 1.1.7
- Improvements in `TextInterfaceComponent`
- Improvements in `GameComponent`
- Improvements in `SimpleDirectionAnimation`

# 1.1.6
- update `tiledjsonreader`
- update `flame`
- Improvements in `SimpleDirectionAnimation`
- Improvements in `generateRectWithBleedingPixel`


# 1.1.5
- blocks paths off screen in `MoveToPositionAlongThePath`
- create function `overlap` to `Image`.

# 1.1.4
- new improvements in `MoveToPositionAlongThePath`

# 1.1.2
- Update `tiledjsonreader`
- Improvements in `MoveToPositionAlongThePath`
- Fix bug of the issue [#115](https://github.com/RafaelBarbosatec/bonfire/issues/115)

# 1.1.1

- Fix bug `TalkDialog`.
- Fix bug Animations in `SimplePlayer` and `SimpleEnemy`.

# 1.1.0

- Update `Flame` to `1.0.0-releasecandidate.11` version.
- [BREAKING CHANGE] improvements in `objectsBuilder` and `registerObject` to register objects in `TiledWorldMap`.
    ```dart
      TiledWorldMap(
        'tiled/map.json',
        forceTileSize: Size(32, 32),
        objectsBuilder: {
          'goblin': (ObjectProperties properties) => Goblin(properties.position),
          'torch': (ObjectProperties properties) => Torch(properties.position),
          'barrel': (ObjectProperties properties) => BarrelDraggable(properties.position),
          'spike': (ObjectProperties properties) => Spikes(properties.position),
          'column': (ObjectProperties properties) => ColumnDecoration(properties.position),
          'chest': (ObjectProperties properties) => Chest(properties.position),
        },
      )
    ```
- [BREAKING CHANGE] change `TextConfig` to `TextPaintConfig`
- adds method `tilePropertiesBelow()` and `tilePropertiesListBelow()` in GameComponent to access proprieties of the tile set in Tiled.
- adds method `void onCollision(GameComponent component, bool active)` in `ObjectCollision`. Now you can override this method to listen what Component enter in collision.
- improvements in `BonfireGame`
- improvements in `TalkDialog`.


# 1.0.3

- Adds type `above` in tiled to render above components
- update `tiledjsonreader`
- improvements in `Camera`
- Adds param `objectsBuilder` in `TiledWorldMap`
- others improvements

# 1.0.2

- Downgrade flame version to 1.0.0-rc9

# 1.0.1

- Fix `SimpleDirectionAnimation`

# 1.0.0

- Rename `gameCamera` to `camera`
- Add [JoystickMoveToPosition](https://bonfire-engine.github.io/#/joystick?id=joystickmovetoposition)
- Add mixin `MoveToPositionAlongThePath` and `Movement`

# 1.0.0-rc8

- Improvements in `SimpleDirectionAnimation`
- Improvements in `Collision`
- Update `http`

# 1.0.0-rc7

- fix bug animation to up in `SimpleEnemy`

# 1.0.0-rc6

- remove comments in `FlyingAttackAngleObject` (bug)
- improvements in `Camera`.

# 1.0.0-rc5

- Rename params in `simpleAttackMelee`
- new improvements to use `TapGesture` and `DragGesture` together.
- improvements in `Joystick`(KEYBOARD) to adds diagonal movement with directional.
- improvements in `moveToPosition` of the Player.

# 1.0.0-rc4

- BREAKING CHANGE: add Shapes(circle,rectangle,polygon) to use collisions.
- fix to use `TapGesture` and `DragGesture` together.
- Improvements in mixin `Sensor`.
- Improvements in `TalkDialog`.

# 1.0.0-rc3

- Improvement in `simpleAttackMelee`
- Improvement in `InterfaceComponent` when `selectable` enable


# 1.0.0-rc2

- Improvement in layer priority.
- Improvement in `Camera` when `moveOnlyMapArea` enable.
- Fix bug `animation.playOnce` in Player and Enemy
- Fix bug `addAction` in `Joystick`
- Fix bug `seePlayer` in `GameDecoration`

# 1.0.0-rc1

- Fix bug in `cameraMoveOnlyMapArea`
- Add `CameraConfig` in `BonfireTiledWidget` and `BonfireWidget`

# 1.0.0-rc0

- Update Flame to [1.0.0-rc9](https://pub.dev/packages/flame/versions/1.0.0-rc9/changelog)
- Add null-safety
- Add support to use overlays of the Flame.
- BREAKING CHANGE: All params `Sprite` in components become `Future<Sprite>`.
- BREAKING CHANGE: All params `Animation` in components become `Future<SpriteAnimation>`.
- BREAKING CHANGE: To configure `Lighting`  use `setupLighting(LightingConfig())`.
- BREAKING CHANGE: Removed the `Position` class. Now use `Vector2`.
- WARN (Render priority): The only components that have fixed rendering priority are: `MapGame` and` BackgroundColorGame`. All others render with priority according to the component's position on the Y axis.
- Update support tiled to 1.5.0.
- Rename enum values in `Direction`.
- Rename values in `SimpleDirectionAnimation`.
- Improvements in `InterfaceComponent`. Now can be selectable.
- Others improvements.

# 0.9.0

- BREAKING CHANGE: Collision system. Remove param `collision` from Enemy, Player and GameDecoration. If you need add collision in your component
use the mixin 'Collision' and settings your properties using 'setupCollision()' method.

# 0.8.6

- update dependencies an README.

# 0.8.5

- update Flame to `0.29.3`.

# 0.8.4

- update Flame to `0.29.2`.
- add joystick `TouchToPosition`.

# 0.8.3

- improvements in `BonfireTiledWidget`.

# 0.8.2

- Fix camera zoom-out.

# 0.8.1

- Fix issue [#79](https://github.com/RafaelBarbosatec/bonfire/issues/79).
- Improvements in mixin `Attackable`. It is now possible to determine from whom you can take damage (player, enemy, all) using `receivesAttackFrom`.
- Improvements in mixin `ObjectCollision`.
It is now possible to enable and disable collision with the player and enemies using `collisionWithEnemy` and `collisionWithPlayer`.

# 0.8.0

- Fix issue [#79](https://github.com/RafaelBarbosatec/bonfire/issues/79).
- Fix Handle gestures to take into account the camera zoom.
- Adds basic implementation suggested in issue [#64](https://github.com/RafaelBarbosatec/bonfire/issues/64). Moving the player based on touch. To do this, use `TouchToPosition()` in `Joystick`.

# 0.7.7

- add resize in `InterfaceComponent`
- add param `components` in `BonfireTiledWidget` and `BonfireWidget`
- disable `isAntiAlias` in render `tile` in map.
- update flame to `0.28.0`

# 0.7.6

- add `maxDownSize` in `TextDamageComponent`
- update CHANGELOG

# 0.7.5

- Fix collision in GameDecoration.
- Update Flame to 0.27.0

# 0.7.4

- makes Sprite public in GameDecoration
- update `id` to dynamic in `receiveDamage`  and `JoystickAction`.

# 0.7.3
- hotfix: notify finish in `AnimatedObjectOnce`.
- update `id` to dynamic in `receiveDamage`  and `JoystickAction`.

# 0.7.2
- hotfix render last frame in `AnimatedObjectOnce`.

# 0.7.1
- makes `lighting` accessible through the `gameRef`.
- create `FollowerObject`.

# 0.7.0
- BREAKING CHANGE: improvement in animations to SimplePlayer and SimpleEnemy. Now use `SimpleDirectionAnimation` to manipulate animations.
- add `GameColorFilter`. It is now possible to add color filter in the game.
- Possible to load maps made by Tiled from url. Just pass the link as path.

# 0.6.27
- little performance improvement;
- remove mandatory joystick in widget;
- remove param gameComponent in `LightingConfig`;

# 0.6.26
- improvements image cache in map load by Tiled;

# 0.6.25
- fix `tileTypeBelow()` and add `tileTypesBelow()`;

# 0.6.24
- add method `tileTypeBelow()` in `GameComponent` to get type tile;
- improvements in gestures mixin;

# 0.6.23
- improvement in map.
- BREAKING CHANGE: remove param `isSensor` from `GameDecoration` an create mixin `Sensor`.
- update example (Potion,Spikes).

# 0.6.22
- fix update Camera.

# 0.6.21
- improvement in camera system.
- update flame.

# 0.6.20
- Add mixin `Attackable`.

# 0.6.19
- Fix issue [#55](https://github.com/RafaelBarbosatec/bonfire/issues/55)
- Update Flame to 0.25.0

# 0.6.18
- BREAKING CHANGES: change `forceTileSize` type double to Size.
- Add support to offsetX and offsetY in TileMap layers.

# 0.6.17
- hotfix Tiled - Support multiTileset.

# 0.6.16
- improvement in JoystickActions
- improvement in seeAndMoveToPlayer (Enemy)

# 0.6.15
- improvement in `seeEnemy` and `seePlayer`
- BREAKING CHANGES: rename prams `visionCells` to `radiusVision` in `seeEnemy` and `seePlayer`

# 0.6.14
- hotfix extension simpleAttackMeleeByDirection and simpleAttackMelee

# 0.6.13
- improvements in TiledWorldMap.
- BREAKING CHANGES: rename prams with `animation` to `anim` in SimpleEnemy.
- BREAKING CHANGES: rename mixin `WithLighting` to `Lighting`.
- BREAKING CHANGES: rename param `tiledMap` to `map` in BonfireTiledWidget.
- add animIdleTopLeft, animIdleBottomLeft, animIdleTopRight, animIdleBottomRight in SimplePlayer and SimpleEnemy.
- add `transitionBuilder` in BonfireTiledWidget if desired to add a custom display animation
- add `durationShowAnimation` in BonfireTiledWidget

# 0.6.12
- add diagonal in Direction(enum).

# 0.6.11
- hotfix addFastAnimation.

# 0.6.10
- hotfix addFastAnimation.

# 0.6.9
- update extensions.
- add animation in diagonal in SimpleEnemy and SimplePlayer.
- add extensions getAnimation and getSprite in Image (dart:ui).

# 0.6.8
- improvements show FPS
- update example
- update extensions enemy.
- update Flame.

# 0.6.7
- hotfix seeAndMoveToAttackRange.

# 0.6.6
- Add zoom in moveToPlayerAnimated and moveToPositionAnimated.
- improvements in seeAndMoveToAttackRange.
- add animation show map when load TiledMap.

# 0.6.5
- Optimizations when loading maps built with Tiled

# 0.6.4
- add Zoom camera by [rezendegc](https://github.com/rezendegc).
- improvements TiledObjects.
- improvements Joystick.

# 0.6.3
- hotfix Tiled with tile null in TileSet.

# 0.6.2
- hotfix render.

# 0.6.1
- add [Tiled](https://www.mapeditor.org/) json support (BonfireTiledWidget)
- BREAKING CHANGES: gestures improvements (now use mixin TapGesture or DragGesture)
- BREAKING CHANGES: align collision
- add support drag gestures
- add support multiCollision to Decoration and Tile.
- add support Tile animated.

# 0.5.1
- hotfix in FlyingAttackObject
- adds sensor functionality to GameDecoration

# 0.5.0
- BREAKING CHANGES: remove 'positionInWorld', everything uses 'position' now.
- improvements in Camera system by [rezendegc](https://github.com/rezendegc)
- improvements in JoystickDirectional

# 0.4.2
- improvements in TextDamage
- performance improvements

# 0.4.1
- add lightingConfig in extensions

# 0.4.0
- BREAKING CHANGES in joystick and player in 'void joystickAction(JoystickActionEvent event)'
- adds support for direction in actions of the joystick
- adds support for basic lighting
- update Flame to 0.21.0
- performance improvements

# 0.3.3

- Improvements in FlyingAttackAngleObject.
- Fix bug issue #22.

# 0.3.2

- Fix bug extension enemy.

# 0.3.1

- Update Flame.
- Add identify in attacks.

# 0.3.0 [ BREAKING CHANGE ]

- Improvements render components
- the Player was dismembered in Player(base) ,SimplePlayer(similar old Player) and RotationPlayer
- the Enemy was dismembered in Enemy(base) ,SimpleEnemy(similar old Player) and RotationEnemy
- created FlyingAttackAngleObject
- add 'rotateRadAngle' in AnimatedObjectOnce

# 0.2.12

- Improvements on the JoystickKeyBoard.

# 0.2.11

- Improvements change size map

# 0.2.10

- Fix bug player;

# 0.2.9

- Fix bug player update

# 0.2.8

- change of speed parameter to points / seconds.

# 0.2.7

- improvements pointer detector.

# 0.2.6

- improvements bleeding pixel.
- add support web in example

# 0.2.5

- Flutter Web test.

# 0.2.4

- add bleeding pixel in GameDecoration.sprite and GameDecoration.animation.

# 0.2.3

- Fix bug Joystick fixed

# 0.2.2

- Improvements Joystick
    - better sensitivity
    - possibility of obtaining intensity
    - possibility of obtaining angle
- Improvements player movement windows
- Improvements enemy movement
- Add TextInterfaceComponent
- Add bleeding pixel in decorations

# 0.2.0

- Improvements in GameInterface (now it’s easier to add elements with 'InterfaceComponent')
- Improvements in Joystick
- Update readme

# 0.1.11

- add customize collisionAreaColor and constructionModeColor
- Improvements player

# 0.1.10

- add constructor Tile.fromSprite
- add constructor GameDecoration.sprite
- add constructor GameDecoration.animation

# 0.1.9

- remove scaffold in BonfireWidget

# 0.1.8

- update flame to 0.19.1.
- add bleeding pixel in map.
- modify parameter sprite in decoration.

# 0.1.7

- add margin in seeAndMoveToPlayer(Extension enemy).

# 0.1.6

- Improvements in enemy.

# 0.1.5

- Improvements in enemy movements.
- Improvements in map resize.

# 0.1.4

- Update Flame.
- Improvements in BonfireWidget.
- Add onTapDown, onTapUp, onTapMove, onTapCancel in components isTouchable = true

# 0.1.3

- Improvements in player and enemy extensions.
- Add GameController.

# 0.1.2

- Improvements in player and enemy extensions.
- Add ShowAreaCollision.

# 0.1.1

- Improvements in gestures.
- Improvements in joystick.
- Decorations can now be touched.

# 0.1.0

- First version stable! Possible to create complete games like this: https://github.com/RafaelBarbosatec/darkness_dungeon
- Update readme and demo.

# 0.0.16

- Update extensions enemy and player

# 0.0.15

- Add callback destroyedObject in FlyingAttackObject
- Add TalkDialog to create your conversation.

# 0.0.14

- Improvements collision
- Improvements collision decoration

# 0.0.13

- Fix bug collision decoration

# 0.0.12

- Update Readme
- Improvements in draw grid

# 0.0.11

- Add draw grid tiles in constructionMode.
- Improvements in FlyingAttackObject

# 0.0.10

- Add constructionMode. (HotReload update game too)

# 0.0.9

- Map size improvements

# 0.0.8

- Collision system improvements
- Add 'drawPositionCollision(Canvas canvas)'

# 0.0.7

- Add MapExplorer when not set Player
- Add BackgroundGame

# 0.0.6

- Fix bug FlyingAttackObject.

# 0.0.5

- Add camera movements.
- Fix delay between map and components.
- Update readme.

# 0.0.4

- Organization improvements.
- Update readme.

# 0.0.3

- Add AnimatedFollowerObject and 'seeEnemy' in player.
- Update readme.

# 0.0.2

- Update readme.

# 0.0.1

- Starts project with basic mechanics.
