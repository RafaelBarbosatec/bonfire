// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:bonfire/base/base_game.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/camera/bonfire_camera.dart';
import 'package:bonfire/color_filter/color_filter_component.dart';
import 'package:bonfire/joystick/joystick_map_explorer.dart';
import 'package:bonfire/lighting/lighting_component.dart';
// ignore: implementation_imports
import 'package:flame/src/camera/viewports/fixed_resolution_viewport.dart';
// ignore: implementation_imports
import 'package:flutter/widgets.dart';

/// Is a customGame where all magic of the Bonfire happen.
class BonfireGame extends BaseGame implements BonfireGameInterface {
  static const INTERVAL_UPDATE_ORDER = 500;
  static const INTERVAL_OPTIMIZE_TREE = 5001;

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
  final JoystickController? joystickController;

  /// Background of the game. This can be a color or custom component
  final GameBackground? background;

  /// Used to draw area collision in objects.
  @override
  final bool showCollisionArea;

  /// Color of the collision area when `showCollisionArea` is true
  @override
  final Color? collisionAreaColor;

  /// Used to configure lighting in the game
  final Color? lightingColorGame;

  @override
  final List<Force2D> globalForces;

  @override
  SceneBuilderStatus sceneBuilderStatus = SceneBuilderStatus();

  final List<GameComponent> _visibleComponents = List.empty(growable: true);
  final List<ShapeHitbox> _visibleCollisions = List.empty(growable: true);
  late IntervalTick _intervalUpdateOder;
  late IntervalTick _intervalOprimizeTree;

  ValueChanged<BonfireGame>? onReady;

  @override
  LightingInterface get lighting =>
      camera.viewport.children.whereType<LightingInterface>().first;

  @override
  ColorFilterInterface get colorFilter =>
      camera.viewport.children.whereType<ColorFilterInterface>().first;

  @override
  JoystickController? get joystick => joystickController;

  @override
  Color backgroundColor() => _bgColor ?? super.backgroundColor();

  Color? _bgColor;

  bool _shouldUpdatePriority = false;

  @override
  BonfireCamera get camera => super.camera as BonfireCamera;

  @override
  set camera(CameraComponent newCameraComponent) {
    throw Exception('Is forbiden updade camera');
  }

  /// variable that keeps the highest rendering priority per frame. This is used to determine the order in which to render the `interface`, `lighting` and `joystick`
  int _highestPriority = 1000000;

  /// Get of the _highestPriority
  @override
  int get highestPriority => _highestPriority;

  BonfireGame({
    required this.context,
    required this.map,
    this.joystickController,
    this.player,
    this.interface,
    List<GameComponent>? components,
    this.background,
    bool debugMode = false,
    this.showCollisionArea = false,
    this.collisionAreaColor,
    this.lightingColorGame,
    this.onReady,
    Color? backgroundColor,
    GameColorFilter? colorFilter,
    CameraConfig? cameraConfig,
    List<Force2D>? globalForces,
  })  : globalForces = globalForces ?? [],
        super(
          camera: BonfireCamera(
            config: cameraConfig,
            viewport: cameraConfig?.resolution != null
                ? FixedResolutionViewport(resolution: cameraConfig!.resolution!)
                : null,
            hudComponents: [
              LightingComponent(
                color: lightingColorGame ?? const Color(0x00000000),
              ),
              ColorFilterComponent(
                colorFilter ?? GameColorFilter(),
              ),
              if (joystickController != null) joystickController,
              if (interface != null) interface,
            ],
          ),
          world: World(
            children: [
              map,
              if (background != null) background,
              if (player != null) player,
              ...components ?? [],
            ],
          ),
        ) {
    this.debugMode = debugMode;
    _bgColor = backgroundColor;

    _intervalUpdateOder = IntervalTick(
      INTERVAL_UPDATE_ORDER,
      onTick: _updateOrderPriorityMicrotask,
    );
    _intervalOprimizeTree = IntervalTick(
      INTERVAL_OPTIMIZE_TREE,
      onTick: _optimizeCollisionTree,
    );
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    initializeCollisionDetection(
      mapDimensions: Rect.zero,
    );

    joystickController?.addObserver(
      player ?? JoystickMapExplorer(camera),
    );

    if (camera.config.target != null) {
      camera.follow(
        camera.config.target!,
        snap: true,
      );
    } else if (player != null && camera.config.startFollowPlayer) {
      camera.moveToPlayer();
    }
  }

