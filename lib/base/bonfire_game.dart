import 'dart:async';

import 'package:bonfire/base/base_game.dart';
import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/camera/bonfire_camera.dart';
import 'package:bonfire/color_filter/color_filter_component.dart';
import 'package:bonfire/lighting/lighting_component.dart';
import 'package:bonfire/util/map_explorer.dart';
import 'package:bonfire/util/mixins/pointer_detector.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Is a customGame where all magic of the Bonfire happen.
class BonfireGame extends BaseGame
    with KeyboardEvents
    implements BonfireGameInterface {
  static const INTERVAL_UPDATE_CACHE = 200;
  static const INTERVAL_UPDATE_ORDER = 253;
  static const INTERVAL_UPDATE_COLLISIONS = 1003;

  /// Context used to access all Flutter power in your game.
  @override
  final BuildContext context;

  /// Represents the character controlled by the user in the game. Instances of this class has actions and movements ready to be used and configured.
  @override
  final Player? player;

  /// The way you can draw things like life bars, stamina and settings. In another words, anything that you may add to the interface to the game.
  final GameInterface? interface;

  /// Represents a map (or world) where the game occurs.
  final MapGame map;

  /// The player-controlling component.
  final JoystickController? _joystickController;

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

  /// Callback to receive the tapDown event from the game.
  final TapInGame? onTapDown;

  /// Callback to receive the onTapUp event from the game.
  final TapInGame? onTapUp;

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
  LightingComponent? _lighting;

  List<Enemy>? _initialEnemies;
  List<GameDecoration>? _initialDecorations;
  List<GameComponent>? _initialComponents;

  GameColorFilter? _colorFilter;

  ValueChanged<BonfireGame>? onReady;

  @override
  LightingInterface? get lighting => _lighting;

  @override
  ColorFilterInterface? get colorFilter => _colorFilterComponent;

  @override
  JoystickController? get joystick => _joystickController;

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
    this.showFPS = false,
    this.onReady,
    this.onTapDown,
    this.onTapUp,
    GameColorFilter? colorFilter,
    CameraConfig? cameraConfig,
  })  : _joystickController = joystickController,
        super(camera: BonfireCamera(cameraConfig ?? CameraConfig())) {
    _initialEnemies = enemies;
    _initialDecorations = decorations;
    _initialComponents = components;
    _colorFilter = colorFilter ?? GameColorFilter();
    debugMode = constructionMode;

    camera.setGame(this);
    camera.target ??= player;

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
  Future<void>? onLoad() async {
    await super.onLoad();
    _colorFilterComponent = ColorFilterComponent(
      _colorFilter ?? GameColorFilter(),
    );
    await add(_colorFilterComponent);

    if (background != null) {
      await add(background!);
    }

    await add(map);

    if (_initialDecorations != null) {
      await Future.forEach<GameComponent>(
          _initialDecorations!, (element) => add(element));
    }
    if (_initialEnemies != null) {
      await Future.forEach<GameComponent>(
          _initialEnemies!, (element) => add(element));
    }
    if (_initialComponents != null) {
      await Future.forEach<GameComponent>(
          _initialComponents!, (element) => add(element));
    }
    if (player != null) {
      await add(player!);
    }
    _lighting = LightingComponent(
      color: lightingColorGame ?? Color(0x00000000),
    );
    await add(_lighting!);
    await add(interface ?? GameInterface());
    await add(_joystickController ?? Joystick());
    _joystickController?.addObserver(player ?? MapExplorer(camera));
    if (gameController != null) {
      await add(gameController!);
    }
  }

  @override
  void update(double t) {
    super.update(t);
    _interval?.update(t);
    _intervalUpdateOder?.update(t);
    _intervalAllCollisions?.update(t);
  }

  @override
  void onMount() {
    onReady?.call(this);
    super.onMount();
  }

  @override
  Iterable<GameComponent> visibleComponents() => _visibleComponents;

  @override
  Iterable<Enemy> visibleEnemies() {
    return _visibleComponents.where((element) => (element is Enemy)).cast();
  }

  @override
  Iterable<Enemy> livingEnemies() {
    return enemies().where((element) => !element.isDead).cast();
  }

  @override
  Iterable<Enemy> enemies() {
    return children.where((element) => (element is Enemy)).cast();
  }

  @override
  Iterable<GameDecoration> visibleDecorations() {
    return _visibleComponents
        .where((element) => (element is GameDecoration))
        .cast();
  }

  @override
  Iterable<GameDecoration> decorations() {
    return children.where((element) => (element is GameDecoration)).cast();
  }

  @override
  Iterable<Lighting> visibleLighting() => _visibleLights;

  @override
  Iterable<Attackable> attackables() {
    return children.where((element) => (element is Attackable)).cast();
  }

  @override
  Iterable<Attackable> visibleAttackables() {
    return _visibleComponents
        .where((element) => (element is Attackable))
        .cast();
  }

  @override
  Iterable<Sensor> visibleSensors() {
    return _visibleComponents.where((element) {
      return (element is Sensor);
    }).cast();
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
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (_joystickController?.keyboardConfig.acceptedKeys != null) {
      final keyAccepted = _joystickController?.keyboardConfig.acceptedKeys;
      if (keyAccepted!.contains(event.logicalKey)) {
        _joystickController?.onKeyboard(event);
        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    }
    _joystickController?.onKeyboard(event);
    return KeyEventResult.handled;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updateTempList();
  }

  void _updateTempList() {
    _visibleComponents = children.where((element) {
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
    _collisions = children
        .where((element) {
          return (element is ObjectCollision) && (element).containCollision();
        })
        .toList()
        .cast();

    _collisions.addAll(map.getCollisions());
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
    if (c.shouldRemove) return false;
    return camera.isComponentOnCamera(c);
  }

  @override
  void onPointerDown(PointerDownEvent event) {
    final localPosition = event.localPosition.toVector2();
    onTapDown?.call(
      this,
      localPosition,
      camera.screenToWorld(localPosition),
    );
    super.onPointerDown(event);
  }

  @override
  void onPointerUp(PointerUpEvent event) {
    final localPosition = event.localPosition.toVector2();
    onTapUp?.call(
      this,
      localPosition,
      camera.screenToWorld(localPosition),
    );
    super.onPointerUp(event);
  }

  /// Use this method to change default observer of the Joystick events.
  @override
  void addJoystickObserver(
    GameComponent target, {
    bool cleanObservers = false,
    bool moveCameraToTarget = false,
  }) {
    if (target is JoystickListener) {
      if (cleanObservers) {
        _joystickController?.cleanObservers();
      }
      _joystickController?.addObserver(target as JoystickListener);
      if (moveCameraToTarget) {
        camera.moveToTargetAnimated(target);
      }
    } else {
      print('$target is not a JoystickListener');
    }
  }
}
