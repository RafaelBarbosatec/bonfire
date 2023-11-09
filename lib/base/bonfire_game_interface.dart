import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/camera/bonfire_camera.dart';
import 'package:bonfire/color_filter/color_filter_component.dart';
import 'package:bonfire/lighting/lighting_component.dart';
import 'package:flame/game.dart';
// ignore: implementation_imports
import 'package:flame/src/game/overlay_manager.dart';
import 'package:flutter/widgets.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 19/11/21

abstract class BonfireGameInterface {
  BuildContext get context;
  Player? get player;
  JoystickController? get joystick;
  LightingInterface? get lighting;
  ColorFilterInterface? get colorFilter;
  BonfireCamera get camera;
  GameMap get map;
  int get highestPriority;
  Vector2 get size;
  bool get hasLayout;
  bool get showCollisionArea;
  Color? get collisionAreaColor;
  GameInterface? get interface;
  List<Force2D> get globalForces;
  SceneBuilderStatus sceneBuilderStatus = SceneBuilderStatus();
  double timeScale = 1.0;

  /// A property that stores an [ActiveOverlaysNotifier]
  ///
  /// This is useful to render widgets above a game, like a pause menu for
  /// example.
  /// Overlays visible or hidden via [overlays].add or [overlays].remove,
  /// respectively.
  ///
  /// Ex:
  /// ```
  /// final pauseOverlayIdentifier = 'PauseMenu';
  /// overlays.add(pauseOverlayIdentifier); // marks 'PauseMenu' to be rendered.
  /// overlays.remove(pauseOverlayIdentifier); // marks 'PauseMenu' to not be rendered.
  /// ```
  ///
  /// See also:
  /// - GameWidget
  /// - [Game.overlayManager]
  // ignore: invalid_use_of_internal_member
  OverlayManager get overlays;

  /// Used to pause the engine.
  void pauseEngine();

  /// Returns is the engine if currently paused or running
  bool get paused;

  /// Used to resume the engine.
  void resumeEngine();

  /// Used to add component in the game.
  FutureOr<void> add(Component component);

  /// Used to add component list in the game.
  Future<void> addAll(List<Component> components);

  /// Used to get visible "Components".
  Iterable<T> visibles<T extends GameComponent>();

  /// Used to get all "Enemies" or oly visibles.
  Iterable<Enemy> enemies({bool onlyVisible = false});

  /// Used to get living "Enemies" or oly visibles.
  Iterable<Enemy> livingEnemies({bool onlyVisible = false});

  /// Used to get all "Decoration" or oly visibles.
  Iterable<GameDecoration> decorations({bool onlyVisible = false});

  /// Used to get all "Attackables" or oly visibles.
  Iterable<Attackable> attackables({bool onlyVisible = false});

  /// Used to get all "ShapeHitbox".
  Iterable<ShapeHitbox> collisions({bool onlyVisible = false});

  /// Used to find component by type visible or not.
  Iterable<T> query<T extends Component>({bool onlyVisible = false});

  /// This  method convert word position to screen position
  Vector2 worldToScreen(Vector2 position);

  /// This  method convert screen position to word position
  Vector2 screenToWorld(Vector2 position);

  /// Used to check if a component is visible in the camera.
  bool isVisibleInCamera(GameComponent c);

  /// Used to change Joystick listener. And move camera to new target.
  void addJoystickObserver(
    JoystickListener target, {
    bool cleanObservers = false,
    bool moveCameraToTarget = false,
  });

  RaycastResult<ShapeHitbox>? raycast(
    Ray2 ray, {
    double? maxDistance,
    List<ShapeHitbox>? ignoreHitboxes,
    RaycastResult<ShapeHitbox>? out,
  });

  List<RaycastResult<ShapeHitbox>> raycastAll(
    Vector2 origin, {
    required int numberOfRays,
    double startAngle = 0,
    double sweepAngle = tau,
    double? maxDistance,
    List<Ray2>? rays,
    List<ShapeHitbox>? ignoreHitboxes,
    List<RaycastResult<ShapeHitbox>>? out,
  });

  Iterable<RaycastResult<ShapeHitbox>> raytrace(
    Ray2 ray, {
    int maxDepth = 10,
    List<ShapeHitbox>? ignoreHitboxes,
    List<RaycastResult<ShapeHitbox>>? out,
  });

  void startScene(List<SceneAction> actions, {void Function()? onComplete});
  void stopScene();

  void enableGestures(bool enable);
  void enableKeyboard(bool enable);
  bool get enabledGestures;
  bool get enabledKeyboard;
}
