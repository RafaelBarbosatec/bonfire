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
  final String _keyIntervalCheckIsVisible = "CHECK_VISIBLE";
  final int _intervalCheckIsVisible = 100;
  Map<String, dynamic>? properties;

  /// When true this component render above all components in game.
  bool renderAboveComponents = false;

  /// Param checks if this component is visible on the screen
  bool _isVisibleInScreen = false;

  bool get isVisible => _visible ? _isVisibleInScreen : false;
  set isVisible(bool visible) {
    _visible = visible;
  }

  /// Param used to enable or disable the render.
  bool _visible = true;

  bool enabledCheckIsVisible = true;

  /// Get BuildContext
  BuildContext get context => gameRef.context;

  double lastAngle = 0;

  @override
  set angle(double a) {
    lastAngle = super.angle;
    super.angle = a;
  }

  Rect? _rectCollision;

  @override
  int get priority {
    if (renderAboveComponents && hasGameRef) {
      return LayerPriority.getAbovePriority(gameRef.highestPriority);
    }
    return LayerPriority.getComponentPriority(rectCollision.bottom.floor());
  }

  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);
    _checkIsVisible(dt);
  }

  void _checkIsVisible(double dt) {
    if (!enabledCheckIsVisible) return;
    if (checkInterval(
      _keyIntervalCheckIsVisible,
      _intervalCheckIsVisible,
      dt,
    )) {
      _onSetIfVisible();
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
    return hasGameRef ? gameRef.isVisibleInCamera(this) : false;
  }

  @override
  @mustCallSuper
  void onRemove() {
    (gameRef as BonfireGame).removeVisible(this);
    super.onRemove();
  }

  void _onSetIfVisible() {
    if (!_visible) return;
    bool nowIsVisible = isVisibleInCamera();
    if (isHud) {
      nowIsVisible = true;
      enabledCheckIsVisible = false;
    }
    if (nowIsVisible && !isVisible) {
      (gameRef as BonfireGame).addVisible(this);
    }
    if (!nowIsVisible && isVisible) {
      (gameRef as BonfireGame).removeVisible(this);
    }
    _isVisibleInScreen = nowIsVisible;
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

  void onGameDetach() {}

  void _confHitBoxRender(Component component) {
    if (component is ShapeHitbox) {
      if (gameRef.showCollisionArea) {
        var paintCollition = Paint()
          ..color = gameRef.collisionAreaColor ?? const Color(0xffffffff);
        if (component is Sensor) {
          paintCollition.color = sensorColor;
        }
        component.paint = paintCollition;
        component.renderShape = true;
      }
    }
  }

  bool get containsShapeHitbox {
    return shapeHitboxes.isNotEmpty;
  }

  List<ShapeHitbox> get shapeHitboxes => children.query<ShapeHitbox>();

  Rect get rectCollision {
    if (_rectCollision == null) {
      var list = children.query<ShapeHitbox>();
      if (list.isNotEmpty) {
        _rectCollision = children.query<ShapeHitbox>().fold(
          list.first.toRect(),
          (previousValue, element) {
            return previousValue!.expandToInclude(element.toRect());
          },
        );
      }
    }
    var absoluteRect = toAbsoluteRect();

    if (_rectCollision != null) {
      return _rectCollision!.translate(absoluteRect.left, absoluteRect.top);
    } else {
      return absoluteRect;
    }
  }

  RaycastResult<ShapeHitbox>? raycast(
    Vector2 direction, {
    Vector2? origin,
    double? maxDistance,
    List<ShapeHitbox>? ignoreHitboxes,
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
    var sensorHitBox = <ShapeHitbox>[];
    gameRef.query<Sensor>(onlyVisible: true).forEach((e) {
      sensorHitBox.addAll(e.children.query<ShapeHitbox>());
    });
    return sensorHitBox;
  }

  @override
  void onMount() {
    paint.isAntiAlias = false;
    super.onMount();
  }
}
