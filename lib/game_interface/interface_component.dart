import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/gestures/tap_gesture.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

/// Component used to add in your [GameInterface]
class InterfaceComponent extends GameComponent with TapGesture {
  /// identifier
  final int id;

  /// sprite that will be render
  Sprite? sprite;

  /// sprite that will be render when pressed
  Sprite? spriteSelected;

  /// Callback used to receive onTab gesture in your component. this return if is selected
  final ValueChanged<bool>? onTapComponent;
  final double width;
  final double height;
  final bool selectable;
  bool _lastSelected = false;
  bool selected = false;

  final _loader = AssetsLoader();

  InterfaceComponent({
    required this.id,
    required Vector2 position,
    required this.width,
    required this.height,
    Future<Sprite>? sprite,
    Future<Sprite>? spriteSelected,
    this.selectable = false,
    this.onTapComponent,
  }) {
    _loader.add(AssetToLoad(sprite, (value) {
      this.sprite = value;
    }));
    _loader.add(AssetToLoad(spriteSelected, (value) {
      this.spriteSelected = value;
    }));
    this.position = Vector2(position.x, position.y);
    this.size = Vector2(width, height);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    (selected ? spriteSelected : sprite)?.renderRectWithOpacity(
      canvas,
      toRect(),
      opacity: opacity,
    );
  }

  @override
  void onTapCancel() {
    if (selectable) return;
    selected = !selected;
  }

  @override
  void onTap() {
    if (selectable && !_lastSelected) {
      selected = true;
    } else {
      selected = !selected;
    }
    _lastSelected = selected;
    onTapComponent?.call(selected);
  }

  @override
  PositionType get positionType => PositionType.viewport;

  @override
  Future<void>? onLoad() {
    super.onLoad();
    return _loader.load();
  }

  @override
  void onTapDown(int pointer, Vector2 position) {
    selected = true;
  }

  @override
  void onTapUp(int pointer, Vector2 position) {}
}
