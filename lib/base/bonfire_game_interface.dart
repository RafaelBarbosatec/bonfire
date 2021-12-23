import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/color_filter/color_filter_component.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/game_interface/game_interface.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/lighting/lighting.dart';
import 'package:bonfire/lighting/lighting_component.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/mixins/attackable.dart';
import 'package:bonfire/util/mixins/sensor.dart';
import 'package:bonfire/util/value_generator_component.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart' as flameGame;
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
  flameGame.Camera get camera;
  MapGame get map;
  ComponentSet get children;
  int get highestPriority;
  Vector2 get size;
  bool get hasLayout;
  GameInterface? get interface;
  flameGame.ActiveOverlaysNotifier get overlays;
  void pauseEngine();
  void resumeEngine();
  Future<void> add(Component component);
  Future<void> addAll(List<Component> components);
  Iterable<GameComponent> visibleComponents();

  Iterable<Enemy> enemies();
  Iterable<Enemy> visibleEnemies();
  Iterable<Enemy> livingEnemies();

  Iterable<GameDecoration> decorations();
  Iterable<GameDecoration> visibleDecorations();

  Iterable<Lighting> lightVisible();

  Iterable<Attackable> attackables();
  Iterable<Attackable> visibleAttackables();

  Iterable<Sensor> visibleSensors();

  Iterable<ObjectCollision> collisions();
  Iterable<ObjectCollision> visibleCollisions();

  Iterable<T> visibleComponentsByType<T>();
  Iterable<T> componentsByType<T>();

  ValueGeneratorComponent getValueGenerator(
    Duration duration, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.decelerate,
    VoidCallback? onFinish,
    ValueChanged<double>? onChange,
  });

  Vector2 worldToScreen(Vector2 position);

  Vector2 screenToWorld(Vector2 position);

  bool isVisibleInCamera(GameComponent c);

  void addJoystickObserver(
    GameComponent target, {
    bool cleanObservers = false,
    bool moveCameraToTarget = false,
  });
}
