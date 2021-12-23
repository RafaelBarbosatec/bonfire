import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/map_paint.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:bonfire/util/controlled_update_animation.dart';
import 'package:flutter/widgets.dart';

class Tile extends GameComponent {
  Sprite? _sprite;
  ControlledUpdateAnimation? _animation;
  final double width;
  final double height;
  final String? type;
  late Vector2 _positionText;
  Paint? _paintText;
  AssetsLoader? _loader;
  final Map<String, dynamic>? properties;
  TextPaint? _textPaintConfig;
  String id = '';

  Tile(
    String spritePath,
    Vector2 position, {
    this.width = 32,
    this.height = 32,
    this.type,
    this.properties,
  }) {
    this.position = generateRectWithBleedingPixel(position, width, height);
    if (spritePath.isNotEmpty) {
      _loader = AssetsLoader();
      _loader?.add(
        AssetToLoad(Sprite.load(spritePath), (value) => this._sprite = value),
      );
    }

    _positionText = position;
  }

  Tile.fromSprite(
    Sprite sprite,
    Vector2 position, {
    this.width = 32,
    this.height = 32,
    this.type,
    this.properties,
    double offsetX = 0,
    double offsetY = 0,
  }) {
    id = '${position.x}/${position.y}';
    this._sprite = sprite;
    this.position = generateRectWithBleedingPixel(
      position,
      width,
      height,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    _positionText = position;
  }

  Tile.fromFutureSprite(
    Future<Sprite> sprite,
    Vector2 position, {
    this.width = 32,
    this.height = 32,
    this.type,
    this.properties,
    double offsetX = 0,
    double offsetY = 0,
  }) {
    id = '${position.x}/${position.y}';
    _loader = AssetsLoader();
    _loader?.add(AssetToLoad(sprite, (value) => this._sprite = value));
    this.position = generateRectWithBleedingPixel(
      position,
      width,
      height,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    _positionText = position;
  }

  Tile.fromAnimation(
    ControlledUpdateAnimation animation,
    Vector2 position, {
    this.width = 32,
    this.height = 32,
    this.type,
    this.properties,
    double offsetX = 0,
    double offsetY = 0,
  }) {
    id = '${position.x}/${position.y}';
    this._animation = animation;
    this.position = generateRectWithBleedingPixel(
      position,
      width,
      height,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    _positionText = position;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _animation?.render(canvas, position);
    _sprite?.renderFromVector2Rect(
      canvas,
      position,
      overridePaint: MapPaint.instance.paint,
    );
  }

  @override
  void renderDebugMode(Canvas canvas) {
    _drawGrid(canvas);
  }

  void _drawGrid(Canvas canvas) {
    if (_paintText == null) {
      _paintText = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
    }
    canvas.drawRect(
      position.rect,
      _paintText!
        ..color = (gameRef as BonfireGame).constructionModeColor ??
            Color(0xFF00BCD4).withOpacity(0.5),
    );
    if (_positionText.x % 2 == 0) {
      if (_textPaintConfig == null) {
        _textPaintConfig = TextPaint(
          style: TextStyle(
            fontSize: width / 3,
            color: (gameRef as BonfireGame).constructionModeColor ??
                Color(0xFF00BCD4).withOpacity(0.5),
          ),
        );
      }
      _textPaintConfig?.render(
        canvas,
        '${_positionText.x.toInt()}:${_positionText.y.toInt()}',
        Vector2(position.rect.left + 2, position.rect.top + 2),
      );
    }
  }

  Vector2Rect generateRectWithBleedingPixel(
    Vector2 position,
    double width,
    double height, {
    double offsetX = 0,
    double offsetY = 0,
  }) {
    double sizeMax = max(width, height);
    double blendingPixel = sizeMax * 0.05;

    if (blendingPixel > 2) {
      blendingPixel = 2;
    }

    return Rect.fromLTWH(
      (position.x * width) -
          (position.x % 2 == 0 ? (blendingPixel / 2) : 0) +
          offsetX,
      (position.y * height) -
          (position.y % 2 != 0 ? (blendingPixel / 2) : 0) +
          offsetY,
      width + (position.x % 2 == 0 ? blendingPixel : 0),
      height + (position.y % 2 != 0 ? blendingPixel : 0),
    ).toVector2Rect();
  }

  @override
  // ignore: must_call_super
  void update(double dt) {
    _animation?.update(dt);

    /// not used super.update(dt); to avoid consulting unnecessary computational resources
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    await _loader?.load();
    await _animation?.onLoad();
    _loader = null;
  }

  bool get containAnimation => _animation != null;
}
