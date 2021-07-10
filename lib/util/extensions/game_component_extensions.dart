import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';

extension GameComponentExtensions on GameComponent {
  /// This method we notify when detect the component when enter in [radiusVision] configuration
  /// Method that bo used in [update] method.
  void seeComponent(
    GameComponent component, {
    required Function(GameComponent) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
  }) {
    if (component.shouldRemove) {
      if (notObserved != null) notObserved();
      return;
    }

    double vision = radiusVision * 2;

    Rect fieldOfVision = Rect.fromLTWH(
      this.position.center.dx - radiusVision,
      this.position.center.dy - radiusVision,
      vision,
      vision,
    );

    if (fieldOfVision.overlaps(_getRectAndCollision(component).rect)) {
      observed(component);
    } else {
      notObserved?.call();
    }
  }

  /// This method we notify when detect components by type when enter in [radiusVision] configuration
  /// Method that bo used in [update] method.
  void seeComponentType<T extends GameComponent>({
    required Function(List<T>) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
  }) {
    var compVisible = this.gameRef.visibleComponents().where((element) {
      return element is T && element != this;
    }).cast<T>();

    if (compVisible.isEmpty) {
      if (notObserved != null) notObserved();
      return;
    }

    double visionWidth = radiusVision * 2;
    double visionHeight = radiusVision * 2;

    Rect fieldOfVision = Rect.fromLTWH(
      this.position.center.dx - radiusVision,
      this.position.center.dy - radiusVision,
      visionWidth,
      visionHeight,
    );

    List<T> compObserved = compVisible
        .where((comp) => fieldOfVision.overlaps(comp.position.rect))
        .toList();

    if (compObserved.isNotEmpty) {
      observed(compObserved);
    } else {
      notObserved?.call();
    }
  }

  /// This method move this component to target
  /// Need use Movement mixin.
  /// Method that bo used in [update] method.
  void followComponent(
    GameComponent target,
    double dt, {
    required Function(GameComponent) closeComponent,
    double margin = 10,
  }) {
    final comp = _getRectAndCollision(target);
    double centerXPlayer = comp.center.dx;
    double centerYPlayer = comp.center.dy;
    if (!(this is Movement)) {
      print('$this need use Movement mixin.');
      return;
    }

    Movement thisMov = this as Movement;

    double translateX = 0;
    double translateY = 0;
    double speed = thisMov.speed * dt;

    Vector2Rect rectToMove = this.isObjectCollision()
        ? (this as ObjectCollision).rectCollision
        : position;

    translateX =
        rectToMove.rect.center.dx > centerXPlayer ? (-1 * speed) : speed;

    translateX = _adjustTranslate(
      translateX,
      rectToMove.rect.center.dx,
      centerXPlayer,
      speed,
    );
    translateY =
        rectToMove.rect.center.dy > centerYPlayer ? (-1 * speed) : speed;
    translateY = _adjustTranslate(
      translateY,
      rectToMove.rect.center.dy,
      centerYPlayer,
      speed,
    );

    if ((translateX < 0 && translateX > -0.1) ||
        (translateX > 0 && translateX < 0.1)) {
      translateX = 0;
    }

    if ((translateY < 0 && translateY > -0.1) ||
        (translateY > 0 && translateY < 0.1)) {
      translateY = 0;
    }

    Rect rectPlayerCollision = Rect.fromLTWH(
      comp.left - margin,
      comp.top - margin,
      comp.width + (margin * 2),
      comp.height + (margin * 2),
    );

    if (rectToMove.rect.overlaps(rectPlayerCollision)) {
      closeComponent(target);
      if (!thisMov.isIdle) {
        thisMov.idle();
      }
      return;
    }

    translateX = translateX / dt;
    translateY = translateY / dt;

    if (translateX > 0 && translateY > 0) {
      thisMov.moveDownRight(translateX, translateY);
    } else if (translateX < 0 && translateY < 0) {
      thisMov.moveUpLeft(translateX.abs(), translateY.abs());
    } else if (translateX > 0 && translateY < 0) {
      thisMov.moveUpRight(translateX, translateY.abs());
    } else if (translateX < 0 && translateY > 0) {
      thisMov.moveDownLeft(translateX.abs(), translateY);
    } else {
      if (translateX > 0) {
        thisMov.moveRight(translateX);
      } else if (translateX < 0) {
        thisMov.moveLeft(translateX.abs());
      }
      if (translateY > 0) {
        thisMov.moveDown(translateY);
      } else if (translateY < 0) {
        thisMov.moveUp(translateY.abs());
      }
    }
  }

  /// Gets player position used how base in calculations
  Vector2Rect _getRectAndCollision(GameComponent? comp) {
    return (comp is ObjectCollision ? (comp).rectCollision : comp?.position) ??
        Vector2Rect.zero();
  }

  double _adjustTranslate(
    double translate,
    double centerEnemy,
    double centerPlayer,
    double speed,
  ) {
    double innerTranslate = translate;
    if (innerTranslate > 0) {
      double diffX = centerPlayer - centerEnemy;
      if (diffX < speed) {
        innerTranslate = diffX;
      }
    } else if (innerTranslate < 0) {
      double diffX = centerPlayer - centerEnemy;
      if (diffX > (speed * -1)) {
        innerTranslate = diffX;
      }
    }

    return innerTranslate;
  }
}
