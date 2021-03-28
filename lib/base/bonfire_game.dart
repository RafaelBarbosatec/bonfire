import 'package:bonfire/base/base_game_point_detector.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/game_interface/game_interface.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/lighting/lighting.dart';
import 'package:bonfire/lighting/lighting_component.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/camera/camera.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/color_filter_component.dart';
import 'package:bonfire/util/game_color_filter.dart';
import 'package:bonfire/util/game_controller.dart';
import 'package:bonfire/util/interval_tick.dart';
import 'package:bonfire/util/map_explorer.dart';
import 'package:bonfire/util/mixins/attackable.dart';
import 'package:bonfire/util/value_generator_component.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BonfireGame extends BaseGamePointerDetector with KeyboardEvents {
  final BuildContext context;
  final Player player;
  final GameInterface interface;
  final MapGame map;
  final JoystickController joystickController;
  final GameComponent background;
  final bool constructionMode;
  final bool showCollisionArea;
  final bool showFPS;
  final GameController gameController;
  final Color constructionModeColor;
  final Color lightingColorGame;
  final Color collisionAreaColor;

  Iterable<Enemy> _enemies = [];
  Iterable<Enemy> _visibleEnemies = [];
  Iterable<Enemy> _livingEnemies = [];
  Iterable<Attackable> _attackables = [];
  Iterable<GameDecoration> _decorations = [];
  Iterable<GameDecoration> _visibleDecorations = [];
  Iterable<Lighting> _visibleLights = [];
  Iterable<GameComponent> _visibleComponents = [];
  Iterable<Sensor> _visibleSensors = [];
  Iterable<ObjectCollision> _visibleCollisions = [];
  Iterable<ObjectCollision> _collisions = [];
  IntervalTick _interval;
  ColorFilterComponent _colorFilterComponent =
      ColorFilterComponent(GameColorFilter());
  LightingComponent lighting;

  BonfireGame({
    @required this.context,
    this.map,
    this.joystickController,
    this.player,
    this.interface,
    List<Enemy> enemies,
    List<GameDecoration> decorations,
    List<GameComponent> components,
    this.background,
    this.constructionMode = false,
    this.showCollisionArea = false,
    this.showFPS = false,
    this.gameController,
    this.constructionModeColor,
    this.collisionAreaColor,
    this.lightingColorGame,
    GameColorFilter colorFilter,
    double cameraZoom,
    Size cameraSizeMovementWindow = const Size(50, 50),
    bool cameraMoveOnlyMapArea = false,
  }) : assert(context != null) {
    if (colorFilter != null)
      _colorFilterComponent = ColorFilterComponent(colorFilter);
    _colorFilterComponent.gameRef = this;
    super.add(_colorFilterComponent);
    gameCamera = Camera(
      zoom: cameraZoom ?? 1.0,
      sizeMovementWindow: cameraSizeMovementWindow,
      moveOnlyMapArea: cameraMoveOnlyMapArea,
      target: player,
    );
    gameCamera.gameRef = this;
    gameController?.gameRef = this;
    if (background != null) super.add(background);
    if (map != null) super.add(map);
    decorations?.forEach((decoration) => super.add(decoration));
    enemies?.forEach((enemy) => super.add(enemy));
    components?.forEach((comp) => super.add(comp));
    if (player != null) super.add(player);
    lighting = LightingComponent(color: lightingColorGame);
    super.add(lighting);
    super.add((interface ?? GameInterface()));
    super.add(joystickController ?? Joystick());
    joystickController?.addObserver(player ?? MapExplorer(gameCamera));
    _interval = IntervalTick(200, tick: _updateTempList);
  }

  @override
  void update(double t) {
    _interval.update(t);
    super.update(t);
  }

  void addGameComponent(GameComponent component) {
    add(component);
  }

  Iterable<GameComponent> visibleComponents() => _visibleComponents;
  Iterable<Enemy> visibleEnemies() => _visibleEnemies;

  Iterable<Enemy> livingEnemies() => _livingEnemies;

  Iterable<GameDecoration> visibleDecorations() => _visibleDecorations;

  Iterable<Enemy> enemies() => _enemies;

  Iterable<GameDecoration> decorations() => _decorations;

  Iterable<Lighting> lightVisible() => _visibleLights;

  Iterable<Attackable> attackables() => _attackables;
  Iterable<Sensor> visibleSensors() => _visibleSensors;

  Iterable<ObjectCollision> collisions() => _collisions;
  Iterable<ObjectCollision> visibleCollisions() => _visibleCollisions;

  ValueGeneratorComponent getValueGenerator(
    Duration duration, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.decelerate,
    VoidCallback onFinish,
    ValueChanged<double> onChange,
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
  void resize(Size size) {
    super.resize(size);
    _updateTempList();
  }

  void _updateTempList() {
    _visibleComponents = components.where((element) {
      return (element is GameComponent) && (element).isVisibleInCamera();
    }).cast();

    _decorations = components.where((element) {
      return (element is GameDecoration);
    }).cast();

    _visibleDecorations = _decorations.where((element) {
      return element.isVisibleInCamera();
    });

    _enemies = components.where((element) => (element is Enemy)).cast();
    _livingEnemies = _enemies.where((element) => !element.isDead).cast();
    _visibleEnemies = _livingEnemies.where((element) {
      return element.isVisibleInCamera();
    });

    _visibleSensors =
        _visibleComponents.where((element) => (element is Sensor)).cast();
    _attackables =
        _visibleComponents.where((element) => (element is Attackable)).cast();

    _collisions =
        components.where((element) => (element is ObjectCollision)).cast();
    _visibleCollisions = _visibleComponents
        .where((element) => (element is ObjectCollision))
        .cast();

    if (lightingColorGame != null) {
      _visibleLights = components.where((element) {
        return element is Lighting &&
            (element as Lighting).isVisible(gameCamera);
      }).cast();
    }

    if (gameController != null) gameController.notifyListeners();
  }

  @override
  bool recordFps() => showFPS;

  GameColorFilter get colorFilter => _colorFilterComponent.colorFilter;
}
