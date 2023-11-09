import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/controlled_update_animation.dart';

class Tile extends GameComponent with UseAssetsLoader {
  final String? tileClass;
  String id = '';
  Sprite? _sprite;
  ControlledUpdateAnimation? _animation;
  Color? color;

  Tile({
    required String spritePath,
    required Vector2 position,
    required Vector2 size,
    this.tileClass,
    this.color,
    Map<String, dynamic>? properties,
    double offsetX = 0,
    double offsetY = 0,
  }) {
    this.properties = properties;
    applyBleedingPixel(
      position: position,
      size: size,
      offsetX: offsetX,
      offsetY: offsetY,
      calculatePosition: true,
    );
    if (spritePath.isNotEmpty) {
      loader?.add(
        AssetToLoad(Sprite.load(spritePath), (value) => _sprite = value),
      );
    }
  }

  Tile.fromSprite({
    required Sprite? sprite,
    required Vector2 position,
    required Vector2 size,
    this.tileClass,
    Map<String, dynamic>? properties,
    double offsetX = 0,
    double offsetY = 0,
    this.color,
  }) {
    this.properties = properties;
    id = '${position.x}/${position.y}';
    _sprite = sprite;
    applyBleedingPixel(
      position: position,
      size: size,
      offsetX: offsetX,
      offsetY: offsetY,
      calculatePosition: true,
    );
  }

  Tile.fromAnimation({
    required ControlledUpdateAnimation animation,
    required Vector2 position,
    required Vector2 size,
    this.tileClass,
    Map<String, dynamic>? properties,
    double offsetX = 0,
    double offsetY = 0,
  }) {
    properties = properties;
    id = '${position.x}/${position.y}';
    _animation = animation;
    applyBleedingPixel(
      position: position,
      size: size,
      offsetX: offsetX,
      offsetY: offsetY,
      calculatePosition: true,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _animation?.render(
      canvas,
      size: size,
      overridePaint: paint,
    );
    _sprite?.render(
      canvas,
      size: size,
      overridePaint: paint,
    );
    if (color != null) {
      canvas.drawRect(toRect(), paint..color = color!);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animation?.update(dt, size);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _animation?.onLoad();
  }

  bool get containAnimation => _animation != null;

  @override
  bool get enabledCheckIsVisible => false;

  @override
  int get priority => 0;

  @override
  void renderDebugMode(Canvas canvas) {}
}
