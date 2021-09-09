import 'dart:async';

import 'package:bonfire/base/custom_base_game.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/camera/camera.dart';
import 'package:bonfire/camera/camera_config.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/game_interface/game_interface.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/lighting/lighting.dart';
import 'package:bonfire/lighting/lighting_component.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/color_filter_component.dart';
import 'package:bonfire/util/game_color_filter.dart';
import 'package:bonfire/util/game_controller.dart';
import 'package:bonfire/util/interval_tick.dart';
import 'package:bonfire/util/map_explorer.dart';
import 'package:bonfire/util/mixins/attackable.dart';
import 'package:bonfire/util/mixins/pointer_detector.dart';
import 'package:bonfire/util/value_generator_component.dart';
import 'package:flame/components.dart' hide JoystickController;
import 'package:flame/keyboard.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Is a customGame where all magic of the Bonfire happen.
class BonfireGame extends CustomBaseGame with KeyboardEvents {
  static const INTERVAL_UPDATE_CACHE = 200;
  static const INTERVAL_UPDATE_ORDER = 253;
  static const INTERVAL_UPDATE_COLLISIONS = 1003;

  /// Context used to access all Flutter power in your game.
  final BuildContext context;

  /// Represents the character controlled by the user in the game. Instances of this class has actions and movements ready to be used and configured.
  final Player? player;

  /// The way you can draw things like life bars, stamina and settings. In another words, anything that you may add to the interface to the game.
  final GameInterface? interface;

  /// Represents a map (or world) where the game occurs.
  final MapGame map;

  /// The player-controlling component.
  final JoystickController? joystickController;

  /// Background of the game. This can be a color or custom component
  final GameBackground? background;

  /// Used to show grid in the map and facilitate the construction and testing of the map
  final bool constructionMode;

  /// Color grid when `constructionMode` is true
  final Color? constructionModeColor;

  /// Used to draw area collision in objects.
  final bool showCollisionArea;

  /// Color of the collision area when `showCollisionArea` is true
  final Color? collisionAreaColor;

  /// Used to extensively control game elements
  final GameController? gameController;

  /// Used to configure lighting in the game
  final Color? lightingColorGame;

  /// Used to show in the interface the FPS.
  final bool showFPS;

  final TapInGame? onTapDown;
  final TapInGame? onTapUp;

  bool _firstUpdate = true;

  Iterable<Lighting> _visibleLights = List.empty();
  Iterable<GameComponent> _visibleComponents = List.empty();
  List<ObjectCollision> _visibleCollisions = List.empty();
  List<ObjectCollision> _collisions = List.empty();
  IntervalTick? _interval;
  IntervalTick? _intervalUpdateOder;
  IntervalTick? _intervalAllCollisions;
  ColorFilterComponent _colorFilterComponent = ColorFilterComponent(
    GameColorFilter(),
  );
  LightingComponent? lighting;

  List<Enemy>? _initialEnemies;
  List<GameDecoration>? _initialDecorations;
  List<GameComponent>? _initialComponents;

  GameColorFilter? _colorFilter;

  ValueChanged<BonfireGame>? onReady;

  BonfireGame({
    required this.context,
    required this.map,
    this.joystickController,
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
    this.showFPS = false,
    this.onReady,
    this.onTapDown,
    this.onTapUp,
    GameColorFilter? colorFilter,
    CameraConfig? cameraConfig,
  }) {
    _initialEnemies = enemies;
    _initialDecorations = decorations;
    _initialComponents = components;
    _colorFilter = colorFilter;
    debugMode = constructionMode;

    gameController?.gameRef = this;
    camera = Camera(cameraConfig ?? CameraConfig());
    camera.gameRef = this;
    if (camera.config.target == null && player != null) {
      camera.moveToTarget(player!);
    }

    _interval = IntervalTick(
      INTERVAL_UPDATE_CACHE,
      tick: _updateTempList,
    );
    _intervalUpdateOder = IntervalTick(
      INTERVAL_UPDATE_ORDER,
      tick: updateOrderPriority,
    );
    _intervalAllCollisions = IntervalTick(
      INTERVAL_UPDATE_COLLISIONS,
      tick: () => scheduleMicrotask(_updateAllCollisions),
    );
  }

