// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:bonfire/base/base_game.dart';
import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/camera/bonfire_camera.dart';
import 'package:bonfire/color_filter/color_filter_component.dart';
import 'package:bonfire/joystick/joystick_map_explorer.dart';
import 'package:bonfire/lighting/lighting_component.dart';
import 'package:bonfire/mixins/pointer_detector.dart';
// ignore: implementation_imports
import 'package:flame/src/game/overlay_manager.dart';
import 'package:flutter/widgets.dart';

/// Is a customGame where all magic of the Bonfire happen.
class BonfireGame extends BaseGame implements BonfireGameInterface {
  static const INTERVAL_UPDATE_CACHE = 200;
  static const INTERVAL_UPDATE_ORDER = 499;

  /// Context used to access all Flutter power in your game.
  @override
  final BuildContext context;

  /// Represents the character controlled by the user in the game. Instances of this class has actions and movements ready to be used and configured.
  @override
  final Player? player;

  /// The way you can draw things like life bars, stamina and settings. In another words, anything that you may add to the interface to the game.
  @override
  final GameInterface? interface;

  /// Represents a map (or world) where the game occurs.
  @override
  final GameMap map;

  /// The player-controlling component.
  final JoystickController? _joystickController;

  /// Background of the game. This can be a color or custom component
  final GameBackground? background;

  /// Used to show grid in the map and facilitate the construction and testing of the map
  final bool constructionMode;

  /// Color grid when `constructionMode` is true
  @override
  final Color? constructionModeColor;

  /// Used to draw area collision in objects.
  @override
  final bool showCollisionArea;

  /// Color of the collision area when `showCollisionArea` is true
  @override
  final Color? collisionAreaColor;

  /// Used to extensively control game elements
  final GameController? gameController;

  /// Used to configure lighting in the game
  final Color? lightingColorGame;

  /// Callback to receive the tapDown event from the game.
  final TapInGame? onTapDown;

  /// Callback to receive the onTapUp event from the game.
  final TapInGame? onTapUp;

  @override
  SceneBuilderStatus sceneBuilderStatus = SceneBuilderStatus();

  final List<GameComponent> _visibleComponents = List.empty(growable: true);
  Iterable<ObjectCollision> _visibleCollisions = List.empty();
  final List<ObjectCollision> _collisions = List.empty(growable: true);
  final List<GameComponent> _addLater = List.empty(growable: true);
  late IntervalTick _interval;
  late IntervalTick _intervalUpdateOder;
  late ColorFilterComponent _colorFilterComponent;
  late LightingComponent _lighting;

  ValueChanged<BonfireGame>? onReady;

  @override
  LightingInterface? get lighting => _lighting;

  @override
  ColorFilterInterface? get colorFilter => _colorFilterComponent;

  @override
  JoystickController? get joystick => _joystickController;

  @override
  Color backgroundColor() => _bgColor ?? super.backgroundColor();

  Color? _bgColor;

  bool _shouldUpdatePriority = false;

  BonfireGame({
    required this.context,
    required this.map,
    JoystickController? joystickController,
    this.player,
    this.interface,
    List<Enemy>? enemies,
    List<GameDecoration>? decorations,
    List<GameComponent>? components,
    this.background,
    this.constructionMode = false,
    this.showCollisionArea = false,
    this.gameController,
    this.constructionModeColor,
    this.collisionAreaColor,
    this.lightingColorGame,
    this.onReady,
    this.onTapDown,
    this.onTapUp,
    Color? backgroundColor,
    GameColorFilter? colorFilter,
    CameraConfig? cameraConfig,
  })  : _joystickController = joystickController,
        super(camera: BonfireCamera(cameraConfig ?? CameraConfig())) {
    _bgColor = backgroundColor;
    camera.setGame(this);
    camera.target ??= player;

    _addLater.addAll(enemies ?? []);
    _addLater.addAll(decorations ?? []);
    _addLater.addAll(components ?? []);
    _lighting = LightingComponent(
      color: lightingColorGame ?? const Color(0x00000000),
    );
    _colorFilterComponent = ColorFilterComponent(
      colorFilter ?? GameColorFilter(),
    );
    _joystickController?.addObserver(player ?? JoystickMapExplorer(camera));

    debugMode = constructionMode;

    _interval = IntervalTick(
      INTERVAL_UPDATE_CACHE,
      tick: updateVisibleCollisionsMicrotask,
    );
    _intervalUpdateOder = IntervalTick(
      INTERVAL_UPDATE_ORDER,
      tick: updateOrderPriorityMicrotask,
    );
  }

  void updateVisibleCollisionsMicrotask() {
    scheduleMicrotask(_updateVisibleCollisions);
  }

  void updateOrderPriorityMicrotask() {
    if (_shouldUpdatePriority) {
      _shouldUpdatePriority = false;
      scheduleMicrotask(updateOrderPriority);
    }
  }

