import 'package:bonfire/bonfire.dart';
import 'package:bonfire/geometry/shape.dart';
import 'package:flutter/widgets.dart';

final Paint _paintCollision = Paint();

class CollisionArea {
  final Shape shape;
  final Vector2? align;

  CollisionArea(this.shape, {this.align});

  CollisionArea.rectangle({
    required Vector2 size,
    Vector2? align,
  })  : shape = RectangleShape(size),
        align = align ?? Vector2.zero();

  CollisionArea.circle({
    required double radius,
    Vector2? align,
  })  : shape = CircleShape(radius),
        align = align ?? Vector2.zero();

  CollisionArea.polygon({
    required List<Vector2> points,
    Vector2? align,
  })  : shape = PolygonShape(points),
        align = align ?? Vector2.zero();

  CollisionArea clone() {
    late Shape newShape;
    if (shape is PolygonShape) {
      newShape = PolygonShape((shape as PolygonShape).points);
    } else if (shape is CircleShape) {
      newShape = CircleShape((shape as CircleShape).radius);
    } else {
      newShape = RectangleShape((shape as RectangleShape).rect.sizeVector2);
    }
    return CollisionArea(
      newShape,
      align: align?.clone(),
    );
  }

  void updatePosition(Vector2 position) {
    shape.position = Vector2(
      position.x + (align?.x ?? 0.0),
      position.y + (align?.y ?? 0.0),
    );
  }

  void render(Canvas c, Color color, {Paint? overridePaint}) {
    shape.render(c, (overridePaint ?? _paintCollision)..color = color);
  }

  bool verifyCollision(CollisionArea other) {
    return shape.isCollision(other.shape);
  }

  bool verifyCollisionSimulate(Vector2 position, CollisionArea other) {
    Shape? shapeAux;
    if (shape is CircleShape) {
      shapeAux = CircleShape(
        (shape as CircleShape).radius,
      );
    } else if (shape is RectangleShape) {
      shapeAux = RectangleShape(
        Vector2(
          (shape as RectangleShape).rect.width,
          (shape as RectangleShape).rect.height,
        ),
      );
    } else if (shape is PolygonShape) {
      shapeAux = PolygonShape(
        (shape as PolygonShape).relativePoints,
      );
    }

    shapeAux?.position = Vector2(
      position.x + (align?.x ?? 0.0),
      position.y + (align?.y ?? 0.0),
    );
    return shapeAux?.isCollision(other.shape) ?? false;
  }

  Rect get rect {
    if (shape is CircleShape) {
      return (shape as CircleShape).rect.rect;
    }

    if (shape is RectangleShape) {
      return (shape as RectangleShape).rect;
    }

    if (shape is PolygonShape) {
      return (shape as PolygonShape).rect.rect;
    }

    return Rect.zero;
  }

  factory CollisionArea.fromMap(Map<String, dynamic> map) {
    Vector2 align = Vector2(
      map['align']['x'],
      map['align']['y'],
    );
    if (map['shape']['type'] == 'RectangleShape') {
      return CollisionArea.rectangle(
          size: Vector2(
            map['shape']['size']['width'],
            map['shape']['size']['height'],
          ),
          align: align);
    }

    if (map['shape']['type'] == 'CircleShape') {
      return CollisionArea.circle(radius: map['shape']['radius'], align: align);
    }

    if (map['shape']['type'] == 'PolygonShape') {
      return CollisionArea.polygon(
          points: (map['shape']['points'] as List).map((e) {
            return Vector2(e['x'], e['y']);
          }).toList(),
          align: align);
    }

    return CollisionArea.rectangle(
      size: Vector2.zero(),
      align: align,
    );
  }

  Map<String, dynamic> toMap() {
    Map shape = {};
    if (this.shape is RectangleShape) {
      RectangleShape s = this.shape as RectangleShape;
      shape['type'] = 'RectangleShape';
      shape['size'] = {'width': s.width, 'height': s.height};
    }

    if (this.shape is CircleShape) {
      CircleShape s = this.shape as CircleShape;
      shape['type'] = 'CircleShape';
      shape['radius'] = s.radius;
    }

    if (this.shape is PolygonShape) {
      PolygonShape s = this.shape as PolygonShape;
      shape['type'] = 'PolygonShape';
      shape['points'] = s.relativePoints.map((e) {
        return {'x': e.x, 'y': e.y};
      }).toList();
    }

    return {
      'shape': shape,
      'align': {'x': align?.x ?? 0.0, 'y': align?.y ?? 0.0},
    };
  }
}
