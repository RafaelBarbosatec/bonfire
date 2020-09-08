import 'package:bonfire/base/base_game_point_detector.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/game_interface/game_interface.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/lighting/lighting.dart';
import 'package:bonfire/lighting/lighting_component.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/camera/camera.dart';
import 'package:bonfire/util/game_controller.dart';
import 'package:bonfire/util/interval_tick.dart';
import 'package:bonfire/util/map_explorer.dart';
import 'package:bonfire/util/mixins/attackable.dart';
import 'package:bonfire/util/value_generator_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RPGGame extends BaseGamePointerDetector with KeyboardEvents {
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

  Iterable<Enemy> _enemies = List();
  Iterable<Enemy> _visibleEnemies = List();
  Iterable<Enemy> _livingEnemies = List();
  Iterable<Attackable> _attackables = List();
  Iterable<GameDecoration> _decorations = List();
  Iterable<GameDecoration> _visibleDecorations = List();
  Iterable<LightingConfig> _visibleLights = List();
  Iterable<GameComponent> _visibleComponents = List();
  Iterable<Sensor> _visibleSensors = List();
  IntervalTick _interval;

  RPGGame({
    @required this.context,
    @required this.map,
    @required this.joystickController,
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
    double cameraZoom,
    Size cameraSizeMovementWindow = const Size(50, 50),
    bool cameraMoveOnlyMapArea = false,
  })  : assert(context != null),
        assert(joystickController != null) {
    gameCamera = Camera(
      zoom: cameraZoom ?? 1.0,
      sizeMovementWindow: cameraSizeMovementWindow,
      moveOnlyMapArea: cameraMoveOnlyMapArea,
      target: player,
    );
    gameCamera.gameRef = this;
    joystickController.addObserver(player ?? MapExplorer(gameCamera));
    gameController?.gameRef = this;
    if (background != null) super.add(background);
    if (map != null) super.add(map);
    decorations?.forEach((decoration) => super.add(decoration));
    enemies?.forEach((enemy) => super.add(enemy));
    components?.forEach((comp) => super.add(comp));
    if (player != null) super.add(player);
    if (lightingColorGame != null) {
      super.add(LightingComponent(color: lightingColorGame));
    }
    super.add((interface ?? GameInterface()));
    super.add(joystickController);
    _interval = IntervalTick(200, tick: _updateTempList);
  }

  @override
  void update(double t) {
    _interval.update(t);
    super.update(t);
  }

  void addGameComponent(GameComponent component) {
    addLater(component);
  }

  @override
  void add(Component c) {
    addLater(c);
  }

  Iterable<GameComponent> visibleComponents() => _visibleComponents;
  Iterable<Enemy> visibleEnemies() => _visibleEnemies;

  Iterable<Enemy> livingEnemies() => _livingEnemies;

  Iterable<GameDecoration> visibleDecorations() => _visibleDecorations;

  Iterable<Enemy> enemies() => _enemies;

  Iterable<GameDecoration> decorations() => _decorations;

  Iterable<LightingConfig> lightVisible() => _visibleLights;

  Iterable<Attackable> attackables() => _attackables;
  Iterable<Sensor> visibleSensors() => _visibleSensors;

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
    joystickController.onKeyboard(event);
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

    if (lightingColorGame != null) {
      _visibleLights = components.where((element) {
        return element is Lighting &&
            (element as Lighting).isVisible(gameCamera);
      }).map((e) => (e as Lighting).lightingConfig);
    }

    if (gameController != null) gameController.notifyListeners();
  }

  @override
  bool recordFps() => showFPS;
}