  @override
  FutureOr<void> onLoad() async {
    await add(_colorFilterComponent);

    if (background != null) {
      await add(background!);
    }

    await add(map);

    for (var compLate in _addLater) {
      await add(compLate);
    }
    _addLater.clear();

    if (player != null) {
      await add(player!);
    }

    await add(_lighting);

    if (interface != null) {
      await add(interface!);
    }

    if (_joystickController != null) {
      await add(_joystickController!);
    }

    if (gameController != null) {
      await add(gameController!);
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _interval.update(dt);
    _intervalUpdateOder.update(dt);
  }

  @override
  void onMount() {
    super.onMount();
    // ignore: invalid_use_of_internal_member
    setMounted();
    onReady?.call(this);
  }

  @override
  Iterable<GameComponent> visibleComponents() => _visibleComponents;

  @override
  Iterable<Enemy> visibleEnemies() {
    return visibleComponentsByType<Enemy>();
  }

  @override
  Iterable<Enemy> livingEnemies() {
    return enemies().where((element) => !element.isDead);
  }

  @override
  Iterable<Enemy> enemies() {
    return componentsByType<Enemy>();
  }

  @override
  Iterable<GameDecoration> visibleDecorations() {
    return visibleComponentsByType<GameDecoration>();
  }

  @override
  Iterable<GameDecoration> decorations() {
    return componentsByType<GameDecoration>();
  }

  @override
  Iterable<Attackable> attackables() {
    return componentsByType<Attackable>();
  }

  @override
  Iterable<Attackable> visibleAttackables() {
    return visibleComponentsByType<Attackable>();
  }

  @override
  Iterable<Sensor> visibleSensors() {
    return visibleComponentsByType<Sensor>();
  }

  @override
  Iterable<ObjectCollision> collisions() {
    return _collisions;
  }

  @override
  Iterable<ObjectCollision> visibleCollisions() {
    return _visibleCollisions;
  }

  @override
  Iterable<T> visibleComponentsByType<T>() {
    return _visibleComponents.whereType<T>();
  }

  @override
  Iterable<T> componentsByType<T>() {
    return children.whereType<T>();
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    _updateVisibleCollisions();
    camera.onGameResize(canvasSize);
  }

  void _updateVisibleCollisions() {
    _visibleCollisions = _collisions.where(_isVisibleCollision);
    gameController?.notifyListeners();
  }

  bool _isVisibleCollision(element) {
    return element.isVisible || element is Tile;
  }

  @override
  Vector2 worldToScreen(Vector2 position) {
    return camera.worldToScreen(position);
  }

  @override
  Vector2 screenToWorld(Vector2 position) {
    return camera.screenToWorld(position);
  }

  @override
  bool isVisibleInCamera(GameComponent c) {
    if (!hasLayout) return false;
    if (c.isRemoving) return false;
    return camera.isComponentOnCamera(c);
  }

  @override
  void onPointerDown(PointerDownEvent event) {
    if (onTapDown != null) {
      final localPosition = event.localPosition.toVector2();
      onTapDown?.call(
        this,
        localPosition,
        camera.screenToWorld(localPosition),
      );
    }
    super.onPointerDown(event);
  }

  @override
  void onPointerUp(PointerUpEvent event) {
    if (onTapUp != null) {
      final localPosition = event.localPosition.toVector2();
      onTapUp?.call(
        this,
        localPosition,
        camera.screenToWorld(localPosition),
      );
    }
    super.onPointerUp(event);
  }

  /// Use this method to change default observer of the Joystick events.
  @override
  void addJoystickObserver(
    JoystickListener target, {
    bool cleanObservers = false,
    bool moveCameraToTarget = false,
  }) {
    if (cleanObservers) {
      _joystickController?.cleanObservers();
    }
    _joystickController?.addObserver(target);
    if (moveCameraToTarget && target is GameComponent) {
      camera.moveToTargetAnimated(target as GameComponent);
    }
  }

  @override
  void startScene(List<SceneAction> actions) {
    if (!sceneBuilderStatus.isRunning) {
      add(SceneBuilderComponent(actions));
    }
  }

  @override
  void stopScene() {
    try {
      children
          .firstWhere((value) => value is SceneBuilderComponent)
          .removeFromParent();
    } catch (e) {
      /// Not found SceneBuilderComponent
    }
  }

  @override
  void onDetach() {
    children.query<GameComponent>().forEach(_detachComp);
    super.onDetach();
  }

  void _detachComp(GameComponent c) => c.onGameDetach();

  void addCollision(ObjectCollision obj) {
    _collisions.add(obj);
  }

  void removeCollision(ObjectCollision obj) {
    _collisions.remove(obj);
  }

  void addVisible(GameComponent obj) {
    _visibleComponents.add(obj);
  }

  void removeVisible(GameComponent obj) {
    _visibleComponents.remove(obj);
  }

  @override
  // ignore: invalid_use_of_internal_member
  OverlayManager get overlayManager => overlays;

  @override
  void enableGestures(bool enable) {
    enabledGestures = enable;
  }

  @override
  void enableKeyboard(bool enable) {
    enabledKeyboard = enable;
  }

  void requestUpdatePriority() {
    _shouldUpdatePriority = true;
  }
}
