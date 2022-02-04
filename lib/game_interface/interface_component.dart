import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:flutter/widgets.dart';

/// Component used to add in your [GameInterface]
class InterfaceComponent extends GameComponent
    with WithAssetsLoader, WithSprite, TapGesture {
  /// identifier
  final int id;

  /// sprite that will be render
  Sprite? spriteUnSelected;

  /// sprite that will be render when pressed
  Sprite? spriteSelected;

  /// Callback used to receive onTab gesture in your component. this return if is selected
  final ValueChanged<bool>? onTapComponent;
  final bool selectable;
  bool _lastSelected = false;
  bool selected = false;

  InterfaceComponent({
    required this.id,
    required Vector2 position,
    required Vector2 size,
    Future<Sprite>? spriteUnSelected,
    Future<Sprite>? spriteSelected,
    this.selectable = false,
    this.onTapComponent,
  }) {
    loader?.add(AssetToLoad(spriteUnSelected, (value) {
      this.spriteUnSelected = value;
    }));
    loader?.add(AssetToLoad(spriteSelected, (value) {
      this.spriteSelected = value;
    }));
    this.position = Vector2(position.x, position.y);
    this.size = size;
  }

  @override
  void update(double dt) {
    sprite = selected ? spriteSelected : spriteUnSelected;
    super.update(dt);
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
  void onTapDown(int pointer, Vector2 position) {
    selected = true;
  }

  @override
  void onTapUp(int pointer, Vector2 position) {}

  @override
  bool get isVisible => true;
}
