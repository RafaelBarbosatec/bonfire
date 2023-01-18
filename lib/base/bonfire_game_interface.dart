import 'dart:async';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/color_filter/color_filter_component.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/game_interface/game_interface.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/lighting/lighting_component.dart';
import 'package:bonfire/map/base/map_game.dart';
import 'package:bonfire/mixins/attackable.dart';
import 'package:bonfire/mixins/sensor.dart';
import 'package:bonfire/npc/enemy/enemy.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/scene_builder/scene_action.dart';
import 'package:bonfire/scene_builder/scene_manager_component.dart';
import 'package:flame/components.dart';
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
  Camera get camera;
  GameMap get map;
  ComponentSet get children;
  int get highestPriority;
  Vector2 get size;
  bool get hasLayout;
  bool get showCollisionArea;
  Color? get constructionModeColor;
  Color? get collisionAreaColor;
  GameInterface? get interface;
  SceneBuilderStatus sceneBuilderStatus = SceneBuilderStatus();

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
  OverlayManager get overlayManager;

  /// Used to pause the engine.
  void pauseEngine();

  /// Used to resume the engine.
  void resumeEngine();

  /// Used to add component in the game.
  FutureOr<void> add(Component component);

  /// Used to add component list in the game.
  Future<void> addAll(List<Component> components);

  /// Used to get visible "Components".
  Iterable<GameComponent> visibleComponents();

  /// Used to get all "Enemies".
  Iterable<Enemy> enemies();

  /// Used to get visible "Enemies".
  Iterable<Enemy> visibleEnemies();

  /// Used to get living "Enemies".
  Iterable<Enemy> livingEnemies();

  /// Used to get all "Decoration".
  Iterable<GameDecoration> decorations();

  /// Used to get visible "Decoration".
  Iterable<GameDecoration> visibleDecorations();

  /// Used to get all "Attackables".
  Iterable<Attackable> attackables();

  /// Used to get visible "Attackables".
  Iterable<Attackable> visibleAttackables();

  /// Used to get visible "Sensors".
  Iterable<Sensor> visibleSensors();

  /// Used to get all collisions.
  Iterable<ObjectCollision> collisions();

  /// Used to get visible collisions.
  Iterable<ObjectCollision> visibleCollisions();

  /// Used to find visible component by type.
  Iterable<T> visibleComponentsByType<T>();

  /// Used to find component by type.
  Iterable<T> componentsByType<T>();

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

  void startScene(List<SceneAction> actions);
  void stopScene();

  void enableGestures(bool enable);
  void enableKeyboard(bool enable);
  bool get enabledGestures;
  bool get enabledKeyboard;
}
