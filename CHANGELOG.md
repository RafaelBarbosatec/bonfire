# 3.16.1
- Performance improvements

# 3.16.0
- Update flame to 1.32.0

# 3.15.1
- Fix textSize in `BarLifeComponent`
- `FlyingAttackGameObject` improvements


# 3.15.0
- Adds params `collisionConfig`. Now collision system used is a default. take a look [Flame Doc](https://docs.flame-engine.org/latest/flame/collision_detection.html). To use QuadTree approatch pass `BonfireCollisionConfig.quadTree()` as a params.

# 3.14.0
- Performance improvements.

# 3.13.5
- Fix ellipse and polygon collision objects in Tiled maps, the `CollisionType` was set to `inactive`, changed to `active` as the `RectangleHitbox`.
- Fiz padding in `BarLifeComponent`

# 3.13.4
- Fix size in `setupLifeBar`

# 3.13.3
- rollback to deprecated colors

# 3.13.2
- Collision performance improvements

# 3.13.1
- BarLifeComponent improvements
- rename extension method `directionThatPlayerIs` to `getDirectionToPlayer`, `getAngleFromPlayer` to `getAngleToPlayer`, `getInverseAngleFromPlayer` to `getInverseAngleToPlayer`.
- Back flame version to `1.18.0` :-(.

# 3.13.0
- Update Flame to `1.23.0`.

# 3.12.6
- Fix `RangerError`.

# 3.12.5
- Update `a_star_algorithm`.
- InitialMapZoomFitEnum improvements

# 3.12.4
- Switched to declarative mode to apply Grandle plugins

# 3.12.3
- `RandomMovement` improvements

# 3.12.1
- Resolve the alignment and visibility issues when using the MiniMap widget with non-1.0 zoom values. Thanks [qulvmp6](https://github.com/qulvmp6)
- Adds `randomMovementArea` param in `RandomMovement` mixin.

# 3.12.0
- Adds `UseShader` mixin.

# 3.11.0
- Adds `MapNavigator`. Structure to facilitate map navigations.
- Update `MultiScenario` example to use `MapNavigator`.
- Some optimizations.

# 3.10.6
- Update `tiledjsonreader`

# 3.10.5
- Adds param `withDiagonal` in `setupPathFinding` (PathFinding mixin)
- Fix PathFinding bug. Now not consider your own collision as a barrier.

# 3.10.4
- Update `tiledjsonreader` to support web platform
- `DirectionAnimation` improvements

# 3.10.3
- Clean up componentes when game will removed. `onRemove`.

# 3.10.2
- Downgrade to Flame v1.18.0 (Crash in package 'ordered_set')

# 3.10.1
- Update Flame to v1.19.0

# 3.10.0
- BREAKING CHANGE: Bump Flutter SDK minimum version to 3.22.0
- Upgrade: Packages (flame v1.18.0, http v1.2.2, a_star_algorithm v0.3.2).
- Adds new SceneActions

# 3.9.9
- Bugfix/MatrixLayer axisInverted. [#535](https://github.com/RafaelBarbosatec/bonfire/pull/545)
- Makes it possible to set 'axisInverted' in `MatrixLayer` constructor.

# 3.9.8
- Fix bug when hitbox anchor is center.
- BREAKING CHANGE: Update `bool receiveDamage` to `void onReceiveDamage`. Now to perform receive of attack use `handleAttack` method.

# 3.9.7
- Update `tiledjsonreader`
- Bugfix/tile rotation collision. [#535](https://github.com/RafaelBarbosatec/bonfire/pull/535)
- Adds 'currentIndex' and 'fastAnimationcurrentIndex' in `SimpleDirectionAnimation`.

# 3.9.6
- Fix jump animation showing instead of run/idle animation on slanting floors
- Fix above layer bug [#532](https://github.com/RafaelBarbosatec/bonfire/issues/532)
- Fix tile rotation bug. [#531](https://github.com/RafaelBarbosatec/bonfire/issues/531) [#530](https://github.com/RafaelBarbosatec/bonfire/issues/530)

# 3.9.5
- Fix Joystick bug when viewport is fixed resolution. [#526](https://github.com/RafaelBarbosatec/bonfire/issues/526)
- Add guard in `FlyingAttackGameObject` to prevent calling `onDestroy` after component has been destroyed.

# 3.9.4
- Fix bug in `FollowerWidget`.
- Fix bug in `SimpleDirectionAnimation` where fast animation direction did not change when character direction changed. Thanks [tkshnwesper](https://github.com/tkshnwesper)

# 3.9.3
- push improvements. 
- `Movement` mixin improvements.
- Other otimizations
- Fix intermittent crash after `simpleAttackRanged` is called. [#520](https://github.com/RafaelBarbosatec/bonfire/issues/520). Thanks [tkshnwesper](https://github.com/tkshnwesper)

# 3.9.2
- MiniMap improviments. Fix issue [#517](https://github.com/RafaelBarbosatec/bonfire/issues/517)
- Raname `BouncingObject` to `ElasticCollision`.
- Fix `SimpleDirectionAnimation` bug when render fastAnimation.

# 3.9.1
- `BlockMovementCollision` improvements.
- Create a `PinchGesture` mixin to listen pinch gestures.
- Create a `UpdateCameraByPinchGesture` mixin to update zoom and camera position in pinch events.

# 3.9.0
- `JoystickDirectional` improvements. Now you can use `Alignment`.
- `JoystickAction` improvements. Now you can use `Alignment`.
- Adds param `PlayerControllerListener? observer` in `Joystick`. If pass this param, the joystick will controll this observer and not the Component passed in `player` param.
- Adds param `PlayerControllerListener? observer` in `Keyboard`. If pass this param, the keyboard will controll this observer and not the Component passed in `player` param.
- Fix type `BarLifeDrawPosition`. [#515](https://github.com/RafaelBarbosatec/bonfire/issues/515)

**Breaking Changes:**
  - `BonfireWidget` expect `List<PlayerController>? playerControllers` instead of `joystick`. With this improvements is possible pass multi ways to control de player or any component that contains the mixin `PlayerControllerListener`(use `MovementByJoystick` to move automatic by PlayerController interactions). With this improvements it's possible create a local multiplayer.
  - Removed `keyboardConfig` param from `BonfireWidget`. Now pass `Keyboard` instance in `playerControllers`.
  Example using joystick and keyboard:
  ```dart
    return BonfireWidget(
      map: ...,
      playerControllers: [
        Joystick(directional: JoystickDirectional()),
        Keyboard(),
      ],
      player: HumanPlayer(
        position: Vector2(100, 100),
      ),
    );
  ```

# 3.8.7
- Fix bug collision. [#511](https://github.com/RafaelBarbosatec/bonfire/issues/511)
- Renamed `AutomaticRandomMovement` to `RandomMovement`
- `RandomMovement` improvements! Now works in `PLatformEnemy`

# 3.8.5
- Fix bug in `JumperAnimation`

# 3.8.4
- `KeyboardConfig` improvements. Now `directionalKeys` expect list of `KeyboardDirectionalKeys`. Fix [#507](https://github.com/RafaelBarbosatec/bonfire/issues/507)
- `PlatformEnemy` improvements.
- Adds `flipAnimation` method in `ui.Image`.

# 3.8.3
- Fix bug in the `PlatformPlayer` movements.
- Adds `objectsBuilder` in `WorldMapBySpritefusion`. You can select a layer to adds objects in the tile position.
- Now we use `DamageHitbox` in `FlyingAttackGameObject`.

# 3.8.2
- Adds param `centerAnchor` in `SimpleDirectionAnimation` and `PlatformAnimations`. It's useful to correct spritesheet not centered.
- Now only handle move left or right by joystick in `SimplePlayer`.

# 3.8.0
- Adds `DamageHitbox`. Use it to do damage.
- `GameMap` Improvements. Now you can access the layers

  Breaking Changes:
    - `WorldMap` expect `List<Layer>` instead of `List<TileModel>`;
    - `MatrixMapGenerator.generate` now expect `List<MatrixLayer> layers` instead og `List<List<double>> matrix`;
    - `TileModel` renamed to `Tile`;
    - `TileModelSprite` renamed to `TileSprite`.
- Adds support to load map built by [SpriteFusion](https://www.spritefusion.com/). Use `WorldMapBySpritefusion`.

  Breaking Changes:
    - Renamed `TiledReader` to `WorldMapReader`.
    - Renamed `TiledReader.asset` to `WorldMapReader.fromAsset`.
    - Renamed `TiledReader.network` to `WorldMapReader.fromNetwork`.

Breaking Changes:
- Renamed `AttackFromEnum` to `AttackOriginEnum`.
- Renamed `ReceivesAttackFromEnum` to `AcceptableAttackOriginEnum`.
- Renamed `die` to `onDie` in `Attackable`.
- Renamed `revive` to `onRevive` in `Attackable`.

# 3.7.1
- Fix keyboard param. [#500](https://github.com/RafaelBarbosatec/bonfire/pull/500). Thanks [jakobodman123](https://github.com/jakobodman123)


# 3.7.0
- Update `Flame` to 1.17.0

# 3.6.2
- standardizes `onLoad` method.
- adds `size` in `EmptyWorldMap`.
- adds mixin `FlipRender`.

# 3.6.1
- Adds `moveAlongThePath` method in `PathFinding` mixin.
- Bugfix in `Vision` mixin.

# 3.6.0
- Adds param `hudComponents` in `BonfireWidget`;
- Adds `queryHud` method in `BonfireGameInterface`;
- Adds `addHud` method in `BonfireGameInterface`;
- Update Flame to `1.16.0`.

# 3.5.0
- Adds Parallax support
- Background improvements.
- [BREAKING CHANGE] `keyboardConfig` param moved to outside the `Joystick`. now in `BonfireWidget`.
- [BREAKING CHANGE] `JoystickController` renamed to `PlayerController`.

# 3.4.0
- Adds `header` param in `TiledNetworkReader`
- Update Flame to '1.15.0'

# 3.3.0
- `TiledNetworkReader` improvements. Adds support to embedded tileset.
- Update Flame to `1.14.0`

# 3.2.0
BREAKING GANGES:
- removes `progress`,`delayToHideProgress`,`progressTransactionBuilder`,`progressTransactionDuration` from `BonfireWidget`. Now create your own progress with base of `onReady` callback.
- `WorldMapByTiled` now expect `TiledReader` instead of `String`. You can use `TiledReader.asset` or `TiledReader.network`.
- Adds `TiledCacheProvider` in `TiledNetworkReader`
- Update `tiledjsonreader`.

# 3.1.2
- fix bug `AutomaticRandomMovement`. (not stop movement in collision)
- fix bug `BlockMovementCollision`.(pushing other)
- fix bug `simpleAttackMeleeByDirection`.(pushing enemy to inside other collision)

## 3.1.1
- Fix flip render problem in `SimpleDirectionAnimation`.

## 3.1.0
- [BREAKING CHANGE] `BlockMovementCollision` big improvements.
  - Update `onBlockedMovement` method, adds `CollisionData(normal,depth,direction,intersectionPoints)`
  - Adds `onBlockMovementUpdateVelocity` method to do override if necessary.
  - Adds `setupBlockMovementCollision({bool? enabled, bool? isRigid})`
- `HandleForces` improvements.
- Fix typo in params that contained `intencity` renaming it to `intensity`.
- Fix bug `playOnce` and `playOnceOther` when call again without finish the last.
- `BarLifeComponent` improvements. Now it center horizontally automatic
- `Jumper` improvements.

## 3.0.10
- Create mixin `MovePerCell`.
- Create mixin `CanNotSeen`. Use it to turn your component not detectable from `Vision` mixin.
- Update `showDamage` method.`initVelocityUp` renamed to `initVelocityVertical` and adds param `initVelocityHorizontal`.
- Fix issue [#455](https://github.com/RafaelBarbosatec/bonfire/issues/455)
- Fix bug [#474](https://github.com/RafaelBarbosatec/bonfire/issues/474)

## 3.0.9
- adds new Pushable configurations. (`pushableFrom`,`pushPerCellEnabled`,`cellSize`,`pushPerCellDuration`,`pushPerCellCurve`)
- adds method `List<Vector2> getPathToPosition` in mixin `PathFinding`

## 3.0.8
- Fix bug unwanted push when component have BlockMovementCollision.

## 3.0.7
- adds set `mapZoomFit` in `BonfireCamera`.
- adds set `moveOnlyMapArea` in `BonfireCamera`.
- adds param `infinite` and `reverseCurve` in `generateValues`. (ValueGeneratorComponent)
- adds `spriteOffset` in `UseSprite`.
- adds `spriteAnimationOffset` in `UseSpriteAnimation`.
- adds `spriteAnimationOffset` in `SimpleDirectionAnimation`.
- `BlockMovementCollision` improvements. BREAKING CHANGE: Method `onBlockedMovement` now return not null `Direction`.
- Fix bug when setting `isVisible` to `false`.
- Fix in polygon collision added by Tiled.


## 3.0.6
- Adds bool `paused` in `BonfireGameInterface`.
- `SimpleDirectionAnimation.playOther` improvements.
- `TileRecognizer` improvements. Now consider rectCollision
- Render priority improvements. Now consider rectCollision
- Movements improvements.
- Adds param `movementAxis` in `moveTowardsTarget`

## 3.0.5
- Update `a_star_algorithm`

## 3.0.4
- Fix blending pixel bug in tile with animation.

## 3.0.3
- Now all Tile in the map have you own Paint.
- Update `tiledjsonreader` to `1.3.3`.
- Tiled improvements : Now if you set the class of objectlayer to `collision`, all object of this layer will be collision.
- Adds param `resolution` in `CameraConfig`.

## 3.0.2
- `BleedingPixel` improvements.
- Adds `orientation` param in `getZoomFromMaxVisibleTile`.
- Adds methods `showStroke` and `hideStroke` in `SimpleDirectionAnimation`
- Adds methods `showSpriteStroke` and `hideSpriteStroke` in mixin `UseSprite`
- Adds methods `showAnimationStroke` and `hideAnimationStroke` in mixin `UseSpriteAnimation`
- BREAK: `BlockMovementCollision` improvements. Remove `lastDisplacement` from `onBlockedMovement` method.
- BREAK: methos `seeAndMoveTo...` improvements. `notObserved` now return a bool (true to stop move).

## 3.0.1
- Update Flame to `1.10.0`.
- `Movement` improvements.
- Fix bug when use `Movement` mixin and the `MoveEffect`.

## 3.0.0

- Update Flame to `1.9.1`.

- ***BREAKING CHANGES*** 
  - `BonfireWidget`:
    - Remove `enemies` param. Use `components` instead.
    - Remove `decoration` param. Use `components` instead.
    - Remove `gameController` param. Use a `GameComponent` to control your game.
    - Remove unnecessary `constructionModeColor` param.
    - Remove unnecessary `onTapDown` param.
    - Remove unnecessary `onTapUp` param.
    - Rename `constructionMode` to `debugMode`.

  - `Camera` now uses the new Flame API `CameraComponent`
  - `Collision` now uses the Flame collision system:
    - To add collisions on your GameComponent, use a `ShapeHitbox`. See the [docs](https://docs.flame-engine.org/latest/flame/collision_detection.html#shapehitbox) for more info.
    - You can listen the collision callbacks by overriding `onCollision`, `onCollisionEnd` and `onCollisionStart`.
    - To block the movement of components when colliding, use the mixin `BlockMovementCollision`.
  - Remove extension method `followComponent`.
  - Remove `JoystickMoveToPosition`. Use `MoveCameraUsingGesture` with `TapGesture` instead.
  - Mixin `MoveToPositionAlongThePath` was renamed to `PathFinding`, and `setupMoveToPositionAlongThePath` to `setupPathFinding`.
  - Rename `keyboardDirectionalType` to `directionalKeys` in `KeyboardConfig`. Now it is expected a `KeyboardDirectionalKeys`.
  - Remove `UseStateController`.
  - Remove `StateControllerConsumer`.
  - Remove `BonfireInjector`. Is recomented use [get_it](https://pub.dev/packages/get_it).

    
- ***FEATURES***
  - `Force2D`: Now we have a simple support to forces. You can add a global forces setting in `BonfireWidget` using `globalForces` param, or an individual force in you component. For the component to handle these forces, you need to use `HandleForces` mixin.
    - `AccelerationForce2D`: Apply acceleration to velocity.
    - `ResistanceForce2D`: Apply resistance to movement, decreasing speed until it stops.
    - `LinearForce2D`: Apply linear force to velocity.
  - `Jumper`: New mixin to add jumping behavior (suitable for platform games).
  - `PlatformPlayer`: Player class to be used in platform games.
  - `PlatformEnemy`: Enemy class to be used in platform games.
  - Add properties in `gameRef`: `raycastAll`, `raycast` and `timeScale`.
  - Update `Pushable` mixin to handle forces.
  - Add `GameObject`. (It's a `GameComponent` using `Sprite`).
  - Add `AnimatedGameObject`. (It's a `GameComponent` using `SpriteAnimation`).
  - Add `FollowerGameObject`. (It's a `GameObject` using `Follower` mixin).
  - Add `AnimatedFollowerGameObject`. (It's a `AnimatedGameObject` using `Follower` mixin).
  - Add `ComponentSpawner` ([#414](https://github.com/RafaelBarbosatec/bonfire/issues/414)).
  - Add WORLD in `AttackFromEnum`.
  - (Experimental) Add `BouncingObject` mixin.
  - Add `initialMapZoomFit` in `CameraConfig`.
  - Add `getZoomFromMaxVisibleTile` method.
  - Add `startFollowPlayer` param in `CameraConfig`.
  - Add `moveToPosition` in `Movement` mixin.
  - Add `MoveCameraUsingGesture` mixin.
  - Add `isAnimationLastFrame`, `isPaused`, `pauseAnimation()`, `playAnimation()` and `animationCurrentIndex` in `UseSpriteAnimation` mixin.
  - Add `initPosition` param in `CameraConfig`.
  - `Sensor` improvements.
  - `UseBarLife` improvements. Renamed to `UseLifeBar`
  - `MovementByJoystick` improvements: Add `setupMovementByJoystick` method.
  - `Follower` mixin improvements.
  - `Vision` improvements.
  - `AutomaticRandomMovement` improvements: add param `direction` to determine which direction will be the movement.
  - Add `enableDiagonalInput` to enable diagonal input events on `KeyboardConfig` and `JoystickDirectional`.
  - Add `keepDistance` to `MovementExtensions`.
  - Add `MoveCameraUsingGesture` mixin.
  - `TapGesture` improvements: Now you can receive `GestureEvent` in callbacks.
  - `DragGesture` improvements: Now you can receive `GestureEvent` in callbacks.
  - Update `tiledjsonreader` to `1.3.2`. Now it supports maps with encoding and compression.
  - Fix issue [417](https://github.com/RafaelBarbosatec/bonfire/issues/417). (Thanks [Matt El Mouktafi](https://github.com/mel-mouk))

# [2.12.8]
- Update README.
- Fix `manual_map`'s redundant code.
- Fix Knight's gauge remaining bug.

# [2.12.7]
- Fix issue [417](https://github.com/RafaelBarbosatec/bonfire/issues/417). Thanks [Matt El Mouktafi](https://github.com/mel-mouk)

# [2.12.6]
- Adds fixed Flame version to `1.7.3`
- Update Flutter sdk range `<4.0.0`
- Fix issue [413](https://github.com/RafaelBarbosatec/bonfire/issues/413)

# [2.12.5]
- Adds `playOnceOther` in `SimpleDirectionAnimation`
- Now the flip operation did by `SimpleDirectionAnimation` not flip the component.

# [2.12.4]
- Fix issue [#402](https://github.com/RafaelBarbosatec/bonfire/issues/402)

# [2.12.3]
  
## 2.12.3

>>>>>>> v3.0.0
- Fix issue [#379](https://github.com/RafaelBarbosatec/bonfire/issues/379)
- Adds in `ObjectCollision` the method `onCollisionHappened`

## 2.12.2

- Adds `FollowerObject`. Thanks [Matt El Mouktafi](https://github.com/mel-mouk)!

## 2.12.1

- Adds multi scenario example
- Update Flame version to 1.7.1

## 2.12.0

- Add mustCallSuper to GameComponent.update and GameComponent.onRemove
- Update Flame to 1.6.0

## 2.11.11

- Fix [#261](https://github.com/RafaelBarbosatec/bonfire/issues/261)
- Fix [#364](https://github.com/RafaelBarbosatec/bonfire/issues/364)

## 2.11.10

- Consider Tiled layer opacity. Fix [#356](https://github.com/RafaelBarbosatec/bonfire/issues/356)
- Little improvements performance.
- Adds param `area` in `TiledObjectProperties`.
- Fix multi instance of `AnimatedObjectOnce` in `SimpleDirectionAnimation`. [#359](https://github.com/RafaelBarbosatec/bonfire/issues/359)

## 2.11.9

- Improvements performance in `LightingInterface`.
- Improvements to check visible collisions.
- Improvements in `RenderTransformer`.
- Update `ListenerGameWidget`.
- Resolve issue [#354](https://github.com/RafaelBarbosatec/bonfire/issues/354)

## 2.11.8

- Fix bug in `moveOnlyMapArea`

## 2.11.7

- Fix diagonal movement speed for enemies
- Improvements in `moveOnlyMapArea`
- Adds param `setZoomLimitToFitMap` in `CameraConfig`.

## 2.11.6

- Update Flame to `1.5.0`

# 2.11.5
- Improve Keyboard Controls.
- Adds support to tileset with individual image

# 2.11.4
- Fix exception in `TiledWorldBuilder`.

# 2.11.3
- Adds methods `enableGestures` and `enableKeyboard` in `gameRef`(BonfireGameInterface)
- Adds mixin `KeyboardEventListener`.

# 2.11.2
- BugFix[`BarLifeComponent`]: animate in web.

# 2.11.1
- BugFix[`BarLifeComponent`]: resolve bug offset when `drawPosition` equals `BarLifePorition.bottom`.

# 2.11.0
- Render transform improvements.
- BREAKING CHANGE: Now the `SimpleDirectionAnimation` do flip component that use it as necessary.
- Adds param `useCompFlip` in `playOnce` (default `false`). If `true` the animation is flipped equal current state of component.
- Adds param `backgroundColor` in `BonfireWidget`.
- create `BarLifeComponent`.
- Adds `UseBarLife` mixin.
- method `drawDefaultLifeBar` now is deprecated. Pls use `UseBarLife` mixin.

# 2.10.10
- Update Flame to `1.4.0`.
- Improvements in `MiniMap`: Adds `zoom` param. [#325](https://github.com/RafaelBarbosatec/bonfire/issues/325)

# 2.10.9
- Do correction suggested by issue [#327](https://github.com/RafaelBarbosatec/bonfire/issues/327). Thanks [Fixid-Fuzz](https://github.com/Fixid-Fuzz)!
- Camera improvements.
- remove required `animation` in `simpleAttackMeleeByAngle`.

# 2.10.8
- Fix bug tendency to go to the right in `AutomaticRandomMovement`.

# [2.10.6]
- Improvements in `AutomaticRandomMovement`
- Improvements in `Follower`

# [2.10.4]
- fix bug when use `DragGesture` and `TapGesture` together.

# [2.10.3]
- performance improvements
- Improvements in `SimpleDirectionAnimation`. Now you can use diagonal animation passing only right animation: `runUpRight`,`runDownRight`,`idleUpRight`,`idleDownRight`. Resolve issue [316](https://github.com/RafaelBarbosatec/bonfire/issues/316)

# [2.10.2]
- performance improvements in `LightingComponent`.

# [2.10.1]
- fix `onStop` bug in `Acceleration`
- Adds widget `TypeWriter`. It's helpful to show dialog.
- Update `TalkDialog`. now using `TypeWriter`.

# [2.10.0]
- Improvements in `Sensor`. Now you can pass T type to find especific type to contact.
- Update `tiledjsonreader`.
- Update `http`.
- Fix crash in `Acceleration` mixin.
- Adds `onStop` params in `Acceleration` mixin. It's called when stop for collision or when speed is equals 0 in `stopWhenSpeedZero` setted true.
- Use `HasPaint` mixin in `GameComponent`.
- Improvements on Tile.
- Improvements Collision system.
- Improvements Performance.
- Improvements code by lint.

# [2.9.4]
- Adds `revive` method in `Attackable` mixin. Now if adds life to stay above 0 it's is revive.
- Adds `onFinish` in `moveToPositionAlongThePath` method. (`MoveToPositionAlongThePath` mixin)
- Improvements in `WorldMap`
- Mostly dart cleanup while looking at tiled code. Thanks [jtmcdole](https://github.com/jtmcdole)!

# [2.9.3]
- Adds `pauseAnimation` and `resumeAnimation` in `UseSpriteAnimation` mixin.
- Adds `pause` and `resume` in `SimpleDirectionAnimation`
- Improvements in `MoveToPositionAlongThePath`. Adds `factorInflateFindArea` in `setupMoveToPositionAlongThePath` method.
- Improvements in `DirectionAnimation`.


# [2.9.2]
- Improvements in `seeAndMoveToPlayer`. Adds param `notCanMove` sugested by issue [303](https://github.com/RafaelBarbosatec/bonfire/issues/303)
- Improvements in `positionsItselfAndKeepDistance`.

# [2.9.1]
- improvements in `MoveToPositionAlongThePath`. Resolve issue [299](https://github.com/RafaelBarbosatec/bonfire/issues/299)
- improvements in `followComponent`. Now return `true` if can move. Resolve issue [301](https://github.com/RafaelBarbosatec/bonfire/issues/301)

# [2.9.0]
- BREAKING CHANGE:
  - remove `BonfireTiledWidget`. now use `BonfireWidget` passing map `WorldMapByTiled`
  - renamed `MapWorld` to `WorldMap`
  - renamed `MapGame` to `GameMap`
- improvements in `simpleAttackMeleeByDirection` and `simpleAttackMelee`. now it's not necessary set animation to all directions, only to right.
- return `Future<List<Offset>>` in `moveToPositionAlongThePath` method.
- imprvements in `MoveToPositionAlongThePath` mixin.

# [2.8.1]
- Adds `onContactExit` in `Sensor` mixin.

# [2.8.0]
- Update flame to `1.3.0`

# [2.7.8]
- fix `Acceleration`.
- fix `MouseGesture`

# [2.7.6]
- Adds mixin `Acceleration`.
- Rename methods in `MouseGesture`
  - `onHoverScreen` to `onMouseHoverScreen`
  - `onHoverEnter` to `onMouseHoverEnter`
  - `onHoverExit` to `onMouseHoverExit`
  - `onScrollScreen` to `onMouseScrollScreen`
  - `onScroll` to `onMouseScroll`

# [2.7.5]
- Improvements in `MouseGesture`.
- Improvements in `RotationEnemyExtensions`.
- Adds `BonfireUtil`.
- Adds optional param `firstCheckIsTrue` in `checkInterval` method.
- Adds param `useAngle` in `runRandomMovement` method (`AutomaticRandomMovement`). To use in components top-down.
- Update top-down example.

# [2.7.4]
- adds bool `movementByJoystickEnabled` in `MovementByJoystick` mixin. to disable mixin.
- Improvements example game `TopDown`.
- Adds `useTargetPriority` in AnimatedFollowerObject. (default = true)

# [2.7.3]
- Improvements in `Follower`.
- Improvements in `simpleAttackRangeByAngle` and `simpleAttackMeleeByAngle`

# [2.7.2]
- adds `playSpriteAnimationOnce` in mixin `UseSpriteAnimation`
- Fix destroy position in `FlyingAttackObject`
- Add talkAlignment in the talk box (optional), for default is Alignment.bottomCenter. Thanks [pmella16](https://github.com/pmella16)

# [2.7.1]
- update `tiledjsonreader`
- Improvements in `FlyingAttackObject`. Adds damage in area with base in `destroySize` if sets `animationDestroy`

# [2.7.0]
- Improvements in handle gestures events. Fix issue [#283](https://github.com/RafaelBarbosatec/bonfire/issues/283)
- BREAKING CHANGE:
  - `void onTapDown(int pointer, Vector2 position)` to `bool onTapDown(int pointer, Vector2 position)` in `TapGesture` 
  - `void onStartDrag(int pointer, Vector2 position)` to `bool onStartDrag(int pointer, Vector2 position)` in `DragGesture`

# [2.6.6]
- Adds support to `tileset` embeded in map (Tiled).
- update `tiledjsonreader`.

# [2.6.5]
- create `Vision` mixin
- improvements in `seeComponent` and `seeComponentType`. now you can pass `visionAngle`(default = 6,28319 (360 graus)). resolve : [#273](https://github.com/RafaelBarbosatec/bonfire/issues/273)

# [2.6.4]
- Update `flame` to `1.2.1`.
- Update `tiledjsonreader` to `1.1.2`
- Adds support to `class`. is new `type` in tiled version `1.9.0`.
- Adds support to set type `above` in layer. Just create custom property with name `type` and value `above`.
- Fix bug [#271](https://github.com/RafaelBarbosatec/bonfire/issues/271).

# [2.6.3]
- Fix: update map limits using `moveOnlyMapArea` after camera zoom changes. [#267](https://github.com/RafaelBarbosatec/bonfire/issues/267)
- Adds `Future updateDirectional(JoystickDirectional? directional)` in `Joystick`. [#269](https://github.com/RafaelBarbosatec/bonfire/issues/269)

# [2.6.2]
- Updated example.
- Remove mandatory of the `SimpleDirectionAnimation` in  `SimpleAlly`, `SimpleEnemy`, `SimpleNpc` and `SimplePlayer`

# [2.6.1]
- removed `getValueGenerator` from `BonfireGame`. Now use `generateValues` from your component.
- removed `addParticle` from `BonfireGame`. Now use `addParticle` from your component.
- improvements in `ValueGeneratorComponent`
- Adds effect `BonfireOpacityEffect`.
- Adds support to new files of the Tiled 1.8.0 (`tmj`,`tsj`) .

# [2.6.0]
- Update `flame` to `1.2.0` - [CHANGELOG](https://pub.dev/packages/flame/changelog)
- Renamed `gameRef.overlays` to `gameRef.overlayManager`
- Renamed `GameComponent.shouldRemove` to `GameComponent.isRemoving`
- Remove `showFPS` in `BonfireTiledWidget` and `BonfireWidget`.
- Fix Camera bug in a small map that is not the size of the screen. [#261](https://github.com/RafaelBarbosatec/bonfire/issues/261)

# [2.5.0]
- Adds `MatrixMapGenerator`. Class that can help you create a map using a double matrix. [Doc](https://bonfire-engine.github.io/#/map?id=creating-map-by-matrix)
- Adds `TerrainBuilder`. Class that can help you create a map using a double matrix with Sprite. [SpriteSheetModel](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/assets/images/tile_random/earth_to_grass.png)
- Adds `enabledDiagonalMovements` param in `MovementByJoystick` to control if you want diagonal movements.

# [2.4.4]
- Adds `scene` support. Now you can create a "cutscene" in an easy way:
    - Just call `gameRef.startScene([CameraSceneAction()])`.
    - To stop: `gameRef.stopScene()`.
    - SceneActions available:
        - `CameraSceneAction`
        - `DelaySceneAction`
        - `MoveComponentSceneAction`
        - `AwaitCallbackSceneAction`

# [2.4.3]
- Improvement in `JoystickMoveToPosition`. New:
    - adds `enabledMoveCameraWithClick` param to enable movements of the camera with click and move movements.
    - adds `mouseButtonUsedToMoveCamera` param to set what button of the mouse you can use to move the camera.
    - adds `mouseButtonUsedToMoveToPosition` param to set what button of the mouse you can use to set the position target. Default is `secondary` (right mouse button).
- Extracted functions about check `Tiles` to the mixin `TileRecognizer`.

# [2.4.2]
- Adds params `focusNode`, `autofocus` and `mouseCursor` in `BonfireWidget` and `BonfireTiledWidget`.
- Improvements in `Camera`.
- BREAKING CHANGE: Update `StateController`. The method `update` is now `void update(double dt, T component)`. Now you can receive what component belongs to the update method in case that your controller is used in many components.

# [2.4.1]
- Adds `removeLife` method in `Attackable`.
- The `offset` param from Tiled layers are now considered.
- Adds type `dynamicAbove` in tile.
- Adds `MiniMap` widget [DOC](https://bonfire-engine.github.io/#/minimap).
- Update Flame to 1.1.1.

# [2.4.0]
- Updated Flame to version 1.1.0
- Added `addParticle(Particle particle)` in `gameRef`.
- Added NPC component. `Enemy` class now inherits from `Npc` class. Suggested by [4mitabh](https://github.com/4mitabh).
- Improvements in `Attackable` system.
- Added `checkCanReceiveDamage` method in `Attackable` mixin. You can override this method to implement your own filters on who should receive damage or not.
- BREAKING CHANGE - `receiveDamage` method in `Attackable` now requires a new `AttackFromEnum` param.
    - Before:
    ```dart
      void receiveDamage(
         double damage,
         dynamic identify,
      )
    ```
    - Now:
    ```dart
      void receiveDamage(
         AttackFromEnum attacker,
         double damage,
         dynamic identify,
      )
    ```

# [2.3.1]
- Updated example with NPCs. Thanks [4mitabh](https://github.com/4mitabh)!
- Fixed 8-Direction Animation mentioned in [#234](https://github.com/RafaelBarbosatec/bonfire/issues/234). Thanks [TaylorHo](https://github.com/TaylorHo)!
- Update example to Android embedding V2. Thanks [4mitabh](https://github.com/4mitabh)!

# [2.3.0]
- Fix bug in camera zoom out.
- Add `animateZoom` method in `Camera`.
- Add Experimental State Manager. Example [here](https://github.com/RafaelBarbosatec/bonfire/issues/218#issuecomment-1058121200).

# [2.2.5]
- Fix crash mentioned in [#225](https://github.com/RafaelBarbosatec/bonfire/issues/225).
- Fix crash mentioned in [#227](https://github.com/RafaelBarbosatec/bonfire/issues/227).

# [2.2.4]
- Improvements in `MovementByJoystick`.
- Improvements in how to access the `gameRef` from a `GameComponent`.
- Improvements in `ImageLayer`.
- Fix issue [#224](https://github.com/RafaelBarbosatec/bonfire/issues/224) in `TalkDialog`.

# [2.2.2]
- Improvements in `DirectionAnimation` mixin.
- Improvements in `Movement` mixin. Added `onMove` method, which you can override to listen to component movements.
- Set `dPadAngles` default value equals false in `MovementByJoystick`.

# [2.2.1]
- Fix `WithSpriteAnimation`.

# [2.2.0]
- Improvements in performance.
- Add `Follower` mixin.
- Add `WithAssetsLoader` mixin.
- Add `WithSprite` mixin.
- Add `WithSpriteAnimation` mixin.
- Fix bug in camera movement for games with zoom applied.
- Improvements in `FlyingAttackObject`.
- BREAKING CHANGE:
    - Renamed `radAngleDirection` param to `angle` in `simpleAttackRangeByAngle`;
    - Renamed `animationUp` to `animation` in `simpleAttackRange` and `simpleAttackRangeByAngle`. You should now use the default animation (to the right).

# [2.1.0]
- Update `a_star_algorithm`.
- Change `Offset` to `Vector2` in `Camera.moveToPositionAnimated`.
- Add `moveToPositionAnimated` in `camera`.
- Add `marginFromOrigin` param in `simpleAttackRangeByAngle`.
- Add top-down game example.
- Fix bug in `RotationPlayer`.
- Improvements in Lighting mixin:
   - Add types LightingType.circle and LightingType.arc;
   - Add align param;
   - Add lightingEnabled param.

# [2.0.0]
We're striving to reduce the distance between Flame and Bonfire, relying more and more on Flame components under the hood now that it is stable. In this version we are following the standardization of using `Vector2` for `position` and `size` and using `PositionComponent` as the base for Bonfire components. Also, 'FlameGame' and the Flame's Camera are now used instead of custom implementations we had before. Some small features were lost, but nothing that the Flame's team isn't capable of adding over time.

- Update to flame 1.0.
    - BREAKING CHANGE: Use `Vector2 size` instead of `double height` and `double width`.
    - BREAKING CHANGE: Use `Vector2` instead of `Offset` and `Size`.
    - BREAKING CHANGE: `camera.animateSimpleRotation` and `camera.animateLoopRotation` are not available anymore.
- Improvements in `ObjectCollision`. Now it is possible to override `onCollision` and return `false` so the object will not collide with anything or block the passage.
- Add new mixin `Pushable`.
- Add params `name` and `id` in `TiledObjectProperties`.
- Add support to use [Flame Effects](https://docs.flame-engine.org/1.0.0/effects.html)
- Small improvements in `SimpleDirectionAnimation`
- Improvements in `Lighting`
- Extensions improvements
- Improvements in `GameColorFilter`
- Add `left`,`right`,`top`,`bottom` in `GameComponent`
- Add `enabledSensor` in `Sensor`
- `SimpleDirectionAnimation` now only requires `idleRight` and `runRight`. It will automatically flip horizontally to perform the idle/run left animations. You can disable this feature setting the param `enabledFlipX` to false (default = true). `enabledFlipY` is also available, but defaults to false (if you set this param to true, only `idleUp` and `runUp` are needed).
- Bug fix in `getAnimation` (ImageExtension).
- Bug fix in `progress` (BonfireTiledWidget).

# [1.12.3]
- Improvements in collision objects by Tiled.

# [1.12.2]
- Adds support to add objects with collision by Tiled. Just add the object and set you type to `collision`. [#210](https://github.com/RafaelBarbosatec/bonfire/issues/210)
- Improvements in `worldPositionToScreen`. Now considers zoom.
- Improvements in `seeAndMoveToPlayer` and `seeAndMoveToAttackRange`. Adds `notObserved` and `observed`.

# [1.12.1]
- improvements in sprite load of the `BackgroundImageGame`.
- improvements in `simpleAttackRangeByAngle`.
- rename `animationTop` to `animationUp`
- rename `animationBottom` to `animationDown`
- improvements in `TalkDialog`

# [1.12.0]
-  Adds SpriteAnimation extension: method `asWidget`.(You can use this to SpriteAnimation or Future<SpriteAnimation>)
-  Adds Sprite extension: method `asWidget`.(You can use this to Sprite or Future<Sprite>)
-  Adds Support to ImageLayer in map built by Tiled. [issue 76](https://github.com/RafaelBarbosatec/bonfire/issues/76)
-  Adds Support to Text Object in map built by Tiled.

# 1.11.1
- Fix problem render Map.

# 1.11.0
- Improvements in `Sensor` mixin.
- Add support to flip vertical, flip horizontal and rotate in Tiled. [#182](https://github.com/RafaelBarbosatec/bonfire/issues/182)
- Update flame to `1.0.0-releasecandidate.17`
    - BRAKING CHANGE: Replace `TextPaintConfig` to `TextStyle`

# 1.10.0
- Fix [#203](https://github.com/RafaelBarbosatec/bonfire/issues/203) - Web build with late initialisation on animations
- Create interfaces to facility access methods of the `ColorFilter` and `Lighting`.
- Add `replaceAnimation` method in `DirectionAnimation`. now you can use this method in SimplePlayer or Enemy to replace `SimpleDirectionAnimation`.
- Now gameRef is `BonfireGameInterface`.
- Improvements in SimpleDirectionAnimation.
- BREAKING CHANGE:
    - rename `gameRef.changeJoystickTarget` to `gameRef.addJoystickObserver`
    - remove `gameRef.addComponent`. now use `gameRef.add` or `gameRef.addAll`

# 1.9.10
- Fix problem render big tilesets [#200](https://github.com/RafaelBarbosatec/bonfire/issues/200).

# 1.9.9
- Add `dismissible` param in `TalkDialog.show` to avoid the dialogue being dismissed when the back button is pressed or esc key is pressed on desktop.
- Add `animateLoopRotation` method in camera.
- Rename `animateRotate` to `animateSimpleRotation`.
- Improvements in rotation effect.

# 1.9.8
- Fix rounding of movement in `MoveToPositionAlongThePath`.
- Fix loaded map by url.

# 1.9.7
- Improvements in `TalkDialog.show` : add `onClose`.
- Add rotation functionality to the camera. Set `angle` on `CameraConfig` or `animateRotate` to rotate the camera view

# 1.9.6
- Fix bug "getting stuck" in `MoveToPositionAlongThePath`
- [BREAKING CHANGE] Change param `logicalKeyboardKeyToNext` in `TalkDialog` to `logicalKeyboardKeysToNext`, now multiple keys are accepted to advance in the dialogue
- Add option `wasdAndArrows` to `KeyboardDirectionalType` allowing both arrows and wasd keys to control the joystick
- Improvements in diagonal movements in `MoveToPositionAlongThePath`

# 1.9.5
- Update params name of `simpleAttackMelee` in Enemy.
- Improvements in `MoveToPositionAlongThePath`

# 1.9.4
- Small improvements in map loading.
- Adds `angle` param in `GameComponent` to rotate component render.

# 1.9.3
- Update flame to `1.0.0-releasecandidate.16`

# 1.9.2
- Fix onGameResize. It works again when the window size is changed

# 1.9.1
- Correction of loading visible collisions  on the map.
- Adds a simple example.


# 1.9.0
- Update flame to `1.0.0-releasecandidate.15`
- Adds  methods `changeJoystickTarget` in BonfireGame to make it easy to switch the default joystick events watcher.
- [BREAKING CHANGE] Component `remove()` method was replaced by `removeFromParent()`. Use it to remove a component from the game.
- [BREAKING CHANGE] Improvements in Keyboard events. Removed params `keyboardEnable` and `keyboardDirectionalType` in `Joystick`. Set these attributes through `keyboardConfig`.
- [BREAKING CHANGE] gameRef.components changed to gameRef.children.

# 1.8.1
- Adds `Focus` in `CustomGameWidget` to remove "system ding" in MACOS.
- Updates `moveToTarget` method in `Camera` to receive null;
- Add optional list of objects to `moveToPositionAlongThePath` for ignoring visible collisions

# 1.8.0
- Bugfix/quadtree id for removal [#178](https://github.com/RafaelBarbosatec/bonfire/pull/178)
- Adds `keyboardDirectionalType` param in `Joystick` to enable WASD.

# 1.7.0
- adds `FollowerWidget`. With this you can add a widget what follows a component in the game.
- update `a_star_algorithm`. now enables diagonal movements.

# 1.6.1
- fixed the flame version to `1.0.0-releasecandidate.13` while we fixed the flame update crash change.

# 1.6.0
- adds `getScreenPosition` method in `GameComponent`.
- adds `enableDiagonal` param in `simpleAttackRange`.
- adds `visibleComponentsByType` and `componentsByType` in `BonfireGame`.
- adds `onTapDown` and `onTapUp` in `BonfireTiledWidget` and `BonfireWidget`.

# 1.5.11
- Improvements performance.

# 1.5.9
- remove method `isVisibleInCamera()` in `GameComponent`. Now use the `isVisible` param to check if this component is visible in camera.

# 1.5.6
- improvements performance in big maps

# 1.5.4
- increases map rendering space

# 1.5.3
- improvements in order of the update of `Camera`
- add `QuadTree` data struct to search of the visible Tiles.
- update `ordered_set`

# 1.5.2
- improvements in `Camera`
- improvements in `AnimatedObjectOnce`

# 1.5.1
- improvements in `CameraConfig -> moveOnlyMapArea`
- improvements in `Lighting`

# 1.5.0
- adds "Smooth" effect in camera. To enable:
```dart
    BonfireTiledWidget(
        ...
        cameraConfig: CameraConfig(
            smoothCameraEnable: true,
        ),
    );
```

# 1.4.14
- fix bug in `TapGesture`

# 1.4.13
- fix error Tile of `above` type.

# 1.4.12
- fix crash when remove Tile
- optimizes map loading
- improve player joystick movement [#157](https://github.com/RafaelBarbosatec/bonfire/pull/157)

# 1.4.11
- improvements in `MapWorld`
- enables remove tiles of map.
- fix position translation on diagonal movement of FlyingAttackObject [#155](https://github.com/RafaelBarbosatec/bonfire/pull/155)

# 1.4.10
- improvements performance

# 1.4.9
- new Improvements in process Tile in `TiledMap`.
- Add `shake` method in `Camera`.

# 1.4.8
- Improvements in process Tile in `TiledMap`.

# 1.4.6
- Improvements in `TiledMap`.

# 1.4.5
- [BREAKING CHANGE] Refactor `TalkDialog` core to allow RichText animations:
  Now every `Say` requires a `text` param which takes a `List<TextSpan>` instead of a String.
- Add param `speed` to `TalkDialog`.
- Improvements in cache system to load map.

# 1.4.4
- add param `tileSizeToUpdate` to configure interval of the update map.

# 1.4.2
- fix `tileSize` in `MapWorld`.

# 1.4.0
- Improvements in `Camera`
- Improvements in `MapWorld` to support large maps.
- [BREAKING CHANGE] change `List<Tile>` to `List<TileModel>` to create manual maps see [example](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/manual_map/dungeon_map.dart).

# 1.3.7
- remove microTask to update chache in `BonfireGame`

# 1.3.6
- Improvements in `LightingComponent`
- Improvements in `TalkDialog`. [#136](https://github.com/RafaelBarbosatec/bonfire/pull/136)
- update `a_star_algorithm`


# 1.3.5
- remove Unnecessary `print` in `TiledWorldMap`
- Add param `opacity` in `GameComponent` to control opacity.

# 1.3.4
- Improvements in `TiledWorldMap`

# 1.3.3
- Update `tiledjsonreader`
- Adds support to folders(group) in Tiled

# 1.3.2
- Improvements in extensions organization.
- Update Flame to `1.0.0-releasecandidate.13` version.
- Replace `HasGameRef` for the own `BonfireHasGameRef`.

# 1.3.1
- little improvement in `drawDefaultLifeBar`.
- create mixin `AutomaticRandomMovement`
- add `onReady` in `BonfireTiledWidget` and `BonfireWidget`
- add `getComponentDirectionFromMe` in `GameComponentExtensions`
- add `checkInterval` in `GameComponent`

# 1.3.0
- new extensions to `GameComponent`.
- new extensions to `Movement`.
- new extensions to `Attackable`.
- Makes Bonfire more modular. Every kind of behavior has become a mixin.

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
