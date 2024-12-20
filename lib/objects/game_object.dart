import 'dart:async';

import 'package:bonfire/bonfire.dart';

// Component with `Sprite`
class GameObject extends GameComponent
    with UseSprite, Lighting, UseAssetsLoader {
  final int? objectPriority;

  GameObject({
    required Vector2 position,
    required Vector2 size,
    required FutureOr<Sprite>? sprite,
    LightingConfig? lightingConfig,
    this.objectPriority,
    double angle = 0,
    Anchor anchor = Anchor.topLeft,
    bool renderAboveComponents = false,
  }) {
    this.renderAboveComponents = renderAboveComponents;
    this.anchor = anchor;
    this.position = position;
    this.size = size;
    this.angle = angle;
    loader?.add(AssetToLoad<Sprite>(sprite, (value) => this.sprite = value));
    setupLighting(lightingConfig);
  }

  @override
  int get priority {
    return objectPriority ?? super.priority;
  }
}
