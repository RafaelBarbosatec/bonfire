import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/vector2rect.dart';

abstract class FollowerObject extends GameComponent {
  final GameComponent target;
  final Vector2Rect? positionFromTarget;

  FollowerObject(
    this.target,
    this.positionFromTarget,
  );

  @override
  void update(double dt) {
    super.update(dt);
    final newPosition = positionFromTarget ?? Vector2Rect.zero();
    this.position = Vector2Rect.fromRect(
      Rect.fromLTWH(
        target.position.rect.left,
        target.position.rect.top,
        newPosition.rect.width,
        newPosition.rect.height,
      ).translate(
        newPosition.rect.left,
        newPosition.rect.top,
      ),
    );
  }

  @override
  int get priority => target.priority;
}