  void configCollision() {
    initializeCollisionDetection(
      mapDimensions: Rect.fromLTWH(
        -map.tileSize,
        -map.tileSize,
        map.size.x.ceilToDouble() + map.tileSize * 2,
        map.size.y.ceilToDouble() + map.tileSize * 2,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _intervalUpdateOder.update(dt);
    _intervalOprimizeTree.update(dt);
  }

  @override
  void onMount() {
    super.onMount();
    // ignore: invalid_use_of_internal_member
    setMounted();
    onReady?.call(this);
  }

  @override
  Iterable<T> visibles<T extends GameComponent>() {
    return _visibleComponents.whereType<T>();
  }

  @override
  Iterable<Enemy> livingEnemies({bool onlyVisible = false}) {
    return enemies(onlyVisible: onlyVisible)
        .where((element) => !element.isDead);
  }

  @override
  Iterable<Enemy> enemies({bool onlyVisible = false}) {
    return query<Enemy>(onlyVisible: onlyVisible);
  }

  @override
  Iterable<GameDecoration> decorations({bool onlyVisible = false}) {
    return query<GameDecoration>(onlyVisible: onlyVisible);
  }

  @override
  Iterable<Attackable> attackables({bool onlyVisible = false}) {
    return query<Attackable>(onlyVisible: onlyVisible);
  }

  @override
  Iterable<ShapeHitbox> collisions({bool onlyVisible = false}) {
    if (onlyVisible) {
      List<ShapeHitbox> tilesCollision = [];
      map
          .getRendered()
          .where((element) => element.containsShapeHitbox)
          .forEach((e) {
        tilesCollision.addAll(e.children.query<ShapeHitbox>());
      });
      return [
        ..._visibleCollisions,
        ...tilesCollision,
      ];
    }
    return collisionDetection.items;
  }

  @override
  Iterable<T> query<T extends Component>({bool onlyVisible = false}) {
    if (onlyVisible) {
      return _visibleComponents.whereType<T>();
    }
    return world.children.query<T>();
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
    return camera.canSee(c);
  }

  /// Use this method to change default observer of the Joystick events.
  @override
  void addJoystickObserver(
    JoystickListener target, {
    bool cleanObservers = false,
    bool moveCameraToTarget = false,
  }) {
    if (cleanObservers) {
      joystickController?.cleanObservers();
    }
    joystickController?.addObserver(target);
    if (moveCameraToTarget && target is GameComponent) {
      camera.follow(target as GameComponent);
    }
  }

  @override
  void startScene(List<SceneAction> actions, {void Function()? onComplete}) {
    if (!sceneBuilderStatus.isRunning) {
      add(SceneBuilderComponent(actions, onComplete: onComplete));
    }
  }

  @override
  void stopScene() {
    try {
      world.children
          .firstWhere((value) => value is SceneBuilderComponent)
          .removeFromParent();
    } catch (e) {
      /// Not found SceneBuilderComponent
    }
  }

  @override
  void onDetach() {
    world.children.query<GameComponent>().forEach(_detachComp);
    camera.viewport.children.query<GameComponent>().forEach(_detachComp);
    FollowerWidget.removeAll();
    super.onDetach();
  }

  void _detachComp(GameComponent c) => c.onGameDetach();

  void addVisible(GameComponent obj) {
    _visibleComponents.add(obj);
    if (obj.containsShapeHitbox) {
      _visibleCollisions.addAll(obj.children.query<ShapeHitbox>());
    }
  }

  void removeVisible(GameComponent obj) {
    _visibleComponents.remove(obj);
    if (obj.containsShapeHitbox) {
      obj.children.query<ShapeHitbox>().forEach((element) {
        _visibleCollisions.remove(element);
      });
    }
  }

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

  @override
  FutureOr<void> add(Component component) {
    if (component is CameraComponent || component is World) {
      super.add(component);
    } else {
      return world.add(component);
    }
  }

  @override
  Future<void> addAll(Iterable<Component> components) {
    return world.addAll(components);
  }

  /// reorder components by priority
  void _updateOrderPriority() {
    // ignore: invalid_use_of_internal_member
    world.children.reorder();
    _highestPriority = world.children.last.priority;
  }

  @override
  List<RaycastResult<ShapeHitbox>> raycastAll(
    Vector2 origin, {
    required int numberOfRays,
    double startAngle = 0,
    double sweepAngle = tau,
    double? maxDistance,
    List<Ray2>? rays,
    List<ShapeHitbox>? ignoreHitboxes,
    List<RaycastResult<ShapeHitbox>>? out,
  }) {
    return collisionDetection.raycastAll(
      origin,
      numberOfRays: numberOfRays,
      startAngle: startAngle,
      sweepAngle: sweepAngle,
      maxDistance: maxDistance,
      rays: rays,
      ignoreHitboxes: ignoreHitboxes,
      out: out,
    );
  }

  @override
  RaycastResult<ShapeHitbox>? raycast(
    Ray2 ray, {
    double? maxDistance,
    List<ShapeHitbox>? ignoreHitboxes,
    RaycastResult<ShapeHitbox>? out,
  }) {
    return collisionDetection.raycast(
      ray,
      maxDistance: maxDistance,
      ignoreHitboxes: ignoreHitboxes,
      out: out,
    );
  }

  @override
  Iterable<RaycastResult<ShapeHitbox>> raytrace(
    Ray2 ray, {
    int maxDepth = 10,
    List<ShapeHitbox>? ignoreHitboxes,
    List<RaycastResult<ShapeHitbox>>? out,
  }) {
    return collisionDetection.raytrace(
      ray,
      maxDepth: maxDepth,
      ignoreHitboxes: ignoreHitboxes,
      out: out,
    );
  }

  void _optimizeCollisionTree() {
    scheduleMicrotask(
      () => collisionDetection.broadphase.tree.optimize(),
    );
  }

  void _updateOrderPriorityMicrotask() {
    if (_shouldUpdatePriority) {
      _shouldUpdatePriority = false;
      scheduleMicrotask(_updateOrderPriority);
    }
  }
}
