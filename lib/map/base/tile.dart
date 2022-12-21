import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/controlled_update_animation.dart';
import 'package:flutter/widgets.dart';

class Tile extends GameComponent with UseAssetsLoader {
  final String? type;
  late Vector2 _positionText;
  late Vector2 _startPosition;
  Vector2 _lastParentPosition = Vector2.zero();
  Paint? _paintText;
  TextPaint? _textPaintConfig;
  String id = '';
  Sprite? _sprite;
  ControlledUpdateAnimation? _animation;
  Color? color;

  Tile({
    required String spritePath,
    required Vector2 position,
    required Vector2 size,
    this.type,
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

    _positionText = position;
  }

  Tile.fromSprite({
    required Sprite? sprite,
    required Vector2 position,
    required Vector2 size,
    this.type,
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
    _positionText = position;
  }

  Tile.fromAnimation({
    required ControlledUpdateAnimation animation,
    required Vector2 position,
    required Vector2 size,
    this.type,
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
    _positionText = position;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _animation?.render(
      canvas,
      position: position,
      size: size,
      overridePaint: paint,
    );
    _sprite?.render(
      canvas,
      position: position,
      size: size,
      overridePaint: paint,
    );
    if (color != null) {
      canvas.drawRect(toRect(), paint..color = color!);
    }
  }

  @override
  void renderDebugMode(Canvas canvas) {
    _drawGrid(canvas);
  }

  void _drawGrid(Canvas canvas) {
    _paintText ??= Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(
      toRect(),
      _paintText!
        ..color = gameRef.constructionModeColor ??
            const Color(0xFF00BCD4).withOpacity(0.5),
    );
    if (_positionText.x % 2 == 0) {
      _textPaintConfig ??= TextPaint(
        style: TextStyle(
          fontSize: width / 3,
          color: gameRef.constructionModeColor ??
              const Color(0xFF00BCD4).withOpacity(0.5),
        ),
      );
      _textPaintConfig?.render(
        canvas,
        '${_positionText.x.toInt()}:${_positionText.y.toInt()}',
        Vector2(position.x + 2, position.y + 2),
      );
    }
  }

  @override
  void updateTree(double dt) {
    _animation?.update(dt);
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
