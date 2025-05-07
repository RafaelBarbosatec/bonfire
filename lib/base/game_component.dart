import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/pointer_detector.dart';
import 'package:flutter/widgets.dart';

/// Base of the all components in the Bonfire
abstract class GameComponent extends PositionComponent
    with
        BonfireHasGameRef,
        PointerDetectorHandler,
        InternalChecker,
        HasPaint,
        CollisionCallbacks {
  Map<String, dynamic>? properties;

  /// When true this component render above all components in game.
  bool renderAboveComponents = false;
  bool get isHud => _isHud;
  bool _isHud = false;
  bool? _visibleCache;

  bool get isVisible {
    if (_visibleCache != null) {
      return _visibleCache!;
    }
    // HUD components are always visible if _visible is true
    if (isHud) {
      return _visibleCache = true;
    }

    return _visibleCache = isVisibleInCamera();
  }

  bool get isHidded => paint.color == const Color(0x00000000);

  void hideComp() {
    paint.color = const Color(0x00000000);
  }

  void showComp() {
    paint.color = const Color(0xFFFFFFFF);
  }

  /// Get BuildContext
  BuildContext get context => gameRef.context;

  double lastAngle = 0;

  bool _gameMounted = false;
  bool get gameMonuted => _gameMounted;

  @override
  set angle(double a) {
    lastAngle = super.angle;
    super.angle = a;
  }

  Rect? _rectCollision;

  double lastDt = 0;

  @override
  int get priority {
    if (renderAboveComponents && hasGameRef) {
      return LayerPriority.getAbovePriority(gameRef.highestPriority);
    }
    return LayerPriority.getComponentPriority(rectCollision.bottom.floor());
  }

  @override
  void update(double dt) {
    lastDt = dt;
    super.update(dt);
  }

  int _contV = 0;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_visibleCache != null) {
      if (_contV > 4) {
        _contV = 0;
        _visibleCache = null;
      } else {
        _contV++;
      }
    }
  }

  /// Return screen position of this component.
  Vector2 screenPosition() {
    if (hasGameRef) {
      return gameRef.worldToScreen(
        position,
      );
    }
    return Vector2.zero();
  }

  /// Method that checks if this component is visible on the screen
  @mustCallSuper
  bool isVisibleInCamera() {
    if (hasGameRef) {
      return gameRef.isVisibleInCamera(this);
    }
    return false;
  }

  @override
  Future<void> addAll(Iterable<Component> components) {
    components.forEach(_confHitBoxRender);
    return super.addAll(components);
  }

  @override
  FutureOr<void> add(Component component) async {
    _confHitBoxRender(component);
    if (component is ShapeHitbox) {
      _rectCollision = null;
    }
    return super.add(component);
  }

  void _confHitBoxRender(Component component) {
    if (component is ShapeHitbox && gameRef.showCollisionArea) {
      final paintCollition = Paint()
        ..color = gameRef.collisionAreaColor ?? const Color(0xffffffff);
      if (this is Sensor) {
        paintCollition.color = Sensor.color;
      }
      component.paint = paintCollition;
      component.renderShape = true;
    }
  }

  bool get containsShapeHitbox {
    return shapeHitboxes.isNotEmpty;
  }

  Iterable<ShapeHitbox> get shapeHitboxes => children.query<ShapeHitbox>();

  Rect get rectCollision {
    if (_rectCollision == null) {
      final list = children.query<ShapeHitbox>();
      if (list.isNotEmpty) {
        _rectCollision = list.fold(
          list.first.toRect(),
          (previousValue, element) {
            return previousValue!.expandToInclude(element.toRect());
          },
        );
      }
    }

    final absoluteRect = toAbsoluteRect();

    if (_rectCollision != null) {
      return _rectCollision!.translate(
        absoluteRect.left,
        absoluteRect.top,
      );
    } else {
      return absoluteRect;
    }
  }

  RaycastResult<ShapeHitbox>? raycast(
    Vector2 direction, {
    Vector2? origin,
    double? maxDistance,
    Iterable<ShapeHitbox>? ignoreHitboxes,
  }) {
    try {
      return gameRef.raycast(
        Ray2(
          origin: origin ?? rectCollision.center.toVector2(),
          direction: direction,
        ),
        maxDistance: maxDistance,
        ignoreHitboxes: [
          ...children.query<ShapeHitbox>(),
          ..._getSensorsHitbox(),
          ...ignoreHitboxes ?? [],
        ],
      );
    } catch (e) {
      return null;
    }
  }

  List<RaycastResult<ShapeHitbox>> raycastAll(
    int numberOfRays, {
    Vector2? origin,
    double? maxDistance,
    double startAngle = 0,
    double sweepAngle = tau,
    List<Ray2>? rays,
    List<ShapeHitbox>? ignoreHitboxes,
  }) {
    try {
      return gameRef.raycastAll(
        origin ?? rectCollision.center.toVector2(),
        numberOfRays: numberOfRays,
        maxDistance: maxDistance,
        startAngle: startAngle,
        sweepAngle: sweepAngle,
        rays: rays,
        ignoreHitboxes: [
          ...children.query<ShapeHitbox>(),
          ..._getSensorsHitbox(),
          ...ignoreHitboxes ?? [],
        ],
      );
    } catch (e) {
      return [];
    }
  }

  Iterable<RaycastResult<ShapeHitbox>> raytrace(
    Ray2 ray, {
    int maxDepth = 10,
    List<ShapeHitbox>? ignoreHitboxes,
  }) {
    try {
      return gameRef.raytrace(
        ray,
        maxDepth: maxDepth,
        ignoreHitboxes: [
          ...children.query<ShapeHitbox>(),
          ..._getSensorsHitbox(),
          ...ignoreHitboxes ?? [],
        ],
      );
    } catch (e) {
      return [];
    }
  }

  List<ShapeHitbox> _getSensorsHitbox() {
    final sensorHitBox = <ShapeHitbox>[];
    gameRef.query<Sensor>(onlyVisible: true).forEach((e) {
      sensorHitBox.addAll(e.children.query<ShapeHitbox>());
    });
    return sensorHitBox;
  }

  @override
  void onMount() {
    super.onMount();
    paint.isAntiAlias = false;
    _isHud = componentIsHud;
  }

  @override
  Future<void> onLoad() async => super.onLoad();

  void onGameDetach() {
    _gameMounted = false;
  }

  void onGameMounted() {
    _gameMounted = true;
    children.query<GameComponent>().forEach((c) {
      c.onGameMounted();
    });
  }
}
