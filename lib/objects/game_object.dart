import 'dart:async';

import 'package:bonfire/bonfire.dart';

class GameObject extends GameComponent with UseSprite, UseAssetsLoader {
  final int? objectPriority;

  GameObject({
    required Vector2 position,
    required Vector2 size,
    required FutureOr<Sprite> sprite,
    Vector2? positionFromTarget,
    this.objectPriority,
  }) {
    this.position = position;
    this.size = size;
    loader?.add(AssetToLoad(sprite, (value) => this.sprite = value));
  }

  @override
  int get priority {
    return objectPriority ?? super.priority;
  }
}