  @override
  Future<void> onLoad() async {
    _colorFilterComponent = ColorFilterComponent(
      _colorFilter ?? GameColorFilter(),
    );
    add(_colorFilterComponent);

    background?.let((bg) => add(bg));

    add(map);
    _initialDecorations?.forEach((decoration) => add(decoration));
    _initialEnemies?.forEach((enemy) => add(enemy));
    _initialComponents?.forEach((comp) => add(comp));
    player?.let((p) => add(p));
    lighting = LightingComponent(color: lightingColorGame ?? Color(0x00000000));
    add(lighting!);
    add(interface ?? GameInterface());
    add(joystickController ?? Joystick());
    joystickController?.addObserver(player ?? MapExplorer(camera));
    return super.onLoad();
  }

  @override
  void update(double t) {
    super.update(t);
    _interval?.update(t);
    _intervalUpdateOder?.update(t);
    _intervalAllCollisions?.update(t);

    if (_firstUpdate) {
      _firstUpdate = false;
      onReady?.call(this);
    }
  }

  void addGameComponent(GameComponent component) {
    add(component);
  }

  Iterable<GameComponent> visibleComponents() => _visibleComponents;

  Iterable<Enemy> visibleEnemies() {
    return _visibleComponents.where((element) => (element is Enemy)).cast();
  }

  Iterable<Enemy> livingEnemies() {
    return enemies().where((element) => !element.isDead).cast();
  }

  Iterable<Enemy> enemies() {
    return components.where((element) => (element is Enemy)).cast();
  }

  Iterable<GameDecoration> visibleDecorations() {
    return _visibleComponents
        .where((element) => (element is GameDecoration))
        .cast();
  }

  Iterable<GameDecoration> decorations() {
    return components.where((element) => (element is GameDecoration)).cast();
  }

  Iterable<Lighting> lightVisible() => _visibleLights;

  Iterable<Attackable> attackables() {
    return components.where((element) => (element is Attackable)).cast();
  }

  Iterable<Attackable> visibleAttackables() {
    return _visibleComponents
        .where((element) => (element is Attackable))
        .cast();
  }

  Iterable<Sensor> visibleSensors() {
    return _visibleComponents.where((element) {
      return (element is Sensor);
    }).cast();
  }

  Iterable<ObjectCollision> collisions() {
    return _collisions;
  }

  Iterable<ObjectCollision> visibleCollisions() {
    return _visibleCollisions;
  }

  Iterable<T> visibleComponentsByType<T>() {
    return _visibleComponents.whereType<T>();
  }

  Iterable<T> componentsByType<T>() {
    return components.whereType<T>();
  }

  ValueGeneratorComponent getValueGenerator(
    Duration duration, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.decelerate,
    VoidCallback? onFinish,
    ValueChanged<double>? onChange,
  }) {
    final valueGenerator = ValueGeneratorComponent(
      duration,
      end: end,
      begin: begin,
      curve: curve,
      onFinish: onFinish,
      onChange: onChange,
    );
    add(valueGenerator);
    return valueGenerator;
  }

  @override
  void onKeyEvent(RawKeyEvent event) {
    joystickController?.onKeyboard(event);
  }

  @override
  void onResize(Vector2 size) {
    super.onResize(size);
    _updateTempList();
  }

  void _updateTempList() {
    _visibleComponents = components.where((element) {
      return (element is GameComponent) && (element).isVisible;
    }).cast()
      ..toList(growable: false);

    _visibleCollisions = _visibleComponents
        .where((element) {
          return (element is ObjectCollision) && element.containCollision();
        })
        .toList()
        .cast();

    _visibleCollisions.addAll(map.getCollisionsRendered());

    _visibleLights = _visibleComponents.whereType<Lighting>();

    gameController?.notifyListeners();
  }

  void _updateAllCollisions() {
    _collisions = components
        .where((element) {
          return (element is ObjectCollision) && (element).containCollision();
        })
        .toList()
        .cast();

    _collisions.addAll(map.getCollisions());
  }

  GameColorFilter get colorFilter => _colorFilterComponent.colorFilter;

  Offset worldPositionToScreen(Offset position) {
    return camera.worldPositionToScreen(position);
  }

  Offset screenPositionToWorld(Offset position) {
    return camera.screenPositionToWorld(position);
  }

  bool isVisibleInCamera(GameComponent c) {
    if (c.shouldRemove) return false;
    return camera.isComponentOnCamera(c);
  }

  @override
  void onPointerDown(PointerDownEvent event) {
    onTapDown?.call(
      this,
      event.localPosition,
      camera.screenPositionToWorld(event.localPosition),
    );
    super.onPointerDown(event);
  }

  @override
  void onPointerUp(PointerUpEvent event) {
    onTapUp?.call(
      this,
      event.localPosition,
      camera.screenPositionToWorld(event.localPosition),
    );
    super.onPointerUp(event);
  }
}
