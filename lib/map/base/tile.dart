import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/controlled_update_animation.dart';

class Tile extends GameComponent with UseAssetsLoader {
  final String? tileClass;
  late Vector2 _startPosition;
  Vector2 _lastParentPosition = Vector2.zero();
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
    _startPosition = this.position.clone();
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
    _startPosition = this.position.clone();
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
    _startPosition = this.position.clone();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _animation?.render(
      canvas,
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
  void updateTree(double dt) {
    _animation?.update(dt, size);
    if (parent != null) {
      final parentComp = parent as GameComponent;
      if (_lastParentPosition != parentComp.position) {
        _lastParentPosition = parentComp.position.clone();
        position = _lastParentPosition + _startPosition;
      }
    }
    update(dt);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _animation?.onLoad();
  }

  @override
  void onMount() {
    if (opacity == (parent as HasPaint?)?.opacity) {
      paint = (parent as HasPaint?)?.paint ?? paint;
    }
    super.onMount();
  }

  bool get containAnimation => _animation != null;

  @override
  bool get enabledCheckIsVisible => false;
}
